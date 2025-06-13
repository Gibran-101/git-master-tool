#!/bin/bash

# -------------------------
# Revert & Reset Utility
# Author: Gibran 
# -------------------------

# Input Validator
source ./common_utils.sh

# Show recent commits in a friendly format
show_commits() {
    echo "Recent commits:"
    git log --oneline --graph --decorate --all -n 10
}

# Reset to a specific commit
reset_commit() {
    show_commits

    commit_hash=$(prompt_with_validation "Please enter commit hash to reset ") || return 1

    echo "Choose reset type:"
    echo "1. Soft Reset (keep changes)"
    echo "2. Mixed Reset (reset index, keep working directory)"
    echo "3. Hard Reset (dangerous: wipe all local changes)"
   
    reset_type=$(prompt_with_validation "Please enter your choice: ") || return 1

    case "$reset_type" in
        1)
            git reset --soft "$commit_hash"
            echo " Soft reset completed."
            ;;
        2)
            git reset --mixed "$commit_hash"
            echo " Mixed reset completed."
            ;;
        3)
	    stash_answer=$(prompt_with_validation "Do you want to stash changes before hard reset? (y/ n) ") || return 1
          
	    [[ "$stash_answer" == "y" ]] && git stash && echo "Changes stashed SUCCESSFULLY"
            git reset --hard "$commit_hash"
            echo " Hard reset completed. All local changes gone."
            ;;
        *)
            echo " Invalid reset option."
            ;;
    esac
}

# Revert a specific commit
revert_commit() {
    show_commits
    revert_hash=$(prompt_with_validation "Please enter commit hash to revert ") || return 1

    if git revert "$revert_hash"; then
        echo " Commit successfully reverted."
    else
        echo " Revert may have failed due to conflicts. Resolve them manually."
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
            ;;
        2)
            git reset --hard HEAD~1
            echo " Last commit and changes discarded."
            ;;
        *)
            echo " Invalid choice."
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
            exit 0
            ;;
        *)
            echo " Invalid option. Choose between 1-4."
            ;;
    esac
}

# Only execute if run directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_revert_menu
fi

