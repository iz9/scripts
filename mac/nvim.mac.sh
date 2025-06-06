#!/bin/bash

# Import utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.mac.sh"

nvim() {
    log "Setting up Neovim and configurations..."

    # Install Neovim using Homebrew
    if ! install_brew_or_upgrade neovim; then
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
        if ! install_brew_or_upgrade "$dep"; then
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

# Execute if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    nvim
fi
