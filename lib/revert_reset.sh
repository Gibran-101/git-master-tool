#!/bin/bash

# -------------------------
# Revert & Reset Utility
# Author: Gibran the Commit Slayer
# -------------------------

# Validator to ensure input isn't empty
validator() {
    if [ -z "$1" ]; then
        echo "$2"
        return 1
    fi
}

# Show recent commits in a friendly format
show_commits() {
    echo "Recent commits:"
    git log --oneline --graph --decorate --all -n 10
}

# Reset to a specific commit
reset_commit() {
    show_commits
    read -p "Enter commit hash to reset to: " commit_hash
    validator "$commit_hash" " Commit hash cannot be empty" || return 1

    echo "Choose reset type:"
    echo "1. Soft Reset (keep changes)"
    echo "2. Mixed Reset (reset index, keep working directory)"
    echo "3. Hard Reset (dangerous: wipe all local changes)"
    read -p "Your choice: " reset_type

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
            read -p "Do you want to stash changes before hard reset? (yes/no): " stash_answer
            if [[ "$stash_answer" == "yes" ]]; then
                git stash
                echo " Changes stashed."
            fi
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
    read -p "Enter the commit hash you want to revert: " revert_hash
    validator "$revert_hash" " Commit hash cannot be empty" || return 1

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
    read -p "Your choice: " undo_choice

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

    read -p "Choose an option (1-4): " user_choice

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

