#!/bin/bash

# Logging functions
log() {
    echo -e "\033[1;34m[INFO] $1\033[0m"
}

error() {
    echo -e "\033[1;31m[ERROR] $1\033[0m" >&2
}

# Check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Homebrew package installation/upgrade function
install_brew_or_upgrade() {
    if brew list "$1" &>/dev/null; then
        log "$1 is already installed. Upgrading..."
        brew upgrade "$1"
    else
        log "Installing $1..."
        brew install "$1"
    fi
}

# Homebrew cask installation/upgrade function
install_cask_or_upgrade() {
    if brew list --cask "$1" &>/dev/null; then
        log "$1 is already installed. Re-installing/upgrading..."
        brew reinstall --cask "$1"
    else
        log "Installing $1..."
        brew install --cask "$1"
    fi
}
