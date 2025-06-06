#!/bin/bash

# Function to check if mas is installed
check_mas() {
    if ! command -v mas &> /dev/null; then
        echo "mas-cli is not installed. Installing..."
        if ! brew install mas; then
            echo "Error: Failed to install mas-cli"
            return 1
        fi
        echo "mas-cli installed successfully"
    else
        echo "mas-cli is already installed"
    fi
}

# Function to handle app installation
install_app() {
    local app_id=$1
    local app_name=$2

    echo "----------------------------------------"
    echo "Installing $app_name..."
    echo "App Store link:"
    mas info "$app_id"

    read -p "Please install $app_name from the App Store and press Enter when done..."

    if ! mas list | grep -q "^$app_id"; then
        echo "Warning: $app_name ($app_id) does not appear to be installed!"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    else
        echo "✓ $app_name is installed"
    fi
    return 0
}

# Main installation function
install_mas_apps() {
    echo "Starting Mac App Store applications installation..."

    # Check for mas-cli
    check_mas

    # Array of apps with their IDs and names
    declare -A apps=(
        [497799835]="Xcode"
        [937984704]="Amphetamine"
        [1388020431]="DevCleaner"
        [595191960]="CopyClip"
        [1339170533]="CleanMyMac"
    )

    # Install each app
    local failed_apps=()
    for app_id in "${!apps[@]}"; do
        if ! install_app "$app_id" "${apps[$app_id]}"; then
            failed_apps+=("${apps[$app_id]}")
        fi
    done

    echo "----------------------------------------"
    echo "Mac App Store applications installation completed!"

    # Report failed installations if any
    if [ ${#failed_apps[@]} -ne 0 ]; then
        echo "The following apps were not confirmed as installed:"
        printf '%s\n' "${failed_apps[@]}"
        return 1
    fi

    return 0
}

# Execute if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_mas_apps
fi
