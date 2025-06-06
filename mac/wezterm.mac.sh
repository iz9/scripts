#!/bin/bash

# Import utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.ios.sh"

install_wezterm() {
    log "Installing WezTerm..."

    # Check if fonts are installed
    check_required_fonts

    # Install WezTerm via Homebrew
    if ! install_brew_or_upgrade wezterm; then
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

# Execute if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_wezterm
fi
