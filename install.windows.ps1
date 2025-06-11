# Windows Software Installation and Configuration Script
# Run as Administrator for best results

Write-Host "=== Windows Software Installation and Configuration ===" -ForegroundColor Cyan
Write-Host ""

# -------------------- Scoop Installation Prompt --------------------
Write-Host "⚠️  IMPORTANT: Scoop Installation Required" -ForegroundColor Yellow
Write-Host ""
Write-Host "Before running this script, you need to install Scoop (NOT as administrator)." -ForegroundColor Cyan
Write-Host "Please open a regular PowerShell window (not as admin) and run:" -ForegroundColor White
Write-Host ""
Write-Host "    irm get.scoop.sh | iex" -ForegroundColor Green
Write-Host ""
Write-Host "After Scoop is installed, come back and run this script as administrator." -ForegroundColor Cyan
Write-Host ""

$scoopInstalled = Get-Command scoop -ErrorAction SilentlyContinue
if (-not $scoopInstalled) {
    $continue = Read-Host "Scoop is not detected. Do you want to continue anyway? (y/N)"
    if ($continue -ne 'y' -and $continue -ne 'Y') {
        Write-Host "Please install Scoop first, then run this script again." -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "✅ Scoop is already installed!" -ForegroundColor Green
    Write-Host ""
}

# -------------------- Install Chocolatey --------------------
function Install-Chocolatey {
    Write-Host "Step 1: Installing Chocolatey..." -ForegroundColor Yellow

    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Chocolatey is already installed." -ForegroundColor Green
        return
    }

    Write-Host "Installing Chocolatey package manager..." -ForegroundColor Cyan
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    Write-Host "Chocolatey installed successfully!" -ForegroundColor Green
}

# -------------------- Configure Scoop --------------------
function Configure-Scoop {
    Write-Host "`nStep 5: Configuring Scoop buckets..." -ForegroundColor Yellow

    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Warning "Scoop is not available, skipping Scoop configuration"
        return
    }

    Write-Host "Adding useful Scoop buckets..." -ForegroundColor Cyan

    # Add buckets with error handling
    try {
        scoop bucket add extras
        Write-Host "✅ Added 'extras' bucket" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to add 'extras' bucket: $_"
    }

    try {
        scoop bucket add versions
        Write-Host "✅ Added 'versions' bucket" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to add 'versions' bucket: $_"
    }

    try {
        scoop bucket add nerd-fonts
        Write-Host "✅ Added 'nerd-fonts' bucket" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to add 'nerd-fonts' bucket: $_"
    }

    Write-Host "Scoop buckets configuration completed!" -ForegroundColor Green
}

# -------------------- Install Fonts --------------------
function Install-Fonts {
    Write-Host "`nStep 6: Installing fonts..." -ForegroundColor Yellow

    Write-Host "Installing JetBrains Mono Nerd Font..." -ForegroundColor Cyan
    choco install nerd-fonts-jetbrainsmono -y

    if ($LASTEXITCODE -eq 0) {
        Write-Host "JetBrains Mono Nerd Font installed successfully!" -ForegroundColor Green
    } else {
        Write-Warning "JetBrains Mono Nerd Font installation may have encountered issues."
    }
}

# -------------------- Install Essential Applications --------------------
function Install-EssentialApplications {
    Write-Host "`nStep 7: Installing essential applications..." -ForegroundColor Yellow

    $essentialApps = @(
        "jetbrainstoolbox",
        "7zip",
        "anydesk",
        "telegram",
        "obsidian",
        "sparkmail",
        "openvpn-connect",
        "zoom",
        "slack",
        "firefox"
    )

    foreach ($app in $essentialApps) {
        Write-Host "Installing $app..." -ForegroundColor Cyan
        choco install $app -y

        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Failed to install $app via Chocolatey"
        } else {
            Write-Host "$app installed successfully!" -ForegroundColor Green
        }
    }

    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    Write-Host "Essential applications installation completed!" -ForegroundColor Green
}

# -------------------- Install CLI Tools via Chocolatey --------------------
function Install-ChocolateyTools {
    Write-Host "`nStep 8: Installing CLI tools via Chocolatey..." -ForegroundColor Yellow

    $chocoTools = @(
        "fzf",
        "ripgrep",
        "bat",
        "navi",
        "zoxide",
        "wget",
        "curl",
        "fd",
        "jq",
        "tree",
        "ncdu",
        "httpie",
        "duf"
    )

    foreach ($tool in $chocoTools) {
        Write-Host "Installing $tool..." -ForegroundColor Cyan
        choco install $tool -y

        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Failed to install $tool via Chocolatey"
        } else {
            Write-Host "$tool installed successfully!" -ForegroundColor Green
        }
    }

    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# -------------------- Install CLI Tools via Scoop --------------------
function Install-ScoopTools {
    Write-Host "`nStep 9: Installing CLI tools via Scoop..." -ForegroundColor Yellow

    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Warning "Scoop is not available, skipping Scoop tools installation"
        return
    }

    $scoopTools = @(
        "eza",
        "btop",
        "tlrc",
        "doggo",
        "ntop"
    )

    foreach ($tool in $scoopTools) {
        Write-Host "Installing $tool..." -ForegroundColor Cyan
        scoop install $tool

        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Failed to install $tool via Scoop"
        } else {
            Write-Host "$tool installed successfully!" -ForegroundColor Green
        }
    }

    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# -------------------- Install WezTerm --------------------
function Install-WezTerm {
    Write-Host "`nStep 10: Installing WezTerm..." -ForegroundColor Yellow

    choco install wezterm -y

    if ($LASTEXITCODE -eq 0) {
        Write-Host "WezTerm installed successfully!" -ForegroundColor Green
    } else {
        Write-Warning "WezTerm installation may have encountered issues."
    }

    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# -------------------- Configure WezTerm --------------------
function Configure-WezTerm {
    Write-Host "Configuring WezTerm..." -ForegroundColor Cyan

    # Create .config directory if it doesn't exist
    $configDir = Join-Path $HOME ".config"
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir | Out-Null
    }

    # Create wezterm directory
    $weztermConfigDir = Join-Path $configDir "wezterm"
    if (-not (Test-Path $weztermConfigDir)) {
        New-Item -ItemType Directory -Path $weztermConfigDir | Out-Null
    }

    $weztermConfigPath = Join-Path $weztermConfigDir "wezterm.lua"

    $weztermConfig = @"
local wezterm = require 'wezterm'
local act = wezterm.action

local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Default shell
config.default_prog = { 'powershell.exe' }

-- Font configuration
config.font = wezterm.font('JetBrains Mono')
config.font_size = 12.0
config.line_height = 1.2
config.cell_width = 1.0
config.freetype_load_target = 'Light'
config.freetype_render_target = 'HorizontalLcd'

-- Color scheme
config.color_scheme = 'Tokyo Night'

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
  format = 'https://github.com/`$1/`$3',
})

return config
"@

    $weztermConfig | Out-File -FilePath $weztermConfigPath -Encoding UTF8
    Write-Host "WezTerm config created at: $weztermConfigPath" -ForegroundColor Green
}

# -------------------- Install Google Chrome --------------------
function Install-Chrome {
    Write-Host "`nStep 2: Installing Google Chrome..." -ForegroundColor Yellow

    choco install googlechrome -y

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Google Chrome installed successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Please configure Chrome as needed (sign in, set preferences, etc.)" -ForegroundColor Cyan
        Read-Host "Press <Enter> when you're done configuring Chrome"
    } else {
        Write-Warning "Chrome installation may have encountered issues."
    }
}

# -------------------- Install Git --------------------
function Install-Git {
    Write-Host "`nStep 3: Installing Git..." -ForegroundColor Yellow

    choco install git -y

    # Refresh environment variables after Git installation
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Git installed successfully!" -ForegroundColor Green
    } else {
        Write-Warning "Git installation may have encountered issues."
    }
}

# -------------------- Install Starship --------------------
function Install-Starship {
    Write-Host "`nStep 11: Installing Starship prompt..." -ForegroundColor Yellow

    if (Get-Command starship -ErrorAction SilentlyContinue) {
        Write-Host "Starship is already installed." -ForegroundColor Green
        return
    }

    choco install starship -y

    # Refresh environment variables after Starship installation
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Starship installed successfully!" -ForegroundColor Green
    } else {
        Write-Warning "Starship installation may have encountered issues."
    }
}

# -------------------- Configure CLI Tools --------------------
function Configure-CLITools {
    Write-Host "Configuring CLI tools..." -ForegroundColor Cyan

    # Create ripgrep config
    $ripgrepConfigPath = Join-Path $HOME ".ripgreprc"
    if (-not (Test-Path $ripgrepConfigPath)) {
        $ripgrepConfig = @"
--smart-case
--hidden
--glob=!.git/*
--max-columns=150
--max-columns-preview
"@
        $ripgrepConfig | Out-File -FilePath $ripgrepConfigPath -Encoding UTF8
        Write-Host "Ripgrep config created at: $ripgrepConfigPath" -ForegroundColor Green
    }

    # Set environment variables for current session
    $env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'
    $env:FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border --info=inline'
    $env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND
    $env:FZF_ALT_C_COMMAND = 'fd --type d --hidden --follow --exclude .git'
    $env:BAT_THEME = "TwoDark"
    $env:BAT_STYLE = "numbers,changes,header"
    $env:RIPGREP_CONFIG_PATH = $ripgrepConfigPath

    Write-Host "CLI tools configured for current session." -ForegroundColor Green
}

# -------------------- Configure Starship --------------------
function Configure-Starship {
    Write-Host "Configuring Starship prompt..." -ForegroundColor Cyan

    # Create .config directory if it doesn't exist
    $configDir = Join-Path $HOME ".config"
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir | Out-Null
    }

    $starshipConfigPath = Join-Path $configDir "starship.toml"

    $starshipConfig = @"
# Wait 10 milliseconds for starship to check files under the current directory.
scan_timeout = 10

# Use custom format
format = """
`$username\
`$hostname\
`$directory\
`$git_branch\
`$git_status\
`$cmd_duration\
`$line_break\
`$python\
`$nodejs\
`$character"""

[directory]
style = "blue bold"
truncate_to_repo = true
truncation_length = 3

[character]
success_symbol = "[>](purple)"
error_symbol = "[>](red)"
vimcmd_symbol = "[<](green)"

[git_branch]
format = "[`$branch](`$style)"
style = "bright-black"

[git_status]
format = "[[(*`$conflicted`$untracked`$modified`$staged`$renamed`$deleted)](218) (`$ahead_behind`$stashed)](`$style)"
style = "cyan"
conflicted = "!"
untracked = "?"
modified = "M"
staged = "+"
renamed = "R"
deleted = "D"
stashed = "="

[git_state]
format = '\([`$state( `$progress_current/`$progress_total)](`$style)\) '
style = "bright-black"

[cmd_duration]
format = "[`$duration](`$style) "
style = "yellow"

[python]
format = '[`${symbol}`${pyenv_prefix}(`${version} )(\(`$virtualenv\) )](`$style)'
symbol = "Py "
style = "yellow bold"

[nodejs]
format = '[`${symbol}(`${version} )](`$style)'
symbol = "Node "
style = "green bold"
"@

    $starshipConfig | Out-File -FilePath $starshipConfigPath -Encoding UTF8
    Write-Host "Starship config created at: $starshipConfigPath" -ForegroundColor Green
    Write-Host "Note: Using Windows-compatible symbols for better display" -ForegroundColor Cyan
}

# -------------------- Configure PowerShell Profile --------------------
function Configure-PowerShellProfile {
    Write-Host "Configuring PowerShell profile..." -ForegroundColor Cyan

    # Ensure profile directory exists
    $profileDir = Split-Path $PROFILE -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        Write-Host "Created profile directory: $profileDir" -ForegroundColor Gray
    }

    # Create profile file if it doesn't exist
    if (-not (Test-Path $PROFILE)) {
        New-Item -ItemType File -Path $PROFILE -Force | Out-Null
        Write-Host "Created profile file: $PROFILE" -ForegroundColor Gray
    }

    # Read existing profile content
    $existingContent = ""
    if (Test-Path $PROFILE) {
        try {
            $existingContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
            if ($null -eq $existingContent) { $existingContent = "" }
        } catch {
            $existingContent = ""
        }
    }

    $profileConfig = @"

# ==================== CLI Tools Configuration ====================

# Environment Variables
`$env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'
`$env:FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border --info=inline'
`$env:FZF_CTRL_T_COMMAND = `$env:FZF_DEFAULT_COMMAND
`$env:FZF_ALT_C_COMMAND = 'fd --type d --hidden --follow --exclude .git'
`$env:BAT_THEME = "TwoDark"
`$env:BAT_STYLE = "numbers,changes,header"
`$env:RIPGREP_CONFIG_PATH = "`$HOME\.ripgreprc"

# ==================== Aliases ====================

# Basic replacements
Set-Alias -Name cat -Value bat -Option AllScope
Set-Alias -Name find -Value fd -Option AllScope
Set-Alias -Name grep -Value rg -Option AllScope
Set-Alias -Name help -Value tlrc -Option AllScope
Set-Alias -Name tldr -Value tlrc -Option AllScope

# Modern replacements with fallback
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ls { eza --icons @args }
    function ll { eza -l --icons --git @args }
    function la { eza -la --icons --git @args }
    function lt { eza --tree --icons @args }
    function l. { eza -d .* --icons @args }
} else {
    function ll { Get-ChildItem -Force @args }
    function la { Get-ChildItem -Force @args }
}

if (Get-Command duf -ErrorAction SilentlyContinue) {
    Set-Alias -Name du -Value duf -Option AllScope
}

if (Get-Command btop -ErrorAction SilentlyContinue) {
    Set-Alias -Name top -Value btop -Option AllScope
}

if (Get-Command ntop -ErrorAction SilentlyContinue) {
    Set-Alias -Name htop -Value ntop -Option AllScope
}

if (Get-Command doggo -ErrorAction SilentlyContinue) {
    Set-Alias -Name ping -Value doggo -Option AllScope
}

# Directory navigation
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }
function ..... { Set-Location ..\..\..\.. }

# Enhanced aliases
function https { http --default-scheme=https @args }
function dirsize { Get-ChildItem @args | Measure-Object -Property Length -Sum | Select-Object @{Name="Size(MB)";Expression={[math]::Round(`$_.Sum/1MB,2)}} }
function treeg { tree -a -I ".git|node_modules|.DS_Store" @args }
function pf { Get-Process | Where-Object { `$_.ProcessName -like "*`$args*" } }
function disk { duf @args }
function space { ncdu @args }
function ports { netstat -an @args }

# ==================== Functions ====================

# Create and enter directory
function mkcd {
    param([string]`$Path)
    if (`$Path) {
        New-Item -ItemType Directory -Path `$Path -Force | Out-Null
        Set-Location `$Path
    } else {
        Write-Host "Usage: mkcd <directory_name>" -ForegroundColor Yellow
    }
}

# Remove file or directory recursivelly
function rm {
    param (
        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string[]] $Paths
    )
    Remove-Item -Path $Paths -Recurse -Force
}

# Extract various archive types
function extract {
    param([string]`$File)

    if (-not (Test-Path `$File)) {
        Write-Host "'`$File' is not a valid file" -ForegroundColor Red
        return
    }

    switch ([System.IO.Path]::GetExtension(`$File).ToLower()) {
        ".zip" { Expand-Archive -Path `$File -DestinationPath . }
        ".7z" { & 7z x `$File }
        ".rar" { & unrar x `$File }
        ".tar" { tar xf `$File }
        ".gz" {
            if (`$File -like "*.tar.gz") { tar xzf `$File }
            else { gzip -d `$File }
        }
        ".bz2" {
            if (`$File -like "*.tar.bz2") { tar xjf `$File }
            else { bzip2 -d `$File }
        }
        default { Write-Host "'`$File' cannot be extracted via extract()" -ForegroundColor Red }
    }
}

# Search command history with fzf
function fh {
    if (Get-Command fzf -ErrorAction SilentlyContinue) {
        `$command = Get-History | ForEach-Object { `$_.CommandLine } | fzf +s --tac
        if (`$command) {
            Invoke-Expression `$command
        }
    } else {
        Write-Host "fzf is not installed" -ForegroundColor Red
    }
}

# Kill process with fzf
function fkill {
    param([string]`$Signal = "9")

    if (Get-Command fzf -ErrorAction SilentlyContinue) {
        `$process = Get-Process | ForEach-Object { "`$(`$_.Id) `$(`$_.ProcessName) `$(`$_.Description)" } | fzf -m
        if (`$process) {
            `$pid = (`$process -split ' ')[0]
            Stop-Process -Id `$pid -Force
            Write-Host "Killed process `$pid" -ForegroundColor Green
        }
    } else {
        Write-Host "fzf is not installed" -ForegroundColor Red
    }
}

# Initialize zoxide if available
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# Initialize Starship prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

Write-Host "CLI tools configuration loaded!" -ForegroundColor Green
"@

    # Check if our configuration is already in the profile
    if ($existingContent -notmatch "CLI Tools Configuration") {
        try {
            # Force write the configuration using Out-File to ensure it's written
            $profileConfig | Out-File -FilePath $PROFILE -Append -Encoding UTF8 -Force
            Write-Host "✅ CLI tools configuration added to PowerShell profile: $PROFILE" -ForegroundColor Green

            # Verify the content was written
            $verifyContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
            if ($verifyContent -and $verifyContent.Contains("CLI Tools Configuration")) {
                Write-Host "✅ Profile configuration verified successfully!" -ForegroundColor Green
            } else {
                Write-Warning "Profile may not have been written correctly. Attempting alternative method..."

                # Alternative method using Add-Content
                Add-Content -Path $PROFILE -Value $profileConfig -Encoding UTF8 -Force
                Write-Host "✅ Used alternative method to write profile" -ForegroundColor Green
            }

        } catch {
            Write-Warning "Error writing to profile: $_"
            Write-Host "Attempting to write profile using alternative method..." -ForegroundColor Yellow

            try {
                # Fallback method
                $profileConfig | Add-Content -Path $PROFILE -Encoding UTF8
                Write-Host "✅ Profile written using fallback method" -ForegroundColor Green
            } catch {
                Write-Error "Failed to write PowerShell profile: $_"
                Write-Host "Manual intervention required. Profile path: $PROFILE" -ForegroundColor Red
                return
            }
        }

        # Apply configuration to current session immediately
        try {
            Write-Host "Applying configuration to current session..." -ForegroundColor Cyan
            . $PROFILE
            Write-Host "✅ Configuration applied to current session!" -ForegroundColor Green
        } catch {
            Write-Warning "Could not apply configuration to current session: $_"
            Write-Host "Please restart PowerShell or run '. `$PROFILE' manually" -ForegroundColor Yellow
        }

    } else {
        Write-Host "CLI tools configuration already exists in PowerShell profile." -ForegroundColor Gray

        # Still try to apply it to current session
        try {
            . $PROFILE
            Write-Host "✅ Existing configuration applied to current session!" -ForegroundColor Green
        } catch {
            Write-Warning "Could not apply existing configuration: $_"
        }
    }

    # Final verification
    Write-Host ""
    Write-Host "Profile Configuration Summary:" -ForegroundColor Cyan
    Write-Host "  Profile Path: $PROFILE" -ForegroundColor White
    Write-Host "  Profile Exists: $(Test-Path $PROFILE)" -ForegroundColor White

    if (Test-Path $PROFILE) {
        $profileSize = (Get-Item $PROFILE).Length
        Write-Host "  Profile Size: $profileSize bytes" -ForegroundColor White

        if ($profileSize -gt 0) {
            Write-Host "  ✅ Profile appears to have content" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  Profile file is empty!" -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host "To activate aliases in new PowerShell sessions:" -ForegroundColor Yellow
    Write-Host "  - Restart PowerShell, or" -ForegroundColor White
    Write-Host "  - Run: . `$PROFILE" -ForegroundColor White
}

# -------------------- Create Global .gitignore --------------------
function Create-GlobalGitignore {
    $gitignoreGlobalPath = Join-Path $HOME ".gitignore_global"

    if (Test-Path $gitignoreGlobalPath) {
        Write-Host "Global .gitignore already exists - skipping creation." -ForegroundColor Gray
        return
    }

    Write-Host "Creating global .gitignore file..." -ForegroundColor Cyan

    $gitignoreContent = @"
# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
Desktop.ini

# Windows
*.tmp
*.temp
*.log
*.swp
*.swo
*~

# IDEs and editors
.vscode/
.idea/
*.sublime-project
*.sublime-workspace
.vs/
.vscode-test/
*.code-workspace

# Temporary files
*.tmp
*.temp
*.bak
*.backup
*~

# Compiled files
*.com
*.class
*.dll
*.exe
*.o
*.so

# Archives
*.7z
*.dmg
*.gz
*.iso
*.jar
*.rar
*.tar
*.zip

# Logs
*.log
logs/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov

# nyc test coverage
.nyc_output

# Dependency directories
node_modules/
jspm_packages/

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Miscellaneous
.sass-cache/
.connect-temp/
.connect-lock/
.tmp/
.temp/

# JetBrains
.idea/
*.iml
*.ipr
*.iws

# Visual Studio
.vs/
bin/
obj/
*.user
*.suo
*.userosscache
*.sln.docstates

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual environments
venv/
env/
ENV/
.venv/

# Jupyter Notebook
.ipynb_checkpoints

# pyenv
.python-version

# Java
*.class
*.jar
*.war
*.ear
*.zip
*.tar.gz
*.rar
target/
*.iml
.idea/

# C/C++
*.o
*.a
*.so
*.exe
*.out
*.app

# Go
*.exe
*.exe~
*.dll
*.so
*.dylib
*.test
vendor/

# Rust
target/
Cargo.lock

# Ruby
*.gem
*.rbc
/.config
/coverage/
/InstalledFiles
/pkg/
/spec/reports/
/spec/examples.txt
/test/tmp/
/test/version_tmp/
/tmp/
.bundle/
vendor/bundle
lib/bundler/man

# PHP
/vendor/
composer.phar
composer.lock
.env

# Database
*.db
*.sqlite
*.sqlite3

# Security
*.pem
*.key
*.crt
*.p12
*.pfx
secrets.yml
secrets.yaml
"@

    $gitignoreContent | Out-File -FilePath $gitignoreGlobalPath -Encoding UTF8
    Write-Host "Global .gitignore created at: $gitignoreGlobalPath" -ForegroundColor Green
}

# -------------------- Ensure delta is installed --------------------
function Ensure-Delta {
    if (!(Get-Command delta -ErrorAction SilentlyContinue)) {
        Write-Host "delta not found - installing via Chocolatey..." -ForegroundColor Yellow
        if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
            Write-Warning "Chocolatey is not installed; skipping delta installation."
            return
        }
        choco install delta -y
    }
}

# -------------------- Apply Git config --------------------
function Set-GitConfig {
    Write-Host "Applying Git configuration..." -ForegroundColor Cyan

    git config --global core.editor "nvim"
    git config --global core.autocrlf "input"
    git config --global core.fileMode true
    git config --global core.excludesfile "$HOME/.gitignore_global"

    git config --global init.defaultBranch master
    git config --global color.ui true

    git config --global pull.rebase true
    git config --global pull.ff only

    git config --global push.default current
    git config --global push.autoSetupRemote true

    git config --global rebase.autoStash true

    git config --global core.pager "delta"
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate true
    git config --global delta.light false
    git config --global delta.side-by-side true
    git config --global delta.line-numbers true

    git config --global merge.conflictstyle diff3
    git config --global diff.colorMoved default

    $aliases = @{
        st     = 'status -sb'
        co     = 'checkout'
        cb     = 'checkout -b'
        cm     = 'commit -m'
        ca     = 'commit --amend'
        can    = 'commit --amend --no-edit'
        br     = 'branch'
        df     = 'diff'
        dfs    = 'diff --staged'
        lg     = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
        rs     = 'reset'
        rsh    = 'reset --hard'
        rss    = 'reset --soft'
        sl     = 'stash list'
        sa     = 'stash apply'
        ss     = 'stash save'
        sp     = 'stash pop'
        sshow  = 'stash show -p'
    }
    foreach ($kvp in $aliases.GetEnumerator()) {
        git config --global ("alias." + $kvp.Key) $kvp.Value
    }
}

# -------------------- Ensure Git identity --------------------
function Ensure-UserIdentity {
    $currentName  = git config --global user.name
    $currentEmail = git config --global user.email

    if ([string]::IsNullOrWhiteSpace($currentName)) {
        $currentName = Read-Host "Enter your Git user.name"
        git config --global user.name "$currentName"
    }

    if ([string]::IsNullOrWhiteSpace($currentEmail)) {
        $currentEmail = Read-Host "Enter your Git user.email"
        git config --global user.email "$currentEmail"
    }

    Write-Host "Using identity: $currentName <$currentEmail>" -ForegroundColor Green
    return $currentEmail
}

# -------------------- Ensure SSH key --------------------
function Ensure-SshKey {
    param([string]$Email)

    $sshDir      = Join-Path $HOME ".ssh"
    $keyFileBase = Join-Path $sshDir "id_ed25519"
    $pubKeyFile  = "${keyFileBase}.pub"

    if (-not (Test-Path $pubKeyFile)) {
        if (-not (Test-Path $sshDir)) { New-Item -ItemType Directory -Path $sshDir | Out-Null }
        Write-Host "Creating a new SSH key (ed25519)..." -ForegroundColor Cyan
        ssh-keygen -t ed25519 -C "$Email" -f $keyFileBase -N '""' | Out-Null
    } else {
        Write-Host "SSH key already exists - skipping key generation." -ForegroundColor Gray
    }

    Get-Content $pubKeyFile | Set-Clipboard
    Write-Host "`nYour public key has been copied to the clipboard." -ForegroundColor Green
    Write-Host "1. Open https://github.com/settings/keys"
    Write-Host "2. Click 'New SSH key', paste, and Save."
    Read-Host "`nPress <Enter> once you've added the key to GitHub to test the connection"

    Write-Host "Testing connection (ssh -T git@github.com)..." -ForegroundColor Cyan
    ssh -T git@github.com
}


# -------------------- Install and Configure Neovim --------------------
function Install-AndConfigure-Neovim {
    Write-Host "`nStep 11: Installing and configuring Neovim..." -ForegroundColor Yellow

    # Install Neovim via Chocolatey
    Write-Host "Installing Neovim..." -ForegroundColor Cyan
    choco install neovim -y

    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Neovim installation may have encountered issues."
        return
    }

    Write-Host "Neovim installed successfully!" -ForegroundColor Green

    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    # Verify dependencies are installed (these should be from earlier steps)
    $dependencies = @("rg", "fd", "fzf")
    foreach ($dep in $dependencies) {
        if (-not (Get-Command $dep -ErrorAction SilentlyContinue)) {
            Write-Warning "$dep is not available - some Neovim features may not work properly"
        }
    }

    # Create Neovim config directory
    Write-Host "Setting up Neovim configuration..." -ForegroundColor Cyan
    $nvimConfigDir = Join-Path $env:LOCALAPPDATA "nvim"
    if (-not (Test-Path $nvimConfigDir)) {
        New-Item -ItemType Directory -Path $nvimConfigDir -Force | Out-Null
    }

    # Install lazy.nvim package manager
    $lazyPath = Join-Path $env:LOCALAPPDATA "nvim-data\lazy\lazy.nvim"
    if (-not (Test-Path $lazyPath)) {
        Write-Host "Installing lazy.nvim package manager..." -ForegroundColor Cyan
        $lazyDir = Split-Path $lazyPath -Parent
        if (-not (Test-Path $lazyDir)) {
            New-Item -ItemType Directory -Path $lazyDir -Force | Out-Null
        }

        try {
            git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable $lazyPath
            Write-Host "✅ lazy.nvim installed successfully!" -ForegroundColor Green
        } catch {
            Write-Warning "Failed to clone lazy.nvim: $_"
            Write-Host "You may need to install it manually in Neovim" -ForegroundColor Yellow
        }
    }

    # Create init.lua configuration
    $initLuaPath = Join-Path $nvimConfigDir "init.lua"

    $initLuaContent = @"
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
                ensure_installed = { "lua", "vim", "bash", "python", "javascript", "typescript", "rust", "powershell" },
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
                ensure_installed = { 'lua_ls', 'rust_analyzer', 'pyright', 'powershell_es' },
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
"@

    try {
        $initLuaContent | Out-File -FilePath $initLuaPath -Encoding UTF8 -Force
        Write-Host "✅ Neovim configuration created at: $initLuaPath" -ForegroundColor Green
    } catch {
        Write-Error "Failed to create Neovim configuration: $_"
        return
    }

    # Add Neovim to PowerShell profile as default editor
    if (Test-Path $PROFILE) {
        $profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
        if ($profileContent -and $profileContent -notmatch "EDITOR.*nvim") {
            try {
                "`n# Set Neovim as default editor" | Add-Content -Path $PROFILE -Encoding UTF8
                "`$env:EDITOR = 'nvim'" | Add-Content -Path $PROFILE -Encoding UTF8
                "`$env:VISUAL = 'nvim'" | Add-Content -Path $PROFILE -Encoding UTF8
                Write-Host "Added Neovim as default editor to PowerShell profile" -ForegroundColor Green
            } catch {
                Write-Warning "Could not add Neovim to PowerShell profile: $_"
            }
        }
    }

    Write-Host ""
    Write-Host "Neovim Setup Summary:" -ForegroundColor Cyan
    Write-Host "  ✅ Neovim installed" -ForegroundColor Green
    Write-Host "  ✅ Configuration created at: $nvimConfigDir" -ForegroundColor Green
    Write-Host "  ✅ Package manager (lazy.nvim) installed" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Open Neovim by typing 'nvim'" -ForegroundColor White
    Write-Host "  2. Run ':Lazy sync' to install all plugins" -ForegroundColor White
    Write-Host "  3. Run ':checkhealth' to verify setup" -ForegroundColor White
    Write-Host ""
    Write-Host "Key bindings:" -ForegroundColor Cyan
    Write-Host "  <Space> = Leader key" -ForegroundColor White
    Write-Host "  <Leader>e = Toggle file explorer" -ForegroundColor White
    Write-Host "  <Leader>ff = Find files" -ForegroundColor White
    Write-Host "  <Leader>fg = Live grep" -ForegroundColor White
    Write-Host "  <Leader>w = Save file" -ForegroundColor White
    Write-Host "  <Leader>q = Quit" -ForegroundColor White
}


# -------------------- Install Programming Languages --------------------
function Install-ProgrammingLanguages {
    Write-Host "`nStep 14: Installing programming languages..." -ForegroundColor Yellow

    $languages = @(
        @{Name="Node.js"; Package="nodejs"; Description="JavaScript runtime"},
        @{Name="Go"; Package="golang"; Description="Go programming language"},
        @{Name="Python"; Package="python"; Description="Python programming language"},
        @{Name="Rust"; Package="rust"; Description="Rust programming language"}
    )

    foreach ($lang in $languages) {
        Write-Host "Installing $($lang.Name) ($($lang.Description))..." -ForegroundColor Cyan
        choco install $($lang.Package) -y

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ $($lang.Name) installed successfully!" -ForegroundColor Green
        } else {
            Write-Warning "❌ $($lang.Name) installation may have encountered issues."
        }
    }

    # Refresh environment variables after all installations
    Write-Host "Refreshing environment variables..." -ForegroundColor Cyan
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    # Verify installations
    Write-Host ""
    Write-Host "Verifying language installations:" -ForegroundColor Cyan

    # Check Node.js
    try {
        $nodeVersion = & node --version 2>$null
        if ($nodeVersion) {
            Write-Host "  ✅ Node.js: $nodeVersion" -ForegroundColor Green

            # Also check npm
            $npmVersion = & npm --version 2>$null
            if ($npmVersion) {
                Write-Host "  ✅ npm: v$npmVersion" -ForegroundColor Green
            }
        }
    } catch {
        Write-Host "  ❌ Node.js: Not found or not working" -ForegroundColor Red
    }

    # Check Go
    try {
        $goVersion = & go version 2>$null
        if ($goVersion) {
            Write-Host "  ✅ Go: $($goVersion -replace 'go version ', '')" -ForegroundColor Green
        }
    } catch {
        Write-Host "  ❌ Go: Not found or not working" -ForegroundColor Red
    }

    # Check Python
    try {
        $pythonVersion = & python --version 2>$null
        if ($pythonVersion) {
            Write-Host "  ✅ Python: $pythonVersion" -ForegroundColor Green

            # Also check pip
            $pipVersion = & pip --version 2>$null
            if ($pipVersion) {
                $pipVersionClean = ($pipVersion -split ' ')[1]
                Write-Host "  ✅ pip: v$pipVersionClean" -ForegroundColor Green
            }
        }
    } catch {
        Write-Host "  ❌ Python: Not found or not working" -ForegroundColor Red
    }

    # Check Rust
    try {
        $rustVersion = & rustc --version 2>$null
        if ($rustVersion) {
            Write-Host "  ✅ Rust: $($rustVersion -replace 'rustc ', '')" -ForegroundColor Green

            # Also check cargo
            $cargoVersion = & cargo --version 2>$null
            if ($cargoVersion) {
                Write-Host "  ✅ Cargo: $($cargoVersion -replace 'cargo ', '')" -ForegroundColor Green
            }
        }
    } catch {
        Write-Host "  ❌ Rust: Not found or not working" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "Programming languages installation completed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps for each language:" -ForegroundColor Yellow
    Write-Host "  📦 Node.js: npm install -g yarn pnpm typescript" -ForegroundColor White
    Write-Host "  🐍 Python: pip install --upgrade pip setuptools wheel" -ForegroundColor White
    Write-Host "  🦀 Rust: cargo install cargo-edit cargo-watch" -ForegroundColor White
    Write-Host "  🐹 Go: go install golang.org/x/tools/gopls@latest" -ForegroundColor White
    Write-Host ""
    Write-Host "Note: You may need to restart your terminal for PATH changes to take effect." -ForegroundColor Cyan
}

# -------------------- Install Visual Studio Build Tools with C++ --------------------
function Install-VisualStudioCppTools {
    Write-Host "`nStep 17: Installing Visual Studio Build Tools with C++ support..." -ForegroundColor Yellow

    # Check if Visual Studio Installer exists
    $vsInstallerPath = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe"

    if (-not (Test-Path $vsInstallerPath)) {
        Write-Host "Visual Studio Installer not found. Installing Visual Studio Build Tools first..." -ForegroundColor Cyan
        choco install visualstudio2022buildtools -y

        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Failed to install Visual Studio Build Tools via Chocolatey"
            return
        }

        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

        Write-Host "Visual Studio Build Tools installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Visual Studio Installer already exists." -ForegroundColor Green
    }

    Write-Host "`nOpening Visual Studio Installer to install Desktop development with C++..." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "IMPORTANT INSTRUCTIONS:" -ForegroundColor Yellow
    Write-Host "1. The Visual Studio Installer will open shortly" -ForegroundColor White
    Write-Host "2. Look for 'Visual Studio Build Tools 2022' in the installer" -ForegroundColor White
    Write-Host "3. Click 'Modify' if already installed, or 'Install' if not installed" -ForegroundColor White
    Write-Host "4. In the workloads tab, check 'Desktop development with C++'" -ForegroundColor White
    Write-Host "5. Click 'Install' or 'Modify' to begin installation" -ForegroundColor White
    Write-Host "6. Wait for the installation to complete" -ForegroundColor White
    Write-Host "7. Come back to this PowerShell window and press Enter when done" -ForegroundColor White
    Write-Host ""

    Read-Host "Press <Enter> to open Visual Studio Installer"

    try {
        Start-Process -FilePath $vsInstallerPath -Wait:$false
        Write-Host "Visual Studio Installer opened." -ForegroundColor Green
    } catch {
        Write-Warning "Failed to open Visual Studio Installer: $_"
        Write-Host "Please manually open: $vsInstallerPath" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Please complete the C++ workload installation in Visual Studio Installer..." -ForegroundColor Cyan
    $userInput = Read-Host "Press <Enter> when you have finished installing 'Desktop development with C++'"

    Write-Host ""
    Write-Host "Adding Visual Studio C++ tools to system PATH..." -ForegroundColor Cyan

    # Add Visual Studio C++ tools to PATH
    $vcToolsPath = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64"

    # Check if the specific version path exists, if not, try to find the latest version
    if (-not (Test-Path $vcToolsPath)) {
        Write-Host "Specific MSVC version path not found. Searching for latest version..." -ForegroundColor Yellow

        $msvcBasePath = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC"
        if (Test-Path $msvcBasePath) {
            $latestVersion = Get-ChildItem $msvcBasePath | Sort-Object Name -Descending | Select-Object -First 1
            if ($latestVersion) {
                $vcToolsPath = Join-Path $latestVersion.FullName "bin\Hostx64\x64"
                Write-Host "Found latest MSVC version: $($latestVersion.Name)" -ForegroundColor Green
            }
        }
    }

    if (Test-Path $vcToolsPath) {
        try {
            # Get current system PATH
            $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")

            # Check if the path is already in PATH
            if ($currentPath -notlike "*$vcToolsPath*") {
                $newPath = $currentPath + ";" + $vcToolsPath
                [System.Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")

                # Also update current session PATH
                $env:Path = $env:Path + ";" + $vcToolsPath

                Write-Host "✅ Visual Studio C++ tools added to system PATH successfully!" -ForegroundColor Green
                Write-Host "   Path added: $vcToolsPath" -ForegroundColor Gray
            } else {
                Write-Host "Visual Studio C++ tools path already exists in system PATH." -ForegroundColor Gray
            }
        } catch {
            Write-Warning "Failed to add Visual Studio C++ tools to PATH: $_"
            Write-Host "You may need to add this path manually: $vcToolsPath" -ForegroundColor Yellow
        }
    } else {
        Write-Warning "Visual Studio C++ tools directory not found at: $vcToolsPath"
        Write-Host "Please verify the C++ workload was installed correctly." -ForegroundColor Yellow
        Write-Host "You may need to manually add the MSVC tools to your PATH." -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Visual Studio C++ tools installation completed!" -ForegroundColor Green
    Write-Host "Note: You may need to restart PowerShell for PATH changes to take effect." -ForegroundColor Cyan
}


# -------------------- Install and Configure Total Commander --------------------
function Install-ConfigureTotalCommander {
    Write-Host "`nStep 15: Installing and configuring Total Commander..." -ForegroundColor Yellow

    # Install Total Commander via Chocolatey
    Write-Host "Installing Total Commander..." -ForegroundColor Cyan
    choco install totalcommander -y

    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Failed to install Total Commander via Chocolatey"
        return
    }

    Write-Host "Total Commander installed successfully!" -ForegroundColor Green

    # Wait a moment for installation to complete
    Start-Sleep -Seconds 3

    # Find Total Commander installation path
    $tcPaths = @(
        "${env:ProgramFiles}\totalcmd\TOTALCMD64.EXE",
        "${env:ProgramFiles(x86)}\totalcmd\TOTALCMD.EXE",
        "$env:LOCALAPPDATA\totalcmd\TOTALCMD64.EXE",
        "${env:ProgramFiles}\Total Commander\TOTALCMD64.EXE",
        "${env:ProgramFiles(x86)}\Total Commander\TOTALCMD.EXE"
    )

    $tcPath = $tcPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $tcPath) {
        Write-Warning "Total Commander executable not found after installation. Skipping configuration."
        return
    }

    $tcDir = Split-Path $tcPath -Parent
    $wincmdIni = Join-Path $tcDir "wincmd.ini"

    Write-Host "Found Total Commander at: $tcDir" -ForegroundColor Green
    Write-Host "Configuration file: $wincmdIni" -ForegroundColor Cyan

    # Backup existing configuration
    if (Test-Path $wincmdIni) {
        $backupPath = "$wincmdIni.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item $wincmdIni $backupPath -ErrorAction SilentlyContinue
        Write-Host "Backed up existing config to: $backupPath" -ForegroundColor Gray
    }

    # Helper function to set INI values
    function Set-IniValue {
        param(
            [string]$FilePath,
            [string]$Section,
            [string]$Key,
            [string]$Value
        )

        try {
            if (-not (Test-Path $FilePath)) {
                New-Item -Path $FilePath -ItemType File -Force | Out-Null
            }

            $content = Get-Content $FilePath -ErrorAction SilentlyContinue
            if (-not $content) { $content = @() }

            $sectionFound = $false
            $keyFound = $false
            $newContent = @()

            foreach ($line in $content) {
                if ($line -match "^\[$Section\]") {
                    $sectionFound = $true
                    $newContent += $line
                }
                elseif ($sectionFound -and $line -match "^$Key=") {
                    $newContent += "$Key=$Value"
                    $keyFound = $true
                }
                elseif ($sectionFound -and $line -match "^\[.*\]" -and $line -notmatch "^\[$Section\]") {
                    if (-not $keyFound) {
                        $newContent += "$Key=$Value"
                    }
                    $newContent += $line
                    $sectionFound = $false
                }
                else {
                    $newContent += $line
                }
            }

            if ($sectionFound -and -not $keyFound) {
                $newContent += "$Key=$Value"
            }
            elseif (-not $sectionFound) {
                $newContent += "[$Section]"
                $newContent += "$Key=$Value"
            }

            $newContent | Out-File -FilePath $FilePath -Encoding UTF8 -Force
        } catch {
            Write-Warning "Failed to set $Section/$Key in $FilePath: $_"
        }
    }

    Write-Host "Configuring Total Commander settings..." -ForegroundColor Cyan

    # ==================== GENERAL CONFIGURATION ====================
    # Interface settings
    Set-IniValue $wincmdIni "Configuration" "UseNewDefFont" "1"
    Set-IniValue $wincmdIni "Configuration" "FontSize" "10"
    Set-IniValue $wincmdIni "Configuration" "FontName" "Segoe UI"
    Set-IniValue $wincmdIni "Configuration" "SizeStyle" "4"
    Set-IniValue $wincmdIni "Configuration" "SeparateTree" "1"
    Set-IniValue $wincmdIni "Configuration" "PanelFont" "Consolas,10"

    # File operations
    Set-IniValue $wincmdIni "Configuration" "CopyComments" "6"
    Set-IniValue $wincmdIni "Configuration" "FirstTime" "0"
    Set-IniValue $wincmdIni "Configuration" "FirstTimeIconLib" "0"
    Set-IniValue $wincmdIni "Configuration" "SortDirsByName" "1"
    Set-IniValue $wincmdIni "Configuration" "AlwaysToRoot" "0"
    Set-IniValue $wincmdIni "Configuration" "SingleClickStart" "0"
    Set-IniValue $wincmdIni "Configuration" "RenameSelOnlyName" "1"

    # View settings
    Set-IniValue $wincmdIni "Configuration" "ShowHiddenSystem" "1"
    Set-IniValue $wincmdIni "Configuration" "ThumbnailsInPercent" "100"
    Set-IniValue $wincmdIni "Configuration" "IconsInMenus" "7"
    Set-IniValue $wincmdIni "Configuration" "DriveBarStyle" "1"

    # ==================== COLORS AND DISPLAY ====================
    Set-IniValue $wincmdIni "Colors" "InverseCursor" "1"
    Set-IniValue $wincmdIni "Colors" "InverseSelection" "1"
    Set-IniValue $wincmdIni "Colors" "Background" "16777215"
    Set-IniValue $wincmdIni "Colors" "Foreground" "0"
    Set-IniValue $wincmdIni "Colors" "Mark" "255"
    Set-IniValue $wincmdIni "Colors" "Cursor" "128"

    # ==================== TABS CONFIGURATION ====================
    Set-IniValue $wincmdIni "Configuration" "UseTabs" "1"
    Set-IniValue $wincmdIni "Configuration" "TabChangeTimer" "750"
    Set-IniValue $wincmdIni "Configuration" "TabsAlwaysVisible" "1"
    Set-IniValue $wincmdIni "Configuration" "DirTabOptions" "824"
    Set-IniValue $wincmdIni "Configuration" "MaxTabTextLength" "32"

    # ==================== COMPRESSION TOOLS ====================
    $sevenZipPaths = @(
        "${env:ProgramFiles}\7-Zip\7z.exe",
        "${env:ProgramFiles(x86)}\7-Zip\7z.exe"
    )
    $sevenZipPath = $sevenZipPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

    if ($sevenZipPath) {
        Set-IniValue $wincmdIni "PackerPlugins" "7zip" "$sevenZipPath"
        Write-Host "  ✓ Configured 7-Zip integration" -ForegroundColor Green
    }

    # ==================== CUSTOM COLUMNS ====================
    Set-IniValue $wincmdIni "CustomFields1" "title0" "Size in MB"
    Set-IniValue $wincmdIni "CustomFields1" "content0" "[=tc.filesize]/1024/1024"
    Set-IniValue $wincmdIni "CustomFields1" "detect0" "MULTIMEDIA | DOCS"

    # ==================== DIRECTORY HOTLIST ====================
    $commonDirs = @{
        "Desktop" = [System.Environment]::GetFolderPath('Desktop')
        "Documents" = [System.Environment]::GetFolderPath('MyDocuments')
        "Downloads" = "$env:USERPROFILE\Downloads"
        "Pictures" = [System.Environment]::GetFolderPath('MyPictures')
        "Videos" = [System.Environment]::GetFolderPath('MyVideos')
        "Music" = [System.Environment]::GetFolderPath('MyMusic')
        "Projects" = "$env:USERPROFILE\Projects"
        "Temp" = $env:TEMP
    }

    $index = 1
    foreach ($name in $commonDirs.Keys) {
        $path = $commonDirs[$name]
        if (Test-Path $path) {
            Set-IniValue $wincmdIni "DirMenu" "menu$index" "$name"
            Set-IniValue $wincmdIni "DirMenu" "cmd$index" "cd $path"
            $index++
        }
    }
    Set-IniValue $wincmdIni "DirMenu" "MenuChangeMode" "16"

    # ==================== BUTTON BAR CUSTOMIZATION ====================
    Set-IniValue $wincmdIni "Buttonbar" "Buttonheight" "29"
    Set-IniValue $wincmdIni "Buttonbar" "FlatIcons" "1"
    Set-IniValue $wincmdIni "Buttonbar" "SmallIcons" "0"

    # Command Prompt button
    Set-IniValue $wincmdIni "Buttonbar" "button1" "cmd /k"
    Set-IniValue $wincmdIni "Buttonbar" "iconic1" "0"
    Set-IniValue $wincmdIni "Buttonbar" "tooltip1" "Open Command Prompt"

    # PowerShell button
    if (Get-Command pwsh -ErrorAction SilentlyContinue) {
        Set-IniValue $wincmdIni "Buttonbar" "button2" "pwsh"
        Set-IniValue $wincmdIni "Buttonbar" "iconic2" "0"
        Set-IniValue $wincmdIni "Buttonbar" "tooltip2" "Open PowerShell"
    } elseif (Get-Command powershell -ErrorAction SilentlyContinue) {
        Set-IniValue $wincmdIni "Buttonbar" "button2" "powershell"
        Set-IniValue $wincmdIni "Buttonbar" "iconic2" "0"
        Set-IniValue $wincmdIni "Buttonbar" "tooltip2" "Open PowerShell"
    }

    # VS Code button
    if (Get-Command code -ErrorAction SilentlyContinue) {
        Set-IniValue $wincmdIni "Buttonbar" "button3" "code ."
        Set-IniValue $wincmdIni "Buttonbar" "iconic3" "0"
        Set-IniValue $wincmdIni "Buttonbar" "tooltip3" "Open VS Code"
    }

    # Windows Terminal button
    if (Get-Command wt -ErrorAction SilentlyContinue) {
        Set-IniValue $wincmdIni "Buttonbar" "button4" "wt"
        Set-IniValue $wincmdIni "Buttonbar" "iconic4" "0"
        Set-IniValue $wincmdIni "Buttonbar" "tooltip4" "Open Windows Terminal"
    }

    # ==================== CUSTOM TOOLS MENU ====================
    # PowerShell Here
    Set-IniValue $wincmdIni "Command1" "cmd" "powershell.exe"
    Set-IniValue $wincmdIni "Command1" "param" "-NoExit -Command Set-Location '%P'"
    Set-IniValue $wincmdIni "Command1" "menu" "PowerShell Here"
    Set-IniValue $wincmdIni "Command1" "iconic" "0"

    # Command Prompt Here
    Set-IniValue $wincmdIni "Command2" "cmd" "cmd.exe"
    Set-IniValue $wincmdIni "Command2" "param" "/k cd /d %P"
    Set-IniValue $wincmdIni "Command2" "menu" "Command Prompt Here"
    Set-IniValue $wincmdIni "Command2" "iconic" "0"

    # VS Code
    if (Get-Command code -ErrorAction SilentlyContinue) {
        Set-IniValue $wincmdIni "Command3" "cmd" "code"
        Set-IniValue $wincmdIni "Command3" "param" "%P"
        Set-IniValue $wincmdIni "Command3" "menu" "Open in VS Code"
        Set-IniValue $wincmdIni "Command3" "iconic" "0"
    }

    # ==================== FILE ASSOCIATIONS ====================
    if (Get-Command code -ErrorAction SilentlyContinue) {
        $codeAssociations = @("txt", "log", "cfg", "ini", "json", "xml", "yml", "yaml", "md", "ps1", "bat", "cmd")
        foreach ($ext in $codeAssociations) {
            Set-IniValue $wincmdIni "FileSystemPlugins64" $ext "code %1"
        }
        Write-Host "  ✓ Configured VS Code file associations" -ForegroundColor Green
    }

    # ==================== SEARCH SETTINGS ====================
    Set-IniValue $wincmdIni "Configuration" "SearchFor" "*.*"
    Set-IniValue $wincmdIni "Configuration" "SearchIn" "%P"
    Set-IniValue $wincmdIni "Configuration" "SearchText" ""
    Set-IniValue $wincmdIni "Configuration" "SearchFlags" "0"
    Set-IniValue $wincmdIni "Configuration" "QuickSearch" "2"
    Set-IniValue $wincmdIni "Configuration" "QuickSearchAutoFilter" "1"

    # ==================== KEYBOARD SHORTCUTS ====================
    Set-IniValue $wincmdIni "Shortcuts" "C+O" "cm_EditPath"
    Set-IniValue $wincmdIni "Shortcuts" "C+E" "cm_Edit"
    Set-IniValue $wincmdIni "Shortcuts" "C+T" "cm_OpenNewTab"
    Set-IniValue $wincmdIni "Shortcuts" "C+W" "cm_CloseCurrentTab"
    Set-IniValue $wincmdIni "Shortcuts" "F4" "cm_Edit"
    Set-IniValue $wincmdIni "Shortcuts" "C+D" "cm_Delete"
    Set-IniValue $wincmdIni "Shortcuts" "C+N" "cm_MkDir"

    # ==================== FTP SETTINGS ====================
    Set-IniValue $wincmdIni "Configuration" "FtpIniName" "$tcDir\wcx_ftp.ini"
    Set-IniValue $wincmdIni "Configuration" "DefaultFtpClientMode" "0"

    # ==================== COPY/MOVE SETTINGS ====================
    Set-IniValue $wincmdIni "Configuration" "CopyComments" "6"
    Set-IniValue $wincmdIni "Configuration" "LogOptions" "4113"
    Set-IniValue $wincmdIni "Configuration" "LogRotateLimit" "1000000"
    Set-IniValue $wincmdIni "Configuration" "UseLongNames" "1"
    Set-IniValue $wincmdIni "Configuration" "ShowCopyTabOptions" "1"

    # ==================== MISC SETTINGS ====================
    Set-IniValue $wincmdIni "Configuration" "AlwaysOnTop" "0"
    Set-IniValue $wincmdIni "Configuration" "Maximized" "0"
    Set-IniValue $wincmdIni "Configuration" "MinimizeToTray" "0"
    Set-IniValue $wincmdIni "Configuration" "CmdLineHistorySize" "50"
    Set-IniValue $wincmdIni "Configuration" "ShowCentury" "1"
    Set-IniValue $wincmdIni "Configuration" "ShowSeconds" "1"

    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    Write-Host "✅ Total Commander installation and configuration completed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Configuration includes:" -ForegroundColor Cyan
    Write-Host "  ✓ Modern font settings (Segoe UI/Consolas)" -ForegroundColor White
    Write-Host "  ✓ Show hidden/system files enabled" -ForegroundColor White
    Write-Host "  ✓ Tabbed interface with optimized settings" -ForegroundColor White
    Write-Host "  ✓ Directory hotlist with common folders" -ForegroundColor White
    Write-Host "  ✓ Custom button bar (CMD, PowerShell, VS Code, Terminal)" -ForegroundColor White
    Write-Host "  ✓ Custom tools menu for developer workflows" -ForegroundColor White
    Write-Host "  ✓ 7-Zip integration (if 7-Zip is installed)" -ForegroundColor White
    Write-Host "  ✓ VS Code file associations (if VS Code is installed)" -ForegroundColor White
    Write-Host "  ✓ Enhanced search and quick search settings" -ForegroundColor White
    Write-Host "  ✓ Optimized copy/move operations" -ForegroundColor White
    Write-Host "  ✓ Developer-friendly keyboard shortcuts" -ForegroundColor White
    Write-Host ""
    Write-Host "Note: Please restart Total Commander to apply all changes." -ForegroundColor Yellow
}


# -------------------- Install and Configure Visual Studio Code --------------------
function Install-ConfigureVSCode {
    Write-Host "`nStep X: Installing and configuring Visual Studio Code..." -ForegroundColor Yellow

    # Install VS Code via Chocolatey
    Write-Host "Installing Visual Studio Code..." -ForegroundColor Cyan
    choco install vscode -y

    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Failed to install VS Code via Chocolatey"
        return
    }

    Write-Host "Visual Studio Code installed successfully!" -ForegroundColor Green

    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    # Wait a moment for installation to complete
    Start-Sleep -Seconds 5

    # Verify VS Code installation
    if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
        Write-Warning "VS Code 'code' command not found in PATH. Please restart PowerShell and try again."
        return
    }

    Write-Host "Configuring VS Code settings and extensions..." -ForegroundColor Cyan

    # VS Code settings directory
    $vscodeSettingsDir = "$env:APPDATA\Code\User"
    if (-not (Test-Path $vscodeSettingsDir)) {
        New-Item -ItemType Directory -Path $vscodeSettingsDir -Force | Out-Null
        Write-Host "Created VS Code settings directory: $vscodeSettingsDir" -ForegroundColor Gray
    }

    # ==================== INSTALL ESSENTIAL EXTENSIONS ====================
    Write-Host "Installing essential VS Code extensions..." -ForegroundColor Cyan

    $essentialExtensions = @(
    # Language Support
        "ms-python.python",                    # Python
        "ms-vscode.powershell",               # PowerShell
        "ms-dotnettools.csharp",              # C#
        "ms-vscode.vscode-typescript-next",   # TypeScript
        "bradlc.vscode-tailwindcss",          # Tailwind CSS
        "esbenp.prettier-vscode",             # Prettier
        "ms-vscode.vscode-json",              # JSON

        # Web Development
        "formulahendry.auto-rename-tag",      # Auto Rename Tag
        "bradlc.vscode-tailwindcss",          # Tailwind CSS
        "ms-vscode.live-server",              # Live Server
        "ritwickdey.liveserver",              # Live Server (alternative)

        # Git & Version Control
        "eamodio.gitlens",                    # GitLens
        "mhutchie.git-graph",                 # Git Graph
        "donjayamanne.githistory",            # Git History

        # Productivity & UI
        "ms-vscode-remote.remote-wsl",        # WSL Remote
        "ms-vscode-remote.remote-ssh",        # SSH Remote
        "ms-vscode.remote-explorer",          # Remote Explorer
        "gruntfuggly.todo-tree",              # TODO Tree
        "aaron-bond.better-comments",         # Better Comments
        "oderwat.indent-rainbow",             # Indent Rainbow
        "streetsidesoftware.code-spell-checker", # Code Spell Checker

        # File Management
        "alefragnani.project-manager",        # Project Manager
        "alefragnani.bookmarks",              # Bookmarks
        "christian-kohler.path-intellisense", # Path Intellisense
        "ms-vscode.vscode-json",              # JSON Tools

        # Themes & Icons
        "pkief.material-icon-theme",          # Material Icon Theme
        "zhuangtongfa.material-theme",        # One Dark Pro
        "dracula-theme.theme-dracula",        # Dracula Official

        # Docker & Containers
        "ms-azuretools.vscode-docker",        # Docker
        "ms-vscode-remote.remote-containers", # Dev Containers

        # Markdown & Documentation
        "yzhang.markdown-all-in-one",         # Markdown All in One
        "shd101wyy.markdown-preview-enhanced", # Markdown Preview Enhanced

        # Utilities
        "ms-vsliveshare.vsliveshare",         # Live Share
        "humao.rest-client",                  # REST Client
        "ms-vscode.hexeditor",                # Hex Editor
        "redhat.vscode-yaml",                 # YAML
        "ms-vscode.vscode-json",              # JSON
        "formulahendry.auto-close-tag",       # Auto Close Tag

        # AI & IntelliSense
        "github.copilot",                     # GitHub Copilot (if available)
        "ms-vscode.vscode-ai",                # VS Code AI (if available)
        "tabnine.tabnine-vscode"              # Tabnine AI
    )

    $installedExtensions = @()
    $failedExtensions = @()

    foreach ($extension in $essentialExtensions) {
        Write-Host "  Installing $extension..." -ForegroundColor Gray
        try {
            $result = & code --install-extension $extension --force 2>&1
            if ($LASTEXITCODE -eq 0) {
                $installedExtensions += $extension
                Write-Host "    ✓ $extension" -ForegroundColor Green
            } else {
                $failedExtensions += $extension
                Write-Host "    ✗ $extension (Error: $result)" -ForegroundColor Red
            }
        } catch {
            $failedExtensions += $extension
            Write-Host "    ✗ $extension (Exception: $_)" -ForegroundColor Red
        }
        Start-Sleep -Milliseconds 500  # Brief pause between installations
    }

    Write-Host ""
    Write-Host "Extension installation summary:" -ForegroundColor Cyan
    Write-Host "  ✓ Installed: $($installedExtensions.Count)" -ForegroundColor Green
    Write-Host "  ✗ Failed: $($failedExtensions.Count)" -ForegroundColor Red

    if ($failedExtensions.Count -gt 0) {
        Write-Host "Failed extensions:" -ForegroundColor Yellow
        $failedExtensions | ForEach-Object { Write-Host "    - $_" -ForegroundColor Gray }
    }

    # ==================== CREATE SETTINGS.JSON ====================
    Write-Host "Creating VS Code settings.json..." -ForegroundColor Cyan

    $settingsPath = Join-Path $vscodeSettingsDir "settings.json"

    $vscodeSettings = @{
        # ==================== GENERAL SETTINGS ====================
        "workbench.startupEditor" = "newUntitledFile"
        "workbench.colorTheme" = "One Dark Pro"
        "workbench.iconTheme" = "material-icon-theme"
        "workbench.tree.indent" = 16
        "workbench.list.smoothScrolling" = $true
        "workbench.editor.enablePreview" = $false
        "workbench.editor.closeOnFileDelete" = $true
        "workbench.commandPalette.history" = 50

        # ==================== EDITOR SETTINGS ====================
        "editor.fontSize" = 14
        "editor.fontFamily" = "'JetBrains Mono', 'Fira Code', 'Cascadia Code', Consolas, 'Courier New', monospace"
        "editor.fontLigatures" = $true
        "editor.lineHeight" = 1.6
        "editor.cursorBlinking" = "smooth"
        "editor.cursorSmoothCaretAnimation" = "on"
        "editor.smoothScrolling" = $true
        "editor.mouseWheelScrollSensitivity" = 1
        "editor.fastScrollSensitivity" = 5

        # Indentation & Formatting
        "editor.tabSize" = 4
        "editor.insertSpaces" = $true
        "editor.detectIndentation" = $true
        "editor.formatOnSave" = $true
        "editor.formatOnPaste" = $true
        "editor.formatOnType" = $false
        "editor.trimAutoWhitespace" = $true
        "files.trimTrailingWhitespace" = $true
        "files.insertFinalNewline" = $true
        "files.trimFinalNewlines" = $true

        # IntelliSense & Suggestions
        "editor.suggestSelection" = "first"
        "editor.acceptSuggestionOnCommitCharacter" = $true
        "editor.acceptSuggestionOnEnter" = "on"
        "editor.wordBasedSuggestions" = "matchingDocuments"
        "editor.quickSuggestions" = @{
            "other" = $true
            "comments" = $false
            "strings" = $false
        }

        # Code Display
        "editor.renderWhitespace" = "boundary"
        "editor.renderControlCharacters" = $false
        "editor.renderLineHighlight" = "all"
        "editor.showFoldingControls" = "mouseover"
        "editor.foldingStrategy" = "auto"
        "editor.bracketPairColorization.enabled" = $true
        "editor.guides.bracketPairs" = $true
        "editor.guides.bracketPairsHorizontal" = $true
        "editor.guides.indentation" = $true

        # Minimap
        "editor.minimap.enabled" = $true
        "editor.minimap.renderCharacters" = $false
        "editor.minimap.showSlider" = "always"
        "editor.minimap.side" = "right"

        # ==================== FILE SETTINGS ====================
        "files.autoSave" = "afterDelay"
        "files.autoSaveDelay" = 1000
        "files.encoding" = "utf8"
        "files.eol" = "`n"
        "files.hotExit" = "onExit"

        # File Associations
        "files.associations" = @{
            "*.ps1" = "powershell"
            "*.psm1" = "powershell"
            "*.psd1" = "powershell"
            "*.json" = "jsonc"
            "*.jsonc" = "jsonc"
            ".gitignore" = "ignore"
            ".gitattributes" = "gitattributes"
            "Dockerfile*" = "dockerfile"
            "*.yml" = "yaml"
            "*.yaml" = "yaml"
        }

        # Exclude patterns
        "files.exclude" = @{
            "**/.git" = $true
            "**/.svn" = $true
            "**/.hg" = $true
            "**/CVS" = $true
            "**/.DS_Store" = $true
            "**/.vscode" = $false
            "**/node_modules" = $true
            "**/bower_components" = $true
            "**/.nyc_output" = $true
            "**/coverage" = $true
            "**/.pytest_cache" = $true
            "**/__pycache__" = $true
            "**/*.pyc" = $true
            "**/bin" = $true
            "**/obj" = $true
        }

        # ==================== SEARCH SETTINGS ====================
        "search.exclude" = @{
            "**/node_modules" = $true
            "**/bower_components" = $true
            "**/*.code-search" = $true
            "**/.git" = $true
            "**/coverage" = $true
            "**/dist" = $true
            "**/build" = $true
            "**/.nyc_output" = $true
            "**/.pytest_cache" = $true
            "**/__pycache__" = $true
        }
        "search.smartCase" = $true
        "search.useIgnoreFiles" = $true

        # ==================== TERMINAL SETTINGS ====================
        "terminal.integrated.defaultProfile.windows" = "PowerShell"
        "terminal.integrated.profiles.windows" = @{
            "PowerShell" = @{
                "source" = "PowerShell"
                "icon" = "terminal-powershell"
            }
            "Command Prompt" = @{
                "path" = @(
                "${env:windir}\\Sysnative\\cmd.exe",
                "${env:windir}\\System32\\cmd.exe"
                )
                "args" = []
                "icon" = "terminal-cmd"
            }
            "Git Bash" = @{
                "source" = "Git Bash"
            }
        }
        "terminal.integrated.fontSize" = 13
        "terminal.integrated.fontFamily" = "'JetBrains Mono', 'Fira Code', 'Cascadia Code', Consolas"
        "terminal.integrated.cursorBlinking" = $true
        "terminal.integrated.cursorStyle" = "block"
        "terminal.integrated.scrollback" = 10000

        # ==================== GIT SETTINGS ====================
        "git.enableSmartCommit" = $true
        "git.confirmSync" = $false
        "git.autofetch" = $true
        "git.autoStash" = $true
        "git.enableStatusBarSync" = $true
        "git.decorations.enabled" = $true

        # ==================== LANGUAGE-SPECIFIC SETTINGS ====================
        # PowerShell
        "powershell.codeFormatting.preset" = "OTBS"
        "powershell.integratedConsole.showOnStartup" = $false

        # Python
        "python.defaultInterpreterPath" = "python"
        "python.formatting.provider" = "black"
        "python.linting.enabled" = $true
        "python.linting.pylintEnabled" = $false
        "python.linting.flake8Enabled" = $true

        # JavaScript/TypeScript
        "javascript.updateImportsOnFileMove.enabled" = "always"
        "typescript.updateImportsOnFileMove.enabled" = "always"
        "javascript.suggest.autoImports" = $true
        "typescript.suggest.autoImports" = $true

        # JSON
        "json.format.enable" = $true
        "json.format.keepLines" = $false

        # ==================== EXTENSION SETTINGS ====================
        # GitLens
        "gitlens.codeLens.enabled" = $true
        "gitlens.currentLine.enabled" = $true
        "gitlens.hovers.enabled" = $true

        # Live Server
        "liveServer.settings.donotShowInfoMsg" = $true
        "liveServer.settings.donotVerifyTags" = $true

        # TODO Tree
        "todo-tree.general.tags" = @(
            "BUG", "HACK", "FIXME", "TODO", "XXX", "[ ]", "[x]"
        )
        "todo-tree.regex.regex" = "((//|#|<!--|;|/\*|^)\s*($TAGS)|^\s*- \[ \])"

        # Better Comments
        "better-comments.tags" = @(
            @{
                "tag" = "!"
                "color" = "#FF2D00"
                "strikethrough" = $false
                "underline" = $false
                "backgroundColor" = "transparent"
                "bold" = $false
                "italic" = $false
            },
            @{
                "tag" = "?"
                "color" = "#3498DB"
                "strikethrough" = $false
                "underline" = $false
                "backgroundColor" = "transparent"
                "bold" = $false
                "italic" = $false
            },
            @{
                "tag" = "//"
                "color" = "#474747"
                "strikethrough" = $true
                "underline" = $false
                "backgroundColor" = "transparent"
                "bold" = $false
                "italic" = $false
            },
            @{
                "tag" = "todo"
                "color" = "#FF8C00"
                "strikethrough" = $false
                "underline" = $false
                "backgroundColor" = "transparent"
                "bold" = $false
                "italic" = $false
            },
            @{
                "tag" = "*"
                "color" = "#98C379"
                "strikethrough" = $false
                "underline" = $false
                "backgroundColor" = "transparent"
                "bold" = $false
                "italic" = $false
            }
        )

        # Auto Close Tag
        "auto-close-tag.activationOnLanguage" = @(
            "xml", "php", "blade", "ejs", "jinja", "javascript", "javascriptreact",
            "typescript", "typescriptreact", "plaintext", "markdown", "vue",
            "liquid", "erb", "lang-cfml", "cfml", "HTML (EEx)", "HTML (Eex)",
            "plist"
        )

        # ==================== SECURITY & PRIVACY ====================
        "telemetry.telemetryLevel" = "off"
        "update.showReleaseNotes" = $false
        "extensions.autoCheckUpdates" = $true
        "extensions.autoUpdate" = $true

        # ==================== PERFORMANCE ====================
        "extensions.ignoreRecommendations" = $false
        "workbench.reduceMotion" = "auto"
        "workbench.enableExperiments" = $false
    }

    # Convert to JSON and save
    try {
        $jsonSettings = $vscodeSettings | ConvertTo-Json -Depth 10
        $jsonSettings | Out-File -FilePath $settingsPath -Encoding UTF8 -Force
        Write-Host "✓ VS Code settings.json created successfully" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to create settings.json: $_"
    }

    # ==================== CREATE KEYBINDINGS.JSON ====================
    Write-Host "Creating VS Code keybindings.json..." -ForegroundColor Cyan

    $keybindingsPath = Join-Path $vscodeSettingsDir "keybindings.json"

    $keybindings = @(
        @{
            "key" = "ctrl+shift+alt+f"
            "command" = "editor.action.formatDocument"
        },
        @{
            "key" = "ctrl+k ctrl+d"
            "command" = "editor.action.formatDocument"
        },
        @{
            "key" = "ctrl+shift+p"
            "command" = "workbench.action.showCommands"
        },
        @{
            "key" = "ctrl+shift+e"
            "command" = "workbench.view.explorer"
        },
        @{
            "key" = "ctrl+shift+g"
            "command" = "workbench.view.scm"
        },
        @{
            "key" = "ctrl+shift+d"
            "command" = "workbench.view.debug"
        },
        @{
            "key" = "ctrl+shift+x"
            "command" = "workbench.view.extensions"
        },
        @{
            "key" = "ctrl+`"
            "command" = "workbench.action.terminal.toggleTerminal"
        },
        @{
            "key" = "ctrl+shift+`"
            "command" = "workbench.action.terminal.new"
        },
        @{
            "key" = "ctrl+w"
            "command" = "workbench.action.closeActiveEditor"
        },
        @{
            "key" = "ctrl+shift+t"
            "command" = "workbench.action.reopenClosedEditor"
        }
    )

    try {
        $jsonKeybindings = $keybindings | ConvertTo-Json -Depth 5
        $jsonKeybindings | Out-File -FilePath $keybindingsPath -Encoding UTF8 -Force
        Write-Host "✓ VS Code keybindings.json created successfully" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to create keybindings.json: $_"
    }

    # ==================== CREATE SNIPPETS ====================
    Write-Host "Creating custom snippets..." -ForegroundColor Cyan

    $snippetsDir = Join-Path $vscodeSettingsDir "snippets"
    if (-not (Test-Path $snippetsDir)) {
        New-Item -ItemType Directory -Path $snippetsDir -Force | Out-Null
    }

    # PowerShell snippets
    $powershellSnippetsPath = Join-Path $snippetsDir "powershell.json"
    $powershellSnippets = @{
        "Function Template" = @{
            "prefix" = "func"
            "body" = @(
                "function ${1:FunctionName} {",
                "    param(",
                "        [Parameter(Mandatory=`$true)]",
                "        [string]`${2:ParameterName}",
                "    )",
                "    ",
                "    ${3:# Function body}",
                "}"
            )
            "description" = "PowerShell function template"
        }
        "Try-Catch Block" = @{
            "prefix" = "try"
            "body" = @(
                "try {",
                "    ${1:# Code that might throw an exception}",
                "}",
                "catch {",
                "    Write-Error `"Error: `$_`"",
                "    ${2:# Error handling}",
                "}"
            )
            "description" = "PowerShell try-catch block"
        }
    }

    try {
        $jsonPowerShellSnippets = $powershellSnippets | ConvertTo-Json -Depth 5
        $jsonPowerShellSnippets | Out-File -FilePath $powershellSnippetsPath -Encoding UTF8 -Force
        Write-Host "✓ PowerShell snippets created" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to create PowerShell snippets: $_"
    }

    Write-Host ""
    Write-Host "✅ VS Code installation and configuration completed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Configuration includes:" -ForegroundColor Cyan
    Write-Host "  ✓ $($installedExtensions.Count) essential extensions installed" -ForegroundColor White
    Write-Host "  ✓ Optimized settings for development workflow" -ForegroundColor White
    Write-Host "  ✓ Modern theme and icon pack (One Dark Pro + Material Icons)" -ForegroundColor White
    Write-Host "  ✓ Font ligatures support (JetBrains Mono, Fira Code)" -ForegroundColor White
    Write-Host "  ✓ Auto-formatting and code quality settings" -ForegroundColor White
    Write-Host "  ✓ Git integration with GitLens" -ForegroundColor White
    Write-Host "  ✓ PowerShell, Python, C#, TypeScript language support" -ForegroundColor White
    Write-Host "  ✓ Docker and remote development capabilities" -ForegroundColor White
    Write-Host "  ✓ Custom keybindings and snippets" -ForegroundColor White
    Write-Host "  ✓ Performance optimizations" -ForegroundColor White
    Write-Host ""
    Write-Host "VS Code is ready for development!" -ForegroundColor Green
}

# -------------------- Main execution --------------------
try {
    # Step 1: Install Chocolatey
    Install-Chocolatey

    # Step 2: Install Chrome and wait for user configuration
    Install-Chrome

    # Step 3: Install Git
    Install-Git

    # Step 4: Configure Git
    Write-Host "`nStep 4: Configuring Git..." -ForegroundColor Yellow

    Create-GlobalGitignore
    Ensure-Delta
    Set-GitConfig
    $email = Ensure-UserIdentity
    Ensure-SshKey -Email $email

    # Step 5: Configure Scoop (buckets)
    Configure-Scoop

    # Step 6: Install Fonts
    Install-Fonts

    # Step 7: Install Essential Applications
    Install-EssentialApplications

    # Step 8: Install CLI tools via Chocolatey
    Install-ChocolateyTools

    # Step 9: Install CLI tools via Scoop
    Install-ScoopTools

    # Step 10: Install WezTerm
    Install-WezTerm

    # Step 11: Install Starship
    Install-Starship

    # Step 12: Configure CLI Tools, WezTerm, and Starship
    Write-Host "`nStep 12: Configuring CLI tools, WezTerm, and Starship..." -ForegroundColor Yellow
    Configure-CLITools
    Configure-WezTerm
    Configure-Starship
    Configure-PowerShellProfile

    # Step 13: Install and configure Neovim
    Write-Host "`nStep 13: Install and configure neovim..." -ForegroundColor Yellow
    Install-AndConfigure-Neovim

    # Step 14: Install programming languaches and runtimes
    Install-ProgrammingLanguages

    # Step 15: Install TotalCMD
    Install-ConfigureTotalCommander

    # Step 17: Install C++
    Install-VisualStudioCppTools

    Write-Host "`nAll done! Your system is now configured." -ForegroundColor Green
    Write-Host "Installed software:" -ForegroundColor Cyan
    Write-Host "  - Package managers: Chocolatey, Scoop" -ForegroundColor White
    Write-Host "  - Font: JetBrains Mono Nerd Font" -ForegroundColor White
    Write-Host "  - Essential Apps: JetBrains Toolbox, 7zip, AnyDesk, Telegram, Obsidian, SparkMail, OpenVPN Connect, Zoom, Slack, Firefox" -ForegroundColor White
    Write-Host "  - CLI tools via Chocolatey: fzf, ripgrep, bat, navi, zoxide, wget, curl, fd, jq, tree, ncdu, httpie, duf" -ForegroundColor White
    Write-Host "  - CLI tools via Scoop: eza, btop, tlrc, doggo, ntop" -ForegroundColor White
    Write-Host "  - Terminal: WezTerm with Tokyo Night theme" -ForegroundColor White
    Write-Host "  - Browsers: Google Chrome, Firefox" -ForegroundColor White
    Write-Host "  - Development: Git with custom configuration, Delta (Git diff tool)" -ForegroundColor White
    Write-Host "  - Shell: Starship prompt with custom configuration" -ForegroundColor White
    Write-Host "  - PowerShell profile with aliases and functions" -ForegroundColor White
    Write-Host "  - SSH key for GitHub" -ForegroundColor White

    Write-Host "`nEssential applications installed:" -ForegroundColor Yellow
    Write-Host "  🛠️  JetBrains Toolbox - IDE management" -ForegroundColor White
    Write-Host "  📦 7zip - Archive management" -ForegroundColor White
    Write-Host "  🖥️  AnyDesk - Remote desktop" -ForegroundColor White
    Write-Host "  💬 Telegram - Messaging" -ForegroundColor White
    Write-Host "  📝 Obsidian - Note taking" -ForegroundColor White
    Write-Host "  📧 SparkMail - Email client" -ForegroundColor White
    Write-Host "  🔒 OpenVPN Connect - VPN client" -ForegroundColor White
    Write-Host "  📹 Zoom - Video conferencing" -ForegroundColor White
    Write-Host "  💼 Slack - Team communication" -ForegroundColor White
    Write-Host "  🦊 Firefox - Web browser" -ForegroundColor White

    Write-Host "`nTo apply all changes:" -ForegroundColor Yellow
    Write-Host "  - Restart PowerShell, or" -ForegroundColor White
    Write-Host "  - Run: . `$PROFILE" -ForegroundColor White
    Write-Host "  - Launch WezTerm to use the new terminal!" -ForegroundColor White

} catch {
    Write-Error "An error occurred: $_"
    Write-Host "Please check the error message above and try running the script as Administrator." -ForegroundColor Red
    exit 1
}

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
