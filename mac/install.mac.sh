#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMP_DIR="${1:-/tmp}"  # Use provided TEMP_DIR or default to /tmp
PROGRESS_FILE="${TEMP_DIR}/postinstall_progress"

# Function to run script in new terminal tab
run_script_and_wait() {
    local script_path="$1"

    echo "Running ${script_path##*/}..."
    chmod +x "$script_path"

    # For Homebrew installation, handle sudo separately
    if [[ "${script_path##*/}" == "install_homebrew.mac.sh" ]]; then
        # Get sudo credentials first and keep them alive
        sudo -v

        # Keep sudo active in background
        (while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null) &

        # Run the script directly with current sudo session
        sudo "$script_path"

        # Kill the sudo keepalive
        kill $! 2>/dev/null
    else
        # Execute script normally
        "$script_path"
    fi

    local exit_status=$?

    if [ $exit_status -eq 0 ]; then
        echo "${script_path##*/} completed successfully!"
    else
        echo "Error: ${script_path##*/} failed with exit code $exit_status"
        exit $exit_status
    fi
}

# Function to restart current terminal and continue script
restart_and_continue() {
    if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
        osascript -e "tell application \"Terminal\"
            set currentWindow to window 1
            tell currentWindow
                set custom title to \"Restarting...\"
                do script \"cd '$SCRIPT_DIR' && '$0' '$TEMP_DIR'\" in selected tab of currentWindow
            end tell
        end tell"
    elif [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
        osascript -e "tell application \"iTerm2\"
            tell current session of current window
                set name to \"Restarting...\"
                write text \"clear && cd '$SCRIPT_DIR' && '$0' '$TEMP_DIR'\"
            end tell
        end tell"
    fi
    exit 0
}

# Function to resume from last step
resume_from_last_step() {
    if [ -f "$PROGRESS_FILE" ]; then
        LAST_STEP=$(cat "$PROGRESS_FILE")
        echo "Resuming from step: $LAST_STEP"
        return 0
    fi
    echo "0" > "$PROGRESS_FILE"
    return 1
}

# Function to mark step as completed
mark_step_completed() {
    echo "$1" > "$PROGRESS_FILE"
}

main() {
    local LAST_STEP=0
    resume_from_last_step && LAST_STEP=$(cat "$PROGRESS_FILE")

    # Step 1: Xcode tools
    if [ "$LAST_STEP" -lt 1 ]; then
        run_script_and_wait "${SCRIPT_DIR}/install_xcode_tools.mac.sh"
        mark_step_completed "1"
    fi

    # Step 2: Homebrew
    if [ "$LAST_STEP" -lt 2 ]; then
        run_script_and_wait "${SCRIPT_DIR}/install_homebrew.mac.sh"
        mark_step_completed "2"
        restart_and_continue
    fi

    # Step 3: Rosetta
    if [ "$LAST_STEP" -lt 3 ]; then
        run_script_and_wait "${SCRIPT_DIR}/install_rosetta.mac.sh"
        mark_step_completed "3"
    fi

    # Step 4: Dev libs
    if [ "$LAST_STEP" -lt 4 ]; then
        run_script_and_wait "${SCRIPT_DIR}/install_dev_libs.mac.sh"
        mark_step_completed "4"
        restart_and_continue
    fi

    # Step 5: Chrome
    if [ "$LAST_STEP" -lt 5 ]; then
        run_script_and_wait "${SCRIPT_DIR}/install_chrome.mac.sh"
        mark_step_completed "5"
    fi

    # Step 6: Git
    if [ "$LAST_STEP" -lt 6 ]; then
        run_script_and_wait "${SCRIPT_DIR}/git.mac.sh"
        mark_step_completed "6"
        restart_and_continue
    fi

    # Step 7: Manual apps
    if [ "$LAST_STEP" -lt 7 ]; then
        run_script_and_wait "${SCRIPT_DIR}/install_manual.mac.sh"
        mark_step_completed "7"
    fi

    # Step 8: Fonts
    if [ "$LAST_STEP" -lt 8 ]; then
        run_script_and_wait "${SCRIPT_DIR}/fonts.mac.sh"
        mark_step_completed "8"
    fi

    # Step 9: Shell config
    if [ "$LAST_STEP" -lt 9 ]; then
        run_script_and_wait "${SCRIPT_DIR}/config_shell.mac.sh"
        mark_step_completed "9"
        restart_and_continue
    fi

    # Step 10: CLI tools
    if [ "$LAST_STEP" -lt 10 ]; then
        run_script_and_wait "${SCRIPT_DIR}/install_cli_tools.mac.sh"
        mark_step_completed "10"
        restart_and_continue
    fi

    # Step 11: Neovim
    if [ "$LAST_STEP" -lt 11 ]; then
        run_script_and_wait "${SCRIPT_DIR}/nvim.mac.sh"
        mark_step_completed "11"
    fi

    # Step 12: Wezterm
    if [ "$LAST_STEP" -lt 12 ]; then
        run_script_and_wait "${SCRIPT_DIR}/wezterm.mac.sh"
        mark_step_completed "12"
    fi

    # Step 13: GUI apps
    if [ "$LAST_STEP" -lt 13 ]; then
        run_script_and_wait "${SCRIPT_DIR}/install_gui_apps.mac.sh"
        mark_step_completed "13"
    fi

    # Step 14: ASDF
    if [ "$LAST_STEP" -lt 14 ]; then
        run_script_and_wait "${SCRIPT_DIR}/install_asdf.mac.sh"
        mark_step_completed "14"
    fi

    # Step 15: Dotbot
    if [ "$LAST_STEP" -lt 15 ]; then
        echo "Do you want to backup or restore dotfiles? (backup/restore)"
        read -r choice
        run_script_and_wait "${SCRIPT_DIR}/dotbot.mac.sh $choice"
        mark_step_completed "15"
    fi

    # Cleanup
    rm -f "$TEMP_DIR"
    echo "Installation completed!"
}

main
