#!/bin/bash

# Import utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.mac.sh"

install_homebrew() {
    if ! command_exists brew; then
        log "Installing Homebrew..."

        # Добавляем Homebrew в PATH для текущей сессии
        export PATH="/opt/homebrew/bin:$PATH"
        # Install brew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Настраиваем Homebrew для текущего пользователя
        echo >> "$HOME/.zprofile"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        log "Homebrew is already installed. Running brew update..."
        brew update
        brew upgrade
    fi
}

# Execute if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_homebrew
fi
