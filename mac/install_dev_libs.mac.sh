#!/bin/bash

# Import utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.ios.sh"

install_dev_libs() {
    log "Installing development libraries..."

    # Array of required development libraries
    local dev_libs=(
        "gpg"
        "gawk"
        "openssl"
        "libyaml"
        "libffi"
        "readline"
        "zlib"
        "xz"
    )

    # Install or upgrade each library
    for lib in "${dev_libs[@]}"; do
        if ! install_brew_or_upgrade "$lib"; then
            error "Failed to install $lib"
            return 1
        fi
    done

    log "Development libraries installation completed."
}

# Execute if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_dev_libs
fi
