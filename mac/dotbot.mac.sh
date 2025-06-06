#!/bin/bash

# Import utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.ios.sh"

DOTFILES_DIR="$HOME/.dotfiles"
DOTFILES_REPO="git@github.com:iz9/dotfiles-mac.git" # Замените на URL вашего репозитория

install_dotbot() {
    if [[ "$1" == "backup" ]]; then
        backup_dotfiles
    elif [[ "$1" == "restore" ]]; then
        restore_dotfiles
    else
        error "Please specify mode: backup or restore"
        echo "Usage: $0 backup|restore"
        exit 1
    fi
}

backup_dotfiles() {
    log "Starting dotfiles backup process..."

    # Create dotfiles directory
    mkdir -p "$DOTFILES_DIR"
    cd "$DOTFILES_DIR" || exit 1

    # Initialize git repository
    if [[ ! -d ".git" ]]; then
        git init
        git remote add origin "$DOTFILES_REPO"
    fi

    # Add dotbot as a submodule
    if [[ ! -d "dotbot" ]]; then
        log "Adding dotbot as a submodule..."
        git submodule add https://github.com/anishathalye/dotbot
        git config -f .gitmodules submodule.dotbot.ignore dirty
    fi

    # Create directory structure
    mkdir -p {config,git,zsh,ssh,bash,ripgrep,ideavim}
    mkdir -p config/{wezterm,nvim,starship}

    # Backup existing configurations
    log "Backing up configurations..."

    # IdeaVim
    cp ~/.ideavimrc ideavim/ideavimrc 2>/dev/null || true

    # WezTerm
    cp -r ~/.config/wezterm/* config/wezterm/ 2>/dev/null || true

    # Git
    cp ~/.gitconfig git/gitconfig 2>/dev/null || true
    cp ~/.gitignore_global git/gitignore_global 2>/dev/null || true

    # Bash
    cp ~/.bashrc bash/bashrc 2>/dev/null || true
    cp ~/.fzf.bash bash/fzf.bash 2>/dev/null || true

    # Zsh
    cp ~/.zshrc zsh/zshrc 2>/dev/null || true
    cp ~/.zshenv zsh/zshenv 2>/dev/null || true
    cp ~/.zprofile zsh/zprofile 2>/dev/null || true
    cp ~/.fzf.zsh zsh/fzf.zsh 2>/dev/null || true
    cp ~/.shell_tools_config zsh/shell_tools_config 2>/dev/null || true

    # ripgrep
    cp ~/.ripgreprc ripgrep/ripgreprc 2>/dev/null || true

    # Starship
    cp ~/.config/starship.toml config/starship/starship.toml 2>/dev/null || true

    # SSH
    cp ~/.ssh/config ssh/config 2>/dev/null || true
    chmod 600 ssh/config 2>/dev/null || true

    # Neovim
    cp -r ~/.config/nvim/* config/nvim/ 2>/dev/null || true

    # Create/update dotbot configuration
    create_dotbot_config
    create_install_script
    create_readme

    # Git operations
    log "Committing changes..."
    git add .
    git commit -m "Update dotfiles: $(date +%Y-%m-%d)"

    # Ask to push changes
    read -p "Would you like to push changes to remote repository? (y/n) " answer
    if [[ $(echo "$answer" | tr '[:upper:]' '[:lower:]') == "y" ]]; then
        git push -u origin master
    fi

    log "Dotfiles backup completed!"
}

restore_dotfiles() {
    log "Starting dotfiles restoration process..."

    # Check if dotfiles directory exists
    if [[ -d "$DOTFILES_DIR" ]]; then
        read -p "Dotfiles directory already exists. Remove it? (y/n) " answer
        if [[ $(echo "$answer" | tr '[:upper:]' '[:lower:]') == "y" ]]; then
            rm -rf "$DOTFILES_DIR"
        else
            error "Cannot proceed with existing dotfiles directory"
            exit 1
        fi
    fi

    # Clone dotfiles repository
    log "Cloning dotfiles repository..."
    git clone --recursive "$DOTFILES_REPO" "$DOTFILES_DIR"

    # Enter dotfiles directory
    cd "$DOTFILES_DIR" || exit 1

    # Update submodules
    log "Updating submodules..."
    git submodule update --init --recursive

    # Run installation
    log "Running dotbot installation..."
    ./install

    log "Dotfiles restoration completed!"
}

create_dotbot_config() {
    log "Creating dotbot configuration..."

    cat > install.conf.yaml << 'EOL'
- defaults:
    link:
      create: true
      relink: true
      force: true

- clean: ['~']

- link:
    ~/.config/wezterm: config/wezterm
    ~/.gitconfig: git/gitconfig
    ~/.gitignore_global: git/gitignore_global
    ~/.bashrc: bash/bashrc
    ~/.fzf.bash: bash/fzf.bash
    ~/.zshrc: zsh/zshrc
    ~/.zshenv: zsh/zshenv
    ~/.zprofile: zsh/zprofile
    ~/.fzf.zsh: zsh/fzf.zsh
    ~/.shell_tools_config: zsh/shell_tools_config
    ~/.config/starship.toml: config/starship/starship.toml
    ~/.config/nvim: config/nvim
    ~/.ssh/config: ssh/config
    ~/.ripgreprc: ripgrep/ripgreprc
    ~/.ideavimrc: ideavim/ideavimrc

- shell:
    - [git submodule update --init --recursive, Installing submodules]
EOL
}

create_install_script() {
    log "Creating installation script..."

    cat > install << 'EOL'
#!/usr/bin/env bash

set -e

CONFIG="install.conf.yaml"
DOTBOT_DIR="dotbot"

DOTBOT_BIN="bin/dotbot"
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "${BASEDIR}"
git -C "${DOTBOT_DIR}" submodule sync --quiet --recursive
git submodule update --init --recursive "${DOTBOT_DIR}"

"${BASEDIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${BASEDIR}" -c "${CONFIG}" "${@}"
EOL

    chmod +x install
}

create_readme() {
    cat > README.md << 'EOL'
# Dotfiles

Personal dotfiles managed with [dotbot](https://github.com/anishathalye/dotbot).

## Backup

To backup current configurations:
```bash
./install_dotbot.sh backup
```

## Restore

To restore configurations on a new system:
```bash
./install_dotbot.sh restore
```

## Structure
# .
# ├── config/                     # Application configurations
# │   ├── wezterm/               # WezTerm configuration
# │   ├── nvim/                  # Neovim configuration
# │   └── starship/             # Starship prompt configuration
# ├── git/                       # Git configuration
# ├── zsh/                       # Zsh configuration
# ├── ssh/                       # SSH configuration
# ├── install                    # Dotbot installation script
# └── install.conf.yaml          # Dotbot configuration
EOL
}

# Execute if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_dotbot "$1"
fi
