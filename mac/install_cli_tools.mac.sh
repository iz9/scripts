#!/usr/bin/env bash

# Import utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.ios.sh"

install_cli_tools() {
    log "Installing CLI tools and utilities..."

    # Define array of CLI tools
    tools=(
        "fzf"
        "ripgrep"
        "bat"
        "eza"
        "btop"
        "navi"
        "zoxide"
        "wget"
        "curl"
        "fd"
        "jq"
        "tlrc"
        "tree"
        "ncdu"
        "httpie"
        "doggo"
        "duf"
        "htop"
        "sevenzip"
    )


    # Install each tool
    for i in "${!tools[@]}"; do
        log "Installing ${tools[$i]}"
        if ! install_brew_or_upgrade "${tools[$i]}"; then
            error "Failed to install ${tools[$i]}"
            continue
        fi
    done
    # Configure fzf
    if command -v fzf >/dev/null; then
        log "Configuring fzf..."
        $(brew --prefix)/opt/fzf/install --all
    fi

    # Configure zoxide
    if command -v zoxide >/dev/null; then
        log "Configuring zoxide..."
        echo 'eval "$(zoxide init bash)"' >> ~/.bashrc
        echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
    fi

    # Create shell configuration for tools
    create_shell_config

    log "CLI tools installation completed!"
    log "Please restart your shell or run 'source ~/.bashrc' (or ~/.zshrc) to apply changes."
}

create_shell_config() {
    local config_file="$HOME/.shell_tools_config"

    cat > "$config_file" << 'EOL'
# CLI Tools Configuration

# curl configuration
export PATH="/opt/homebrew/opt/curl/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/curl/lib"
export CPPFLAGS="-I/opt/homebrew/opt/curl/include"

# fzf configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# bat configuration
export BAT_THEME="TwoDark"
export BAT_STYLE="numbers,changes,header"
alias cat='bat --paging=never'

# eza configuration (modern ls replacement)
if command -v eza >/dev/null; then
    alias ls='eza --icons'
    alias ll='eza -l --icons --git'
    alias la='eza -la --icons --git'
    alias lt='eza --tree --icons'
    alias l.='eza -d .* --icons'
fi

# ripgrep configuration
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# Create ripgrep config if it doesn't exist
if [ ! -f "$RIPGREP_CONFIG_PATH" ]; then
    cat > "$RIPGREP_CONFIG_PATH" << 'RGEOF'
--smart-case
--hidden
--glob=!.git/*
--max-columns=150
--max-columns-preview
RGEOF
fi

# General aliases
alias du='duf'
alias top='btop'
alias find='fd'
alias help='tldr'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Enhanced grep using ripgrep
alias grep='rg'

# HTTP client
alias https='http --default-scheme=https'

# Directory size
alias dirsize='du -sh'

# History with timestamp
alias history='history -i'

# Tree with gitignore
alias treeg='tree -a -I ".git|node_modules|.DS_Store"'

# Process finding
alias pf='ps aux | grep'

# Memory usage
alias meminfo='free -h'

# Disk usage
alias disk='duf'
alias space='ncdu'

# Network tools
alias ports='netstat -tulanp'
alias ping='doggo'

# Function to create and enter directory
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Function to extract various archive types
extract() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar x $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)          echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Function to search command history
fh() {
    eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
}

# Function to kill process
fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

    if [ "x$pid" != "x" ]; then
        echo $pid | xargs kill -${1:-9}
    fi
}

# tldr = tlrc
alias tldr='tlrc'
EOL

    # Add source to shell rc files
    for rc in ~/.bashrc ~/.zshrc; do
        if [[ -f "$rc" ]]; then
            if ! grep -q "source.*\.shell_tools_config" "$rc"; then
                echo "source ~/.shell_tools_config" >> "$rc"
            fi
        fi
    done
}

# Execute if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_cli_tools
fi
