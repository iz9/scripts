# windows
This Windows software table follows the same format as the macOS and Ubuntu tables, but with Windows-specific package managers and installation methods. Key differences include:

1. **Package Managers**:
    - Winget (Microsoft's official package manager)
    - Chocolatey and Scoop (popular third-party package managers)

2. **Shell Environment**:
    - PowerShell Core instead of Zsh
    - Oh My Posh instead of Oh My Zsh
    - Windows Terminal as the modern terminal emulator

3. **Windows-specific Tools**:
    - PowerToys (productivity utilities)
    - WSL (Windows Subsystem for Linux)
    - Sysinternals Suite (advanced system utilities)

4. **Installation Methods**:
    - Most software can be installed via winget
    - Some developer tools use scoop or pip
    - Some built-in Windows tools are marked as "system"

The table includes similar categories to the macOS and Ubuntu versions: package managers, development tools, programming languages, terminal utilities, and GUI applications, making it easy to set up a complete Windows development environment.

# ubuntu

This is a CSV file for Ubuntu software similar to the macOS one. I've adapted the installation commands to use Ubuntu's package managers (apt, snap, flatpak) instead of Homebrew. I've also included similar software categories:

1. Package managers (apt, snap, flatpak)
2. Development tools (JetBrains Toolbox, git, etc.)
3. Programming languages and environments (Node.js, Python, Ruby, etc.)
4. Terminal utilities (zsh, fzf, ripgrep, etc.)
5. GUI applications (Slack, Telegram, Firefox, etc.)

The installation commands are specific to Ubuntu and use the appropriate package managers. For software not available in standard repositories, I've included direct download commands or PPA instructions.

You can save this as "soft.ubuntu.csv" in the same directory as the macOS file.
