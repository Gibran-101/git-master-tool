#!/bin/bash

"$SCRIPT_DIR/lib/stash.sh"

# Validate input and set up logger
source ./common_utils.sh
source ./logger.sh

SCRIPT_NAME="$(basename "$0")"

# Save current changes to a stash
create_stash() {
    read -p " Enter stash message (optional): " stash_msg
    if [[ -n "$stash_msg" ]]; then
        git stash push -m "$stash_msg"
        log_json "SUCCESS" "$SCRIPT_NAME" "Created stash with message: $stash_msg"
    else
        git stash push
        log_json "SUCCESS" "$SCRIPT_NAME" "Created unnamed stash"
    fi
    echo " Changes stashed."
}

# List all stashes
list_stashes() {
    echo " Available stashes:"
    git stash list
    log_json "INFO" "$SCRIPT_NAME" "Listed all stashes"
}

# Apply a stash
apply_stash() {
    list_stashes
    stash_id=$(prompt_with_validation "Please enter stash identifier to apply (eg., stash@{0} ") || return 1
    git stash apply "$stash_id"
    echo " Stash $stash_id applied."
    log_json "SUCCESS" "$SCRIPT_NAME" "Applied stash: $stash_id"
}

# Drop a specific stash
drop_stash() {
    list_stashes
    stash_id=$(prompt_with_validation "Please enter stash identifier to drop (eg., stash@{0} ") || return 1
    git stash drop "$stash_id"
    echo " Stash $stash_id dropped."
    log_json "SUCCESS" "$SCRIPT_NAME" "Dropped stash: $stash_id"
}

# Clear all stashes
clear_stashes() {
    confirm=$(prompt_with_validation "Are you sure you want to clear all stashes (y/ n): ") || return 1
    if [[ "$confirm" == "y" ]]; then
        git stash clear
        echo " All stashes nuked."
        log_json "SUCCESS" "$SCRIPT_NAME" "Cleared all stashes"
    else
        echo " Operation cancelled."
        log_json "INFO" "$SCRIPT_NAME" "User canceled stash clear operation"
    fi
}

# Main stash menu
main_stash_menu() {
    echo ""
    echo "  Git Stash Management"
    echo "1. Create Stash"
    echo "2. List Stashes"
    echo "3. Apply a Stash"
    echo "4. Drop a Stash"
    echo "5. Clear All Stashes"
    echo "6. Exit"
    echo ""

    option=$(prompt_with_validation "Choose an option (1-6): ") || return 1

    case "$option" in
        1) create_stash ;;
        2) list_stashes ;;
        3) apply_stash ;;
        4) drop_stash ;;
        5) clear_stashes ;;
        6)
            echo " Bye stash master."
            log_json "INFO" "$SCRIPT_NAME" "Exited stash script"
            exit 0
            ;;
        *)
            echo " Invalid option. Pick between 1 and 6."
            log_json "ERROR" "$SCRIPT_NAME" "Invalid menu option: $option"
            ;;
    esac
}

# Run menu only if script is not being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_stash_menu
fi

