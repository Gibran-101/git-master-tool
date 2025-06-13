#!/bin/bash

# ─────────────────────────────────────────────────────
# Git Branch Management Utility
# ─────────────────────────────────────────────────────

# Helper: Validate non-empty input
source ./common_utils.sh

# List all local branches
list_branches() {
    echo " Existing branches:"
    git branch --format="  %(refname:short)"
}

# Switch to a branch
switch_branch() {
    list_branches
    branch_name=$(prompt_with_validation "Enter the branch name to be switched: ") || return 1

    if git rev-parse --verify "$branch_name" >/dev/null 2>&1; then
        git switch "$branch_name"
        echo " Switched to '$branch_name'"
    else
        echo " Branch '$branch_name' does not exist."
    fi
}

# Create a new branch and optionally switch to it
create_branch() {
    new_branch=$(prompt_with_validation "Enter the new branch name ") || return 1

    git checkout -b "$new_branch"
    echo " Created branch '$new_branch'"

    read -p "➡️  Switch to '$new_branch' now? (yes/no): " response
    [[ "$response" == "yes" ]] && git switch "$new_branch"
}

# Delete a branch
delete_branch() {
    list_branches
    branch_to_delete=$(prompt_with_validation "Ente the branch name to be deleted ") || return 1

    if git rev-parse --verify "$branch_to_delete" >/dev/null 2>&1; then
        read -p "⚠️  Confirm deletion of '$branch_to_delete'? (yes): " confirm
        [[ "$confirm" == "yes" ]] && git branch -d "$branch_to_delete" && echo "✅ Deleted '$branch_to_delete'" || echo "❌ Deletion cancelled."
    else
        echo " Branch '$branch_to_delete' does not exist."
    fi
}

# Merge feature branch into base branch
merge_branches() {
    list_branches

    base=$(prompt_with_validation "Please enter the base branch name (merge INTO) ") || return 1
    feature=$(prompt_with_validation "Please enter the feature branch name (merge FROM) ") || return 1

    if [[ "$base" == "$feature" ]]; then
        echo " Base and feature branches cannot be the same."
        return 1
    fi

    if git rev-parse --verify "$base" >/dev/null 2>&1 && git rev-parse --verify "$feature" >/dev/null 2>&1; then
        git switch "$base"
        git merge "$feature"
        echo " Merged '$feature' into '$base'"
    else
        echo " One or both branches do not exist."
    fi
}

# Rename a branch
rename_branch() {
    list_branches

    old_name=$(prompt_with_validation "Please enter the name of the branch to be renamed ") || return 1

    new_name=$(prompt_with_validation "Please enter the new name for the exisiting branch ") || return 1

    if git rev-parse --verify "$old_name" >/dev/null 2>&1; then
        git branch -m "$old_name" "$new_name"
        echo " Renamed '$old_name' to '$new_name'"
    else
        echo " Branch '$old_name' does not exist."
    fi
}

# Main menu handler (for standalone use only)
main_logs_menu() {
    current_branch=$(git branch --show-current)
    echo " You are currently on: $current_branch branch"
    echo
    echo " Branch Management Options:"
    echo "1. Create a New Branch"
    echo "2. Switch to an Existing Branch"
    echo "3. List All Branches"
    echo "4. Delete a Branch"
    echo "5. Merge Branches"
    echo "6. Rename a Branch"
    echo "7. Exit"
    echo

    option=$(prompt_with_validation "Please select a option (1 - 7) ") || return 1

    case "$option" in
        1) create_branch ;;
        2) switch_branch ;;
        3) list_branches ;;
        4) delete_branch ;;
        5) merge_branches ;;
        6) rename_branch ;;
        7) echo " Exiting branch manager." && exit 0 ;;
        *) echo " Invalid option. Choose between 1–7." ;;
    esac
}

# Run main menu if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_logs_menu
fi

