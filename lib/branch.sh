#!/bin/bash

# ─────────────────────────────────────────────────────
# Git Branch Management Utility
# ─────────────────────────────────────────────────────

# Helper: Validate non-empty input
validator() {
    if [ -z "$1" ]; then
        echo "$2"
        return 1
    fi
}

# List all local branches
list_branches() {
    echo " Existing branches:"
    git branch --format="  %(refname:short)"
}

# Switch to a branch
switch_branch() {
    list_branches
    read -p " Enter the branch you want to switch to: " branch_name
    validator "$branch_name" " Please provide a branch name." || return 1

    if git rev-parse --verify "$branch_name" >/dev/null 2>&1; then
        git switch "$branch_name"
        echo " Switched to '$branch_name'"
    else
        echo " Branch '$branch_name' does not exist."
    fi
}

# Create a new branch and optionally switch to it
create_branch() {
    read -p " Enter the new branch name: " new_branch
    validator "$new_branch" " Branch name can't be empty." || return 1

    git checkout -b "$new_branch"
    echo " Created branch '$new_branch'"

    read -p "➡️  Switch to '$new_branch' now? (yes/no): " response
    [[ "$response" == "yes" ]] && git switch "$new_branch"
}

# Delete a branch
delete_branch() {
    list_branches
    read -p " Enter the branch name to delete: " branch_to_delete
    validator "$branch_to_delete" " Please provide a branch name." || return 1

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
    read -p " Enter the base branch (merge INTO): " base
    read -p " Enter the feature branch (merge FROM): " feature

    validator "$base" " Base branch is required." || return 1
    validator "$feature" " Feature branch is required." || return 1

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
    read -p "✏️  Enter current branch name: " old
    validator "$old" " Current name required." || return 1

    read -p "➡️  Enter new branch name: " new
    validator "$new" " New name required." || return 1

    if git rev-parse --verify "$old" >/dev/null 2>&1; then
        git branch -m "$old" "$new"
        echo " Renamed '$old' to '$new'"
    else
        echo " Branch '$old' does not exist."
    fi
}

# Main menu handler (for standalone use only)
main_logs_menu() {
    current_branch=$(git branch --show-current)
    echo " You are currently on: $current_branch"
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

    read -p " Enter your choice (1-7): " option
    echo

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

