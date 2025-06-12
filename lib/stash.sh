#!/bin/bash

# Validate input
validator() {
    if [ -z "$1" ]; then
        echo " $2"
        return 1
    fi
}

# Save current changes to a stash
create_stash() {
    read -p " Enter stash message (optional): " stash_msg
    if [[ -n "$stash_msg" ]]; then
        git stash push -m "$stash_msg"
    else
        git stash push
    fi
    echo " Changes stashed."
}

# List all stashes
list_stashes() {
    echo " Available stashes:"
    git stash list
}

# Apply a stash
apply_stash() {
    list_stashes
    read -p " Enter stash identifier to apply (e.g., stash@{0}): " stash_id
    validator "$stash_id" " Stash ID cannot be empty." || return 1
    git stash apply "$stash_id"
    echo " Stash $stash_id applied."
}

# Drop a specific stash
drop_stash() {
    list_stashes
    read -p " Enter stash identifier to drop (e.g., stash@{0}): " stash_id
    validator "$stash_id" " Stash ID cannot be empty." || return 1
    git stash drop "$stash_id"
    echo " Stash $stash_id dropped."
}

# Clear all stashes
clear_stashes() {
    read -p " Are you sure you want to clear all stashes? (yes/no): " confirm
    if [[ "$confirm" == "yes" ]]; then
        git stash clear
        echo " All stashes nuked."
    else
        echo " Operation cancelled."
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

    read -p " Choose an option (1-6): " option

    case "$option" in
        1) create_stash ;;
        2) list_stashes ;;
        3) apply_stash ;;
        4) drop_stash ;;
        5) clear_stashes ;;
        6)
            echo " Bye stash master."
            exit 0
            ;;
        *)
            echo " Invalid option. Pick between 1 and 6."
            ;;
    esac
}

# Run menu only if script is not being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_stash_menu
fi

