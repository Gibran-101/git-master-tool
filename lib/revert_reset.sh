#!/bin/bash

# -------------------------
# Revert & Reset Utility
# Author: Gibran
# -------------------------

source ./common_utils.sh
source ./logger.sh

SCRIPT_NAME="$(basename "$0")"

# Show recent commits in a friendly format
show_commits() {
    echo "Recent commits:"
    git log --oneline --graph --decorate --all -n 10
    log_json "INFO" "$SCRIPT_NAME" "Displayed last 10 commits"
}

# Reset to a specific commit
reset_commit() {
    show_commits

    commit_hash=$(prompt_with_validation "Please enter commit hash to reset ") || return 1
    log_json "INFO" "$SCRIPT_NAME" "User selected commit $commit_hash to reset"

    echo "Choose reset type:"
    echo "1. Soft Reset (keep changes)"
    echo "2. Mixed Reset (reset index, keep working directory)"
    echo "3. Hard Reset (dangerous: wipe all local changes)"

    reset_type=$(prompt_with_validation "Please enter your choice: ") || return 1

    case "$reset_type" in
        1)
            git reset --soft "$commit_hash"
            echo " Soft reset completed."
            log_json "SUCCESS" "$SCRIPT_NAME" "Performed soft reset to $commit_hash"
            ;;
        2)
            git reset --mixed "$commit_hash"
            echo " Mixed reset completed."
            log_json "SUCCESS" "$SCRIPT_NAME" "Performed mixed reset to $commit_hash"
            ;;
        3)
            stash_answer=$(prompt_with_validation "Do you want to stash changes before hard reset? (y/ n) ") || return 1
            if [[ "$stash_answer" == "y" ]]; then
                git stash
                echo "Changes stashed SUCCESSFULLY"
                log_json "INFO" "$SCRIPT_NAME" "Changes stashed before hard reset"
            fi
            git reset --hard "$commit_hash"
            echo " Hard reset completed. All local changes gone."
            log_json "SUCCESS" "$SCRIPT_NAME" "Performed hard reset to $commit_hash"
            ;;
        *)
            echo " Invalid reset option."
            log_json "ERROR" "$SCRIPT_NAME" "Invalid reset option selected: $reset_type"
            ;;
    esac
}

# Revert a specific commit
revert_commit() {
    show_commits
    revert_hash=$(prompt_with_validation "Please enter commit hash to revert ") || return 1
    log_json "INFO" "$SCRIPT_NAME" "Attempting to revert commit $revert_hash"

    if git revert "$revert_hash"; then
        echo " Commit successfully reverted."
        log_json "SUCCESS" "$SCRIPT_NAME" "Reverted commit $revert_hash"
    else
        echo " Revert may have failed due to conflicts. Resolve them manually."
        log_json "WARNING" "$SCRIPT_NAME" "Revert failed or encountered conflicts for $revert_hash"
    fi
}

# Undo the last commit
undo_last_commit() {
    echo "Choose undo option:"
    echo "1. Undo last commit (keep changes)"
    echo "2. Undo last commit (discard changes)"

    undo_choice=$(prompt_with_validation "Please enter your choice: ") || return 1

    case "$undo_choice" in
        1)
            git reset --soft HEAD~1
            echo " Last commit undone, changes preserved."
            log_json "SUCCESS" "$SCRIPT_NAME" "Soft undo of last commit"
            ;;
        2)
            git reset --hard HEAD~1
            echo " Last commit and changes discarded."
            log_json "SUCCESS" "$SCRIPT_NAME" "Hard undo of last commit"
            ;;
        *)
            echo " Invalid choice."
            log_json "ERROR" "$SCRIPT_NAME" "Invalid undo option: $undo_choice"
            ;;
    esac
}

# =============================
# Menu for Reset & Revert Ops
# =============================
main_revert_menu() {
    echo ""
    echo "Git Revert & Reset Menu"
    echo "1. Reset to a Commit"
    echo "2. Revert a Commit"
    echo "3. Undo Last Commit"
    echo "4. Exit"
    echo ""

    user_choice=$(prompt_with_validation "Please choose an option (1-4) ") || return 1

    case "$user_choice" in
        1) reset_commit ;;
        2) revert_commit ;;
        3) undo_last_commit ;;
        4)
            echo " Exiting revert/reset menu."
            log_json "INFO" "$SCRIPT_NAME" "Exited revert/reset script"
            exit 0
            ;;
        *)
            echo " Invalid option. Choose between 1-4."
            log_json "ERROR" "$SCRIPT_NAME" "Invalid main menu selection: $user_choice"
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_revert_menu
fi

