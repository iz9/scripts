#!/bin/bash

# Import utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.mac.sh"

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

# Execute if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_asdf_and_languages
fi
