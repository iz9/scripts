#!/bin/bash

# Import utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.mac.sh"

install_xcode_tools() {
    if ! command_exists xcode-select; then
        log "Installing Xcode command-line tools..."
        xcode-select --install

        # Wait for xcode-select installation to complete
        while ! command_exists xcode-select; do
            log "Waiting for Xcode command-line tools installation to complete..."
            sleep 10
        done

        log "Xcode command-line tools installation completed."
    else
        log "Checking for Xcode command-line tools updates..."
        softwareupdate --install -a
    fi
}

# Execute if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_xcode_tools
fi
