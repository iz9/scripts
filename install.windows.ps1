# Windows Software Installation and Configuration Script
# Run as Administrator for best results

Write-Host "=== Windows Software Installation and Configuration ===" -ForegroundColor Cyan
Write-Host ""

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

# -------------------- Install Scoop --------------------
function Install-Scoop {
    Write-Host "`nStep 2: Installing Scoop..." -ForegroundColor Yellow

    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "Scoop is already installed." -ForegroundColor Green
        return
    }

    Write-Host "Installing Scoop package manager..." -ForegroundColor Cyan

    # Set execution policy for current user if needed
    $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
    if ($currentPolicy -eq 'Restricted') {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Write-Host "Execution policy set to RemoteSigned for current user." -ForegroundColor Gray
    }

    # Install Scoop
    try {
        iex "& {$(irm get.scoop.sh)} -RunAsAdmin"

        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

        Write-Host "Scoop installed successfully!" -ForegroundColor Green

        # Add useful buckets
        Write-Host "Adding useful Scoop buckets..." -ForegroundColor Cyan
        scoop bucket add extras
        scoop bucket add versions
        scoop bucket add nerd-fonts

        Write-Host "Scoop buckets added: extras, versions, nerd-fonts" -ForegroundColor Green

    } catch {
        Write-Warning "Scoop installation encountered an issue: $_"
    }
}

# -------------------- Install Fonts --------------------
function Install-Fonts {
    Write-Host "`nStep 3: Installing fonts..." -ForegroundColor Yellow

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
    Write-Host "`nStep 4: Installing essential applications..." -ForegroundColor Yellow

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
    Write-Host "`nStep 5: Installing CLI tools via Chocolatey..." -ForegroundColor Yellow

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
    Write-Host "`nStep 6: Installing CLI tools via Scoop..." -ForegroundColor Yellow

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
    Write-Host "`nStep 7: Installing WezTerm..." -ForegroundColor Yellow

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
config.font = wezterm.font('JetBrainsMono Nerd Font')
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
    Write-Host "`nStep 8: Installing Google Chrome..." -ForegroundColor Yellow

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
    Write-Host "`nStep 9: Installing Git..." -ForegroundColor Yellow

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
    Write-Host "`nStep 10: Installing Starship prompt..." -ForegroundColor Yellow

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
success_symbol = "[❯](purple)"
error_symbol = "[❯](red)"
vimcmd_symbol = "[❮](green)"

[git_branch]
format = "[`$branch](`$style)"
style = "bright-black"

[git_status]
format = "[[(*`$conflicted`$untracked`$modified`$staged`$renamed`$deleted)](218) (`$ahead_behind`$stashed)](`$style)"
style = "cyan"
conflicted = "​"
untracked = "​"
modified = "​"
staged = "​"
renamed = "​"
deleted = "​"
stashed = "≡"

[git_state]
format = '\([`$state( `$progress_current/`$progress_total)](`$style)\) '
style = "bright-black"

[cmd_duration]
format = "[`$duration](`$style) "
style = "yellow"

[python]
format = '[`${symbol}`${pyenv_prefix}(`${version} )(\(`$virtualenv\) )](`$style)'
symbol = "🐍 "
style = "yellow bold"

[nodejs]
format = '[`${symbol}(`${version} )](`$style)'
symbol = "⬢ "
style = "green bold"
"@

    $starshipConfig | Out-File -FilePath $starshipConfigPath -Encoding UTF8
    Write-Host "Starship config created at: $starshipConfigPath" -ForegroundColor Green
}

# -------------------- Configure PowerShell Profile --------------------
function Configure-PowerShellProfile {
    Write-Host "Configuring PowerShell profile..." -ForegroundColor Cyan

    # Check if profile exists, create if not
    if (-not (Test-Path $PROFILE)) {
        $profileDir = Split-Path $PROFILE -Parent
        if (-not (Test-Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        }
        New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    }

    # Read existing profile content
    $existingContent = if (Test-Path $PROFILE) { Get-Content $PROFILE -Raw } else { "" }

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
        Add-Content -Path $PROFILE -Value $profileConfig -Encoding UTF8
        Write-Host "CLI tools configuration added to PowerShell profile: $PROFILE" -ForegroundColor Green
    } else {
        Write-Host "CLI tools configuration already exists in PowerShell profile." -ForegroundColor Gray
    }

    Write-Host "Note: Restart PowerShell or run '. `$PROFILE' to apply changes." -ForegroundColor Yellow
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

# -------------------- Main execution --------------------
try {
    # Step 1: Install Chocolatey
    Install-Chocolatey

    # Step 2: Install Scoop
    Install-Scoop

    # Step 3: Install Fonts
    Install-Fonts

    # Step 4: Install Essential Applications
    Install-EssentialApplications

    # Step 5: Install CLI tools via Chocolatey
    Install-ChocolateyTools

    # Step 6: Install CLI tools via Scoop
    Install-ScoopTools

    # Step 7: Install WezTerm
    Install-WezTerm

    # Step 8: Install Chrome and wait for user configuration
    Install-Chrome

    # Step 9: Install Git
    Install-Git

    # Step 10: Install Starship
    Install-Starship

    # Step 11: Configure Git
    Write-Host "`nStep 11: Configuring Git..." -ForegroundColor Yellow

    Create-GlobalGitignore
    Ensure-Delta
    Set-GitConfig
    $email = Ensure-UserIdentity
    Ensure-SshKey -Email $email

    # Step 12: Configure CLI Tools, WezTerm, and Starship
    Write-Host "`nStep 12: Configuring CLI tools, WezTerm, and Starship..." -ForegroundColor Yellow
    Configure-CLITools
    Configure-WezTerm
    Configure-Starship
    Configure-PowerShellProfile

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
