#!/bin/bash

# Import utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.ios.sh"

install_chrome(){
  install_cask_or_upgrade google-chrome
  open -a "Google Chrome"
  echo
  echo "Please complete initial setup for chrome browser"
  read -p "Press Enter when you're ready to continue..."
}

# Execute if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_chrome
fi
