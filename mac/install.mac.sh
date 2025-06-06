#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROGRESS_FILE="/tmp/postinstall_progress"

# Function to run script in new terminal tab
run_script_and_wait() {
    local script_path="$1"
    local temp_done_file="/tmp/script_done_$$_$(date +%s)"

    # Make script executable
    chmod +x "$script_path"

    if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
        osascript -e "tell application \"Terminal\"
            activate
            set currentTab to do script \"$script_path && touch $temp_done_file\"
            repeat
                delay 1
                if not busy of currentTab then
                    exit repeat
                end if
            end repeat
        end tell"
    elif [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
        osascript -e "tell application \"iTerm2\"
            tell current window
                create tab with default profile
                tell current session
                    write text \"$script_path && touch $temp_done_file\"
                end tell
            end tell
        end tell"
    fi

    # Wait for the script to complete
    while [ ! -f "$temp_done_file" ]; do
        echo "Waiting for ${script_path##*/} to complete..."
        sleep 2
    done

    # Cleanup
    rm -f "$temp_done_file"
    echo "${script_path##*/} completed!"
}

# Function to restart current terminal and continue script
restart_and_continue() {
    if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
        osascript -e "tell application \"Terminal\" to do script \"cd '$SCRIPT_DIR' && '$0'\""
    elif [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
        osascript -e "tell application \"iTerm2\"
            tell current window
                create tab with default profile
                tell current session
                    write text \"cd '$SCRIPT_DIR' && '$0'\"
                end tell
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
    rm -f "$PROGRESS_FILE"
    echo "Installation completed!"
}

main
