#!/bin/bash

# Import utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.mac.sh"

install_fonts() {
    log "Installing required fonts..."

    # Add homebrew tap for fonts
    brew tap homebrew/cask-fonts

    # Install fonts
    local fonts=(
        "font-jetbrains-mono-nerd-font"    # JetBrainsMono Nerd Font
        "font-jetbrains-mono"              # JetBrains Mono
        "font-symbols-only-nerd-font"      # Symbols Nerd Font Mono
    )

    for font in "${fonts[@]}"; do
        log "Installing font: $font"
        if ! brew install --cask "$font"; then
            error "Failed to install $font"
        fi
    done

    log "Font installation completed!"

    # Clear font cache
    if command -v fc-cache >/dev/null; then
        log "Clearing font cache..."
        fc-cache -f -v
    fi
}

# Execute if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_fonts
fi
