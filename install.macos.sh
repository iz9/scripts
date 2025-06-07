#!/bin/bash

# One-liner to run this:
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/iz9/scripts/refs/heads/master/install.macos.sh)"

# Create installation directory
INSTALL_DIR="$HOME/tmpinstall"
PROCESS_FILE="$INSTALL_DIR/process"

# Utility functions
log() {
    echo -e "\033[1;36m[SCRIPT:INFO] $1\033[0m"
}

error() {
    echo -e "\033[1;31m[SCRIPT:ERROR] $1\033[0m" >&2
}

command_exists() {
    command -v "$1" &>/dev/null
}

install_formula_or_upgrade() {
    local package=$1
    log "Installing/upgrading $package..."

    if brew list "$package" &>/dev/null; then
        if brew upgrade "$package" &>/dev/null; then
            log "$package upgraded successfully"
            return 0
        else
            error "Failed to upgrade $package"
            return 1
        fi
    else
        if brew install "$package" &>/dev/null; then
            log "$package installed successfully"
            return 0
        else
            error "Failed to install $package"
            return 1
        fi
    fi
}


install_cask_or_upgrade() {
    local package=$1
    log "Installing/upgrading $package..."

    if brew list --cask "$package" &>/dev/null; then
        if brew upgrade --cask "$package" &>/dev/null; then
            log "$package upgraded successfully"
            return 0
        else
            error "Failed to upgrade $package"
            return 1
        fi
    else
        if brew install --cask "$package" &>/dev/null; then
            log "$package installed successfully"
            return 0
        else
            error "Failed to install $package"
            return 1
        fi
    fi
}

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
        if ! install_formula_or_upgrade "$lib"; then
            error "Failed to install $lib"
            return 1
        fi
    done

    log "Development libraries installation completed."
}


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

install_chrome(){
  install_cask_or_upgrade google-chrome
  open -a "Google Chrome"
  echo
  echo "Please complete initial setup for chrome browser"
  read -p "Press Enter when you're ready to continue..."
  echo "Chrome set up"
}

install_and_configure_git() {
    log "Setting up Git and configurations..."

    # Install Git using Homebrew if not already installed
    if ! install_formula_or_upgrade git; then
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
        if ! install_formula_or_upgrade "$tool"; then
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

configure_shell() {
    log "Setting up Zsh and configurations..."

    # Install Zsh using the common function
    if ! install_formula_or_upgrade zsh; then
        error "Failed to install Zsh"
        return 1
    fi

    # Install Starship using Homebrew
    if ! install_formula_or_upgrade starship; then
        error "Failed to install Starship"
        return 1
    fi

    # Install Zsh plugins using Homebrew
    if ! install_formula_or_upgrade zsh-autosuggestions; then
        error "Failed to install zsh-autosuggestions"
        return 1
    fi

    if ! install_formula_or_upgrade zsh-syntax-highlighting; then
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
        if ! install_formula_or_upgrade "${tools[$i]}"; then
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
    create_cli_tools_shell_config

    log "CLI tools installation completed!"
    log "Please restart your shell or run 'source ~/.bashrc' (or ~/.zshrc) to apply changes."
}

create_cli_tools_shell_config() {
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

install_nvim() {
    log "Setting up Neovim and configurations..."

    # Install Neovim using Homebrew
    if ! install_formula_or_upgrade neovim; then
        error "Failed to install Neovim"
        return 1
    fi

    # Install dependencies
    local dependencies=(
        "ripgrep"
        "fd"
        "tree-sitter"
        "lazygit"
        "fzf"
    )

    for dep in "${dependencies[@]}"; do
        if ! install_formula_or_upgrade "$dep"; then
            error "Failed to install $dep"
            return 1
        fi
    done

    # Create Neovim config directory
    local nvim_config_dir="$HOME/.config/nvim"
    mkdir -p "$nvim_config_dir"

    # Install package manager (lazy.nvim)
    local lazy_path="$HOME/.local/share/nvim/lazy/lazy.nvim"
    if [ ! -d "$lazy_path" ]; then
        log "Installing lazy.nvim package manager..."
        mkdir -p "$(dirname "$lazy_path")"
        git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable "$lazy_path"
    fi

    # Create init.lua
    cat > "$nvim_config_dir/init.lua" << 'EOL'
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic options
vim.g.mapleader = " "  -- Set leader key to space
vim.g.maplocalleader = " "

-- Basic settings
vim.opt.number = true         -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.mouse = 'a'          -- Enable mouse support
vim.opt.ignorecase = true    -- Ignore case in search
vim.opt.smartcase = true     -- But don't ignore it when search string contains uppercase letters
vim.opt.hlsearch = false     -- Don't highlight all search results
vim.opt.wrap = false         -- Don't wrap lines
vim.opt.breakindent = true   -- Preserve indentation in wrapped text
vim.opt.tabstop = 4          -- Tab width
vim.opt.shiftwidth = 4       -- Indentation width
vim.opt.expandtab = true     -- Use spaces instead of tabs
vim.opt.termguicolors = true -- True color support

-- System clipboard
vim.opt.clipboard = 'unnamedplus'  -- Use system clipboard

-- Russian keyboard mappings
local russian_mappings = {
    ['й'] = 'q', ['ц'] = 'w', ['у'] = 'e', ['к'] = 'r', ['е'] = 't',
    ['н'] = 'y', ['г'] = 'u', ['ш'] = 'i', ['щ'] = 'o', ['з'] = 'p',
    ['х'] = '[', ['ъ'] = ']', ['ф'] = 'a', ['ы'] = 's', ['в'] = 'd',
    ['а'] = 'f', ['п'] = 'g', ['р'] = 'h', ['о'] = 'j', ['л'] = 'k',
    ['д'] = 'l', ['ж'] = ';', ['э'] = "'", ['ё'] = '\\',['я'] = 'z',
    ['ч'] = 'x', ['с'] = 'c', ['м'] = 'v', ['и'] = 'b', ['т'] = 'n',
    ['ь'] = 'm', ['б'] = ',', ['ю'] = '.',
    ['Й'] = 'Q', ['Ц'] = 'W', ['У'] = 'E', ['К'] = 'R', ['Е'] = 'T',
    ['Н'] = 'Y', ['Г'] = 'U', ['Ш'] = 'I', ['Щ'] = 'O', ['З'] = 'P',
    ['Х'] = '{', ['Ъ'] = '}', ['Ф'] = 'A', ['Ы'] = 'S', ['В'] = 'D',
    ['А'] = 'F', ['П'] = 'G', ['Р'] = 'H', ['О'] = 'J', ['Л'] = 'K',
    ['Д'] = 'L', ['Ж'] = ':', ['Э'] = '"', ['Я'] = 'Z', ['Ч'] = 'X',
    ['С'] = 'C', ['М'] = 'V', ['И'] = 'B', ['Т'] = 'N', ['Ь'] = 'M',
    ['Б'] = '<', ['Ю'] = '>', ['Ё'] = '|'
}

for rus, eng in pairs(russian_mappings) do
    vim.keymap.set({'n', 'v'}, rus, eng)
end

-- Basic keymaps
vim.keymap.set('n', '<leader>w', '<cmd>write<cr>', { desc = 'Save' })
vim.keymap.set('n', '<leader>q', '<cmd>quit<cr>', { desc = 'Quit' })
vim.keymap.set('n', '<leader>h', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlight' })

-- Plugin specifications
require("lazy").setup({
    -- Color scheme
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme tokyonight-night]])
        end,
    },

    -- File explorer
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        keys = {
            { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer" },
        },
    },

    -- Fuzzy finder
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-tree/nvim-web-devicons',
        },
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
        },
    },

    -- Status line
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = true,
    },

    -- Better syntax highlighting
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup({
                ensure_installed = { "lua", "vim", "bash", "python", "javascript", "typescript", "rust" },
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },

    -- LSP Support
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        dependencies = {
            {'neovim/nvim-lspconfig'},
            {'williamboman/mason.nvim'},
            {'williamboman/mason-lspconfig.nvim'},
            {'hrsh7th/nvim-cmp'},
            {'hrsh7th/cmp-buffer'},
            {'hrsh7th/cmp-path'},
            {'saadparwaiz1/cmp_luasnip'},
            {'hrsh7th/cmp-nvim-lsp'},
            {'hrsh7th/cmp-nvim-lua'},
            {'L3MON4D3/LuaSnip'},
            {'rafamadriz/friendly-snippets'},
        },
        config = function()
            local lsp_zero = require('lsp-zero')
            lsp_zero.on_attach(function(client, bufnr)
                lsp_zero.default_keymaps({buffer = bufnr})
            end)

            require('mason').setup({})
            require('mason-lspconfig').setup({
                ensure_installed = { 'lua_ls', 'rust_analyzer', 'pyright' },
                handlers = {
                    lsp_zero.default_setup,
                },
            })
        end,
    },

    -- Git signs in the gutter
    {
        'lewis6991/gitsigns.nvim',
        config = true,
    },

    -- copy text highlight
    {
        "machakann/vim-highlightedyank",
        event = "VeryLazy",
    },

    -- code commentary
    {
        "numToStr/Comment.nvim",
        event = "VeryLazy",
        config = function()
            require('Comment').setup()
        end,
        keys = {
            { "gcc", mode = "n", desc = "Comment toggle current line" },
            { "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
            { "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
        },
    },

    -- enhanced navigation
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
            { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
            { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
            { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
        },
    },

    -- fast string navigation
    {
        "jinh0/eyeliner.nvim",
        event = "VeryLazy",
        config = function()
            require('eyeliner').setup({
                highlight_on_key = true,
                dim = true,
            })
        end,
    },
})

-- yanked highlight
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank({ timeout = 300 })
    end,
})
EOL

    log "Neovim setup completed. Please run ':Lazy sync' in Neovim to install plugins."
}


install_wezterm() {
    log "Installing WezTerm..."

    # Check if fonts are installed
    check_required_fonts

    # Install WezTerm via Homebrew
    if ! install_formula_or_upgrade wezterm; then
        error "Failed to install WezTerm"
        exit 1
    fi

    setup_wezterm_config
    log "WezTerm installation and configuration completed!"
    log "Please restart your terminal or source your shell configuration file."
}

check_required_fonts() {
    local required_fonts=(
        "font-jetbrains-mono-nerd-font"
        "font-jetbrains-mono"
        "font-symbols-only-nerd-font"
    )

    local missing_fonts=()

    for font in "${required_fonts[@]}"; do
        if ! brew list --cask | grep -q "$font"; then
            missing_fonts+=("$font")
        fi
    done

    if [ ${#missing_fonts[@]} -ne 0 ]; then
        error "Required fonts are missing. Please install them first using install_fonts.sh:"
        for font in "${missing_fonts[@]}"; do
            echo "  - $font"
        done
        exit 1
    fi
}

setup_wezterm_config() {
    local config_dir="$HOME/.config/wezterm"
    mkdir -p "$config_dir"

    cat > "$config_dir/wezterm.lua" << 'EOL'
local wezterm = require 'wezterm'
local act = wezterm.action

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Settings
config.color_scheme = 'Tokyo Night'
config.font = wezterm.font_with_fallback({
  { family = 'JetBrainsMono Nerd Font', weight = 'Medium' },
  'JetBrains Mono',
  'Symbols Nerd Font Mono',
})
config.font_size = 12.0
config.line_height = 1.2
config.cell_width = 1.0
config.freetype_load_target = 'Light'
config.freetype_render_target = 'HorizontalLcd'

-- Window appearance
config.window_padding = {
  left = '1cell',
  right = '1cell',
  top = '0.5cell',
  bottom = '0.5cell',
}
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_max_width = 32
config.show_tab_index_in_tab_bar = false
config.switch_to_last_active_tab_when_closing_tab = true

-- General Settings
config.automatically_reload_config = true
config.scrollback_lines = 10000
config.enable_scroll_bar = false
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = 'Linear'
config.cursor_blink_ease_out = 'Linear'
config.animation_fps = 60
config.max_fps = 60

-- Keys
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
  { key = 'a', mods = 'LEADER|CTRL', action = act.SendString '\x01' },

  -- Pane keybindings
  { key = '=', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
  { key = 'c', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },

  -- Tab keybindings
  { key = 't', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'LEADER', action = act.CloseCurrentTab { confirm = true } },
  { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },

  -- Pane navigation
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },

  -- Pane resizing
  { key = 'H', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'J', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Down', 5 } },
  { key = 'K', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Up', 5 } },
  { key = 'L', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Right', 5 } },

  -- Copy mode
  { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },
  { key = ']', mods = 'LEADER', action = act.PasteFrom 'Clipboard' },

  -- Quick select mode
  { key = 's', mods = 'LEADER', action = act.QuickSelect },

  -- Clipboard
  { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'ClipboardAndPrimarySelection' },
}

-- Mouse bindings
config.mouse_bindings = {
  -- Change the default click behavior so that it populates
  -- the Clipboard rather than PrimarySelection.
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'Clipboard',
  },
  {
    event = { Up = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = act.PasteFrom 'Clipboard',
  },
  -- Triple click selects the entire line
  {
    event = { Up = { streak = 3, button = 'Left' } },
    mods = 'NONE',
    action = act.SelectTextAtMouseCursor 'Line',
  },
}

-- Custom hyperlinks
config.hyperlink_rules = wezterm.default_hyperlink_rules()
-- make username/project paths clickable. this implies paths like the following are for github.
-- ( "nvim-treesitter/nvim-treesitter" | wbthomason/packer.nvim | ... )
table.insert(config.hyperlink_rules, {
  regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
  format = 'https://github.com/$1/$3',
})

return config
EOL

    # Create directory for custom colorschemes if needed
    mkdir -p "$config_dir/colors"

    log "WezTerm configuration created at ~/.config/wezterm/wezterm.lua"

    # Create startup script
    create_wezterm_startup_script
}

create_wezterm_startup_script() {
    local bin_dir="$HOME/.local/bin"
    mkdir -p "$bin_dir"

    cat > "$bin_dir/wezterm-start" << 'EOL'
#!/bin/bash

# Function to check if WezTerm is running
is_wezterm_running() {
    pgrep -f wezterm >/dev/null
}

# Function to activate WezTerm window
activate_wezterm() {
    if command -v osascript >/dev/null; then
        osascript -e 'tell application "WezTerm" to activate'
    fi
}

# Start or focus WezTerm
if is_wezterm_running; then
    activate_wezterm
else
    wezterm start --always-new-process
fi
EOL

    chmod +x "$bin_dir/wezterm-start"

    # Add bin directory to PATH if needed
    for rc in ~/.bashrc ~/.zshrc; do
        if [[ -f "$rc" ]]; then
            if ! grep -q "$HOME/.local/bin" "$rc"; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
            fi
        fi
    done

    log "Created WezTerm startup script at ~/.local/bin/wezterm-start"
}


install_asdf_and_languages() {
    log "Setting up asdf version manager..."

    # Install or upgrade asdf
    if ! command_exists asdf; then
        log "Installing asdf..."

        brew install asdf
        export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

        mkdir -p "${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
        asdf completion zsh > "${ASDF_DATA_DIR:-$HOME/.asdf}/completions/_asdf"
        # append completions to fpath
        fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
        # initialise completions with ZSH's compinit
        autoload -Uz compinit && compinit

        # Source asdf in current session
        . "$HOME/.asdf/asdf.sh"
    else
        log "Updating asdf..."
        asdf update
    fi

    # Define languages and their versions using parallel arrays
    LANGS=(
        "ruby"
        "nodejs"
        "python"
        "golang"
        "rust"
    )

    VERSIONS=(
        "3.2.2"
        "latest"
        "latest"
        "latest"
        "latest"
    )

    # Install plugins and languages
    local i
    for i in "${!LANGS[@]}"; do
        lang="${LANGS[$i]}"
        version="${VERSIONS[$i]}"

        log "Setting up $lang $version..."

        # Add plugin if not exists
        if ! asdf plugin list | grep -q "^$lang$"; then
            log "Adding $lang plugin..."
            asdf plugin add "$lang"
        else
            log "Updating $lang plugin..."
            asdf plugin update "$lang"
        fi

        echo -e "\n# Golang environment setup\n. \${ASDF_DATA_DIR:-\$HOME/.asdf}/plugins/golang/set-env.zsh" >> ~/.zshrc

        # Install language version
        if ! asdf list "$lang" | grep -q "^$version$"; then
            log "Installing $lang $version..."
            asdf install "$lang" "$version"

            if [ $? -ne 0 ]; then
                error "Failed to install $lang $version"
                continue
            fi
        else
            log "$lang $version is already installed"
        fi

        # Set global version
        log "Setting $lang $version as global..."
        asdf set -u "$lang" "$version"
    done

    asdf current

    log "asdf and languages setup completed."
}

install_mas_app() {
    local app_id=$1
    local app_name=$2

    echo "----------------------------------------"
    echo "Installing $app_name..."
    echo "App Store link:"
    mas info "$app_id"

    read -p "Please install $app_name from the App Store and press Enter when done..."

    if ! mas list | grep -q "^$app_id"; then
        echo "Warning: $app_name ($app_id) does not appear to be installed!"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    else
        echo "✓ $app_name is installed"
    fi
    return 0
}

install_mas_apps() {
    echo "Starting Mac App Store applications installation..."

    # Check for mas-cli
      if ! command -v mas &> /dev/null; then
          echo "mas-cli is not installed. Installing..."
          if ! brew install mas; then
              echo "Error: Failed to install mas-cli"
              return 1
          fi
          echo "mas-cli installed successfully"
      else
          echo "mas-cli is already installed"
      fi


    # Array of apps with their IDs and names
    declare -A apps=(
        [497799835]="Xcode"
        [937984704]="Amphetamine"
        [1388020431]="DevCleaner"
        [595191960]="CopyClip"
        [1339170533]="CleanMyMac"
    )

    # Install each app
    local failed_apps=()
    for app_id in "${!apps[@]}"; do
        if ! install_mas_app "$app_id" "${apps[$app_id]}"; then
            failed_apps+=("${apps[$app_id]}")
        fi
    done

    echo "----------------------------------------"
    echo "Mac App Store applications installation completed!"

    # Report failed installations if any
    if [ ${#failed_apps[@]} -ne 0 ]; then
        echo "The following apps were not confirmed as installed:"
        printf '%s\n' "${failed_apps[@]}"
        return 1
    fi

    return 0
}

install_gui_apps() {
    log "Starting GUI applications installation..."

    CASKS=(
        "jetbrains-toolbox"
        "ticktick"
        "telegram"
        "obsidian"
        "commander-one"
        "readdle-spark"
        "kap"
        "openvpn-connect"
        "slack"
        "zoom"
        "firefox"
    )

    local i
    for i in "${!CASKS[@]}"; do
        cask="${CASKS[$i]}"

        # Install application
        if ! install_cask_or_upgrade "$cask"; then
            error "Failed to install $cask"
            ask_continue
            continue
        fi

        # Wait for user confirmation
        echo
        echo "Please complete initial setup for $cask"
        echo "1. Configure the application according to your preferences"
        echo "2. Once done, close the application"
        read -p "Press Enter when you're ready to continue with the next application..."

        log "$cask installation and configuration completed!"
        echo
    done

    log "All GUI applications have been installed and configured!"
}

ask_continue() {
    read -p "Would you like to continue with the remaining applications? (y/n) " answer
    case "$answer" in
        [Yy]*)
            return 0
            ;;
        *)
            log "Installation aborted by user"
            exit 1
            ;;
    esac
}

# Create directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Check if Homebrew is already installed
if grep -q "homebrew_installed=true" "$PROCESS_FILE" 2>/dev/null; then
    log "Homebrew installation found, continue installation..."

    install_rosetta

    install_dev_libs

    install_fonts

    install_chrome

    install_and_configure_git

    configure_shell

    install_cli_tools

    install_nvim

    install_wezterm

    install_asdf_and_languages

    install_mas_apps

    install_gui_apps

else
    # First run - install Homebrew
    log "Starting Homebrew installation..."

    export PATH="/opt/homebrew/bin:$PATH"
    # Install Homebrew
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        # Mark Homebrew installation as completed
        echo "homebrew_installed=true" >> "$PROCESS_FILE"

        # configure Homebrew for current user
        echo >> "$HOME/.zprofile"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        eval "$(/opt/homebrew/bin/brew shellenv)"


        echo "======================================"
        echo "Homebrew installation completed!"
        echo "======================================"
        echo "Please open a new terminal tab and run:"
        echo -e "\033[1m/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/iz9/scripts/refs/heads/master/install.macos.sh)\"\033[0m"
        echo "======================================"
        exit 0
    else
        error "Homebrew installation failed"
        exit 1
    fi
fi

cd "$HOME"

rm -rf "$INSTALL_DIR"

log "COMPLETED!"
