#!/bin/bash

#  Validator to ensure input isn't empty
validator() {
    if [ -z "$1" ]; then
        echo "$2"
        return 1
    fi
}

#  Show recent commits in a friendly format
show_commits() {
    echo "Recent commits:"
    git log --oneline --graph --decorate --all -n 10
}

#  Reset to a specific commit
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
            ;;
        2)
            git reset --mixed "$commit_hash"
            ;;
        3)
            read -p "Do you want to stash changes before hard reset? (yes/no): " stash_answer
            if [[ "$stash_answer" == "yes" ]]; then
                git stash
                echo "✔Changes stashed."
            fi
            git reset --hard "$commit_hash"
            ;;
        *)
            echo " Invalid reset option."
            ;;
    esac
}

# ↩️ Revert a specific commit
revert_commit() {
    show_commits
    read -p "Enter the commit hash you want to revert: " revert_hash
    validator "$revert_hash" " Commit hash cannot be empty" || return 1

    git revert "$revert_hash" || echo "⚠️ Revert may have failed due to merge conflicts. Resolve manually."
}

#  Undo the last commit
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
            echo "⚠️ Last commit and changes discarded."
            ;;
        *)
            echo " Invalid choice"
            ;;
    esac
}

#  Main menu
main_menu() {
    while true; do
        echo ""
        echo "===== Git Revert & Reset Menu ====="
        echo "1. Reset to specific commit"
        echo "2. Revert a commit"
        echo "3. Undo last commit"
        echo "4. View recent commits"
        echo "5. Exit"
        read -p "Choose an option: " choice

        case "$choice" in
            1) reset_commit ;;
            2) revert_commit ;;
            3) undo_last_commit ;;
            4) show_commits ;;
            5)
                echo " Exiting revert_reset.sh. Stay safe."
                break
                ;;
            *)
                echo " Invalid option. Please try again."
                ;;
        esac
    done
}

# 🚀 Launch the menu
main_menu

