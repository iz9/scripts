#!/bin/bash

# Import utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.ios.sh"

install_rosetta() {
    # Check if running on Apple Silicon
    if [[ "$(uname -m)" == "arm64" ]]; then
        log "Checking for Rosetta 2 installation..."

        # Check if Rosetta is already installed
        if ! pkgutil --pkgs | grep -q "com.apple.pkg.RosettaUpdateAuto"; then
            log "Installing Rosetta 2..."
            # Install Rosetta 2 with automatic acceptance of license
            if ! softwareupdate --install-rosetta --agree-to-license; then
                error "Failed to install Rosetta 2"
                return 1
            fi
            log "Rosetta 2 installed successfully."
        else
            log "Rosetta 2 is already installed."
        fi
    else
        log "Not running on Apple Silicon - Rosetta 2 not needed."
    fi
}

# Execute if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_rosetta
fi
