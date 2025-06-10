#!/bin/bash

# Validate that input is not empty
validator() {
    if [ -z "$1" ]; then
        echo "$2"
        return 1
    fi
}

# List all branches
list_branches() {
    echo " Existing branches:"
    git branch --format="  %(refname:short)"
}

# Switch to a specific branch
switch_branch() {
    list_branches
    read -p "➡️ Enter the branch you want to switch to: " branch_name
    validator "$branch_name" " Please provide a branch name." || return 1

    if git rev-parse --verify "$branch_name" >/dev/null 2>&1; then
        git switch "$branch_name"
        echo " Switched to $branch_name"
    else
        echo " Branch '$branch_name' does not exist."
        return 1
    fi
}

# Create a new branch
create_branch() {
    read -p " Enter the new branch name: " new_branch
    validator "$new_branch" " Branch name can't be empty." || return 1

    git checkout -b "$new_branch"
    echo " Created branch $new_branch"

    read -p " Switch to $new_branch now? (yes/no): " response
    if [[ "$response" == "yes" ]]; then
        git switch "$new_branch"
    fi
}

# Delete a branch
delete_branch() {
    list_branches
    read -p " Enter the branch name to delete: " branch_to_delete
    validator "$branch_to_delete" " Please provide a branch name." || return 1

    if git rev-parse --verify "$branch_to_delete" >/dev/null 2>&1; then
        read -p "⚠️ Are you sure you want to delete '$branch_to_delete'? Type 'yes' to confirm: " confirm
        if [[ "$confirm" == "yes" ]]; then
            git branch -d "$branch_to_delete"
            echo " Branch '$branch_to_delete' deleted."
        else
            echo " Deletion cancelled."
        fi
    else
        echo " Branch '$branch_to_delete' does not exist."
        return 1
    fi
}

# Merge one branch into another
merge_branches() {
    list_branches
    read -p " Enter the base branch (where you want to merge *into*): " base_branch
    read -p " Enter the feature branch (you want to merge *from*): " feature_branch

    validator "$base_branch" " Base branch is required." || return 1
    validator "$feature_branch" " Feature branch is required." || return 1

    if [[ "$base_branch" == "$feature_branch" ]]; then
        echo " Base and feature branches cannot be the same."
        return 1
    fi

    # Verify both branches exist
    if ! git rev-parse --verify "$base_branch" >/dev/null 2>&1 || \
       ! git rev-parse --verify "$feature_branch" >/dev/null 2>&1; then
        echo " One or both branches do not exist."
        return 1
    fi

    git switch "$base_branch"
    git merge "$feature_branch"
    echo " Merged '$feature_branch' into '$base_branch'"
}

# Rename a branch
rename_branch() {
    list_branches
    read -p "✏️ Enter the current branch name to rename: " old_name
    validator "$old_name" " Please provide the current branch name." || return 1

    read -p " Enter the new name: " new_name
    validator "$new_name" " Please provide a new name." || return 1

    if git rev-parse --verify "$old_name" >/dev/null 2>&1; then
        git branch -m "$old_name" "$new_name"
        echo " Branch '$old_name' renamed to '$new_name'"
    else
        echo " Branch '$old_name' does not exist."
        return 1
    fi
}

# Get current branch and display
current_branch=$(git branch --show-current)
echo " You are currently on branch: $current_branch"
echo

# Show menu options
echo "Branch Management Options:"
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

# Handle user choice
case "$option" in
    1) create_branch ;;
    2) switch_branch ;;
    3) list_branches ;;
    4) delete_branch ;;
    5) merge_branches ;;
    6) rename_branch ;;
    7)
        echo " Exiting branch manager."
        exit 0
        ;;
    *)
        echo " Invalid option. Please choose between 1 and 7."
        ;;
esac

