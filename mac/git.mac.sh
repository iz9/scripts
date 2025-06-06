#!/bin/bash

# Import utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.ios.sh"

install_and_configure_git() {
    log "Setting up Git and configurations..."

    # Install Git using Homebrew if not already installed
    if ! install_brew_or_upgrade git; then
        error "Failed to install Git"
        return 1
    fi

    # Install additional Git tools
    local git_tools=(
        "git-delta"    # better diff viewer
        "lazygit"      # terminal UI for git
        "gh"          # GitHub CLI
    )

    for tool in "${git_tools[@]}"; do
        if ! install_brew_or_upgrade "$tool"; then
            error "Failed to install $tool"
            return 1
        fi
    done

    # Configure Git
    log "Configuring Git..."

    # Prompt for user information if not already set
    if [[ -z "$(git config --global user.name)" ]]; then
        read -p "Enter your Git username: " git_username
        git config --global user.name "$git_username"
    fi

    if [[ -z "$(git config --global user.email)" ]]; then
        read -p "Enter your Git email: " git_email
        git config --global user.email "$git_email"
    fi

    # Core Git configuration
    git config --global core.editor "nvim"
    git config --global core.autocrlf "input"
    git config --global core.fileMode true
    git config --global core.excludesfile "~/.gitignore_global"

    # Set default branch name
    git config --global init.defaultBranch master

    # Color settings
    git config --global color.ui true

    # Pull settings
    git config --global pull.rebase true
    git config --global pull.ff only

    # Push settings
    git config --global push.default current
    git config --global push.autoSetupRemote true

    # Rebase settings
    git config --global rebase.autoStash true

    # Delta configuration (better diff viewer)
    git config --global core.pager "delta"
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate true
    git config --global delta.light false
    git config --global delta.side-by-side true
    git config --global delta.line-numbers true

    git config --global merge.conflictstyle "diff3"
    git config --global diff.colorMoved "default"

    # Aliases
    git config --global alias.st "status -sb"
    git config --global alias.co "checkout"
    git config --global alias.cb "checkout -b"
    git config --global alias.cm "commit -m"
    git config --global alias.ca "commit --amend"
    git config --global alias.can "commit --amend --no-edit"
    git config --global alias.br "branch"
    git config --global alias.df "diff"
    git config --global alias.dfs "diff --staged"
    git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    git config --global alias.rs "reset"
    git config --global alias.rsh "reset --hard"
    git config --global alias.rss "reset --soft"
    git config --global alias.sl "stash list"
    git config --global alias.sa "stash apply"
    git config --global alias.ss "stash save"
    git config --global alias.sp "stash pop"
    git config --global alias.sshow "stash show -p"

    # Create global .gitignore
    cat > ~/.gitignore_global << 'EOL'
# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE specific files
.idea/
.vscode/
*.swp
*.swo
*~

# Node
node_modules/
npm-debug.log
yarn-debug.log
yarn-error.log

# Python
__pycache__/
*.py[cod]
*$py.class
.Python
.env
.venv
env/
venv/
ENV/

# Rust
target/
Cargo.lock
**/*.rs.bk

# Java
*.class
*.jar
*.war
*.ear
*.logs
*.iml

# Logs and databases
*.log
*.sql
*.sqlite

# Build output
dist/
build/
out/
EOL

    # Configure SSH for GitHub if not already set up
    if [[ ! -f ~/.ssh/id_ed25519 ]]; then
        log "Setting up SSH key for GitHub..."

        read -p "Enter your GitHub email: " github_email

        # Generate SSH key
        ssh-keygen -t ed25519 -C "$github_email" -f ~/.ssh/id_ed25519 -N ""

        # Start ssh-agent
        eval "$(ssh-agent -s)"

        # Add SSH key to ssh-agent
        ssh-add ~/.ssh/id_ed25519

        # Copy public key to clipboard
        pbcopy < ~/.ssh/id_ed25519.pub

        log "Your SSH public key has been copied to clipboard."
        log "Please add it to your GitHub account: https://github.com/settings/ssh/new"

        # Wait for user to confirm
        read -p "Press Enter after you've added the SSH key to GitHub..."

        # Test SSH connection
        ssh -T git@github.com || true
    fi

    log "Git setup completed successfully!"
    log "Your Git configuration:"
    git config --global --list
}

# Execute if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_and_configure_git
fi
