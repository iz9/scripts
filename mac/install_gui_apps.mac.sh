#!/bin/bash

# Import utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.mac.sh"

# Arrays of applications (parallel arrays)
CASK_NAMES=(
    "jetbrains-toolbox"
    "ticktick"
    "telegram"
    "obsidian"
    "commander-one"
    "readdle-spark"
    "kap"
    "rectangle"
    "openvpn-connect"
    "slack"
    "zoom"
    "firefox"
)

APP_NAMES=(
    "JetBrains Toolbox"
    "TickTick"
    "Telegram"
    "Obsidian"
    "Commander One"
    "Spark"
    "Kap"
    "Rectangle"
    "OpenVPN Connect"
    "Slack"
    "Zoom"
    "Firefox"
)

install_gui_apps() {
    log "Starting GUI applications installation..."

    local i
    for i in "${!CASK_NAMES[@]}"; do
        cask_name="${CASK_NAMES[$i]}"
        app_name="${APP_NAMES[$i]}"

        log "Installing $app_name..."

        # Install application
        if ! install_cask_or_upgrade "$cask_name"; then
            error "Failed to install $app_name"
            ask_continue
            continue
        fi

        # Launch application
        log "Launching $app_name for initial setup..."
        open -a "$app_name"

        # Wait for user confirmation
        echo
        echo "Please complete initial setup for $app_name"
        echo "1. Configure the application according to your preferences"
        echo "2. Once done, close the application"
        read -p "Press Enter when you're ready to continue with the next application..."

        # Kill application to ensure clean state for next launch
        killall "$app_name" 2>/dev/null || true
        sleep 2

        log "$app_name installation and configuration completed!"
        echo
    done

    log "All GUI applications have been installed and configured!"
}

ask_continue() {
    read -p "Would you like to continue with the remaining applications? (y/n) " answer
    case "$answer" in
        [Yy]*)
            return 0
            ;;
        *)
            log "Installation aborted by user"
            exit 1
            ;;
    esac
}

# Execute if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_gui_apps
fi
