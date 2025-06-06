#!/bin/bash

# Import utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.mac.sh"

config_shell() {
    log "Setting up Zsh and configurations..."

    # Install Zsh using the common function
    if ! install_brew_or_upgrade zsh; then
        error "Failed to install Zsh"
        return 1
    fi

    # Install Starship using Homebrew
    if ! install_brew_or_upgrade starship; then
        error "Failed to install Starship"
        return 1
    fi

    # Install Zsh plugins using Homebrew
    if ! install_brew_or_upgrade zsh-autosuggestions; then
        error "Failed to install zsh-autosuggestions"
        return 1
    fi

    if ! install_brew_or_upgrade zsh-syntax-highlighting; then
        error "Failed to install zsh-syntax-highlighting"
        return 1
    fi

    # Install Oh My Zsh if not already installed
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

        if [ $? -ne 0 ]; then
            error "Failed to install Oh My Zsh"
            return 1
        fi
    else
        log "Oh My Zsh is already installed"
    fi

    # Configure Zsh
    log "Configuring Zsh..."

    # Backup existing .zshrc if it exists
    if [ -f "$HOME/.zshrc" ]; then
        mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    fi

    # Create new .zshrc
    cat > "$HOME/.zshrc" << 'EOL'
# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Disable default theme for Oh My Zsh
ZSH_THEME=""

# Configure oh-my-zsh plugins
#plugins=(
#    git
#    docker
#    docker-compose
#    kubectl
#)

source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR='nvim'
export VISUAL='nvim'

# Initialize Starship
eval "$(starship init zsh)"

# Source Homebrew-installed plugins
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
EOL

    # Create Starship configuration directory
    mkdir -p ~/.config

    # Create default Starship configuration
    cat > ~/.config/starship.toml << 'EOL'
# Get editor completions based on the config schema
"$schema" = 'https://starship.rs/config-schema.json'

# Wait 10 milliseconds for starship to check files under the current directory.
scan_timeout = 10

# Use custom format
format = """
$username\
$hostname\
$directory\
$git_branch\
$git_status\
$cmd_duration\
$line_break\
$python\
$nodejs\
$character"""

[directory]
style = "blue bold"
truncate_to_repo = true
truncation_length = 3

[character]
success_symbol = "[❯](purple)"
error_symbol = "[❯](red)"
vimcmd_symbol = "[❮](green)"

[git_branch]
format = "[$branch]($style)"
style = "bright-black"

[git_status]
format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)"
style = "cyan"
conflicted = "​"
untracked = "​"
modified = "​"
staged = "​"
renamed = "​"
deleted = "​"
stashed = "≡"

[git_state]
format = '\([$state( $progress_current/$progress_total)]($style)\) '
style = "bright-black"

[cmd_duration]
format = "[$duration]($style) "
style = "yellow"

[python]
format = '[${symbol}${pyenv_prefix}(${version} )(\($virtualenv\) )]($style)'
symbol = "🐍 "
style = "yellow bold"

[nodejs]
format = '[${symbol}(${version} )]($style)'
symbol = "⬢ "
style = "green bold"
EOL

    # Set Zsh as default shell if it isn't already
    if [ "$SHELL" != "$(which zsh)" ]; then
        log "Setting Zsh as default shell..."
        chsh -s "$(which zsh)"
    fi

    log "Zsh setup completed. Please restart your terminal for changes to take effect."
}

# Execute if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    config_shell
fi
