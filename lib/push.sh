#!/bin/bash

source ./logger.sh
source ./common_utils.sh

# 🧠 Check if 'origin' already set
ensure_remote_origin() {
    if git remote get-url origin >/dev/null 2>&1; then
        log_json "INFO" "$(basename "$0")" "Remote 'origin' already exists. Skipping add."
        echo " Remote 'origin' already exists. Skipping add."
    else
        git remote add origin "$1"
        echo " Remote 'origin' set to $1"
        log_json "INFO" "$(basename "$0")" "Remote 'origin' set to $1"
    fi
}

# 🚀 Setup for brand new repo
init_new_repo() {
    log_json "INFO" "$(basename "$0")" "Initializing new Git repo..."
    echo " Initializing a new Git repository..."
    git init

    git status

    files_to_add=$(prompt_with_validation "Enter the files to add (space-separated) ") || {
        log_json "ERROR" "$(basename "$0")" "File prompt failed"
        return 1
    }

    for file in $files_to_add; do
        if [ ! -e "$file" ]; then
            echo " File '$file' does not exist."
            log_json "ERROR" "$(basename "$0")" "File '$file' does not exist"
            return 1
        fi
    done

    git add $files_to_add

    commit_msg=$(prompt_with_validation "Enter commit message: ") || {
        log_json "ERROR" "$(basename "$0")" "Commit message prompt failed"
        return 1
    }
    git commit -m "$commit_msg"
    log_json "INFO" "$(basename "$0")" "Committed changes"

    branch_response=$(prompt_with_validation "The default branch name is 'master'. Do you want to change it (y/ n): ") || return 1
    if [[ "$branch_response" =~ ^[Yy]$ ]]; then
        new_branch=$(prompt_with_validation "Enter desired branch name: ") || return 1
        branch_name=$new_branch
        git branch -M "$new_branch"
        log_json "INFO" "$(basename "$0")" "Branch renamed to $new_branch"
    else
        branch_name="master"
        git branch -M master
        log_json "INFO" "$(basename "$0")" "Branch name set to default 'master'"
    fi

    read -p " Choose URL format (https/ssh): " url_format
    if [[ "$url_format" != "https" && "$url_format" != "ssh" ]]; then
        echo " Invalid URL format. Use 'https' or 'ssh'."
        log_json "ERROR" "$(basename "$0")" "Invalid URL format: $url_format"
        return 1
    fi

    repo_url=$(prompt_with_validation "Enter the remote repo URL: ") || {
        log_json "ERROR" "$(basename "$0")" "Repo URL prompt failed"
        return 1
    }

    ensure_remote_origin "$repo_url"

    if [[ "$url_format" == "ssh" ]]; then
        eval "$(ssh-agent -s)" >/dev/null
        read -p " Enter SSH private key path (default: ~/.ssh/id_rsa): " ssh_key
        ssh_key=${ssh_key:-~/.ssh/id_rsa}
        ssh-add "$ssh_key" 2>/dev/null || {
            echo "  Failed to add SSH key. Make sure the path is correct."
            log_json "ERROR" "$(basename "$0")" "SSH key add failed at $ssh_key"
        }
    fi

    git push -u origin $branch_name || {
        echo " Push failed. Check URL or authentication."
        log_json "ERROR" "$(basename "$0")" "Push failed to origin/$branch_name"
        return 1
    }

    echo " Repository initialized and pushed successfully!"
    log_json "SUCCESS" "$(basename "$0")" "Repo initialized and pushed to origin/$branch_name"
}

# 🧑‍💻 Commit and push for existing repo
push_existing_repo() {
    log_json "INFO" "$(basename "$0")" "Using existing repo flow"
    echo " Choose how to add files:"
    echo "1. Add all (git add .)"
    echo "2. Add only tracked changes (git add -u)"
    echo "3. Add specific files"
    read -p "Your choice (1/2/3): " add_mode

    case "$add_mode" in
        1) git add . ;;
        2) git add -u ;;
        3)
            git status
            file_list=$(prompt_with_validation "Enter filenames (space-separated): ") || return 1
            git add $file_list
            ;;
        *)
            echo " Invalid choice. Aborting."
            log_json "ERROR" "$(basename "$0")" "Invalid add mode choice: $add_mode"
            return 1
            ;;
    esac

    commit_msg=$(prompt_with_validation "Enter commit message: ") || {
        log_json "ERROR" "$(basename "$0")" "Commit message prompt failed"
        return 1
    }
    git commit -m "$commit_msg"
    log_json "INFO" "$(basename "$0")" "Committed changes in existing repo"

    current_branch=$(git branch --show-current)
    git push origin "$current_branch" || {
        echo " Push failed. Check branch or remote."
        log_json "ERROR" "$(basename "$0")" "Push failed to origin/$current_branch"
        return 1
    }

    echo " Changes pushed to branch '$current_branch'."
    log_json "SUCCESS" "$(basename "$0")" "Pushed to branch $current_branch"
}

# 🔁 Entrypoint
main() {
    log_json "INFO" "$(basename "$0")" "Script started"
    read -p " Enter '1' to create a new repo, '0' to use an existing one: " user_choice

    if [[ "$user_choice" == "1" ]]; then
        init_new_repo
    elif [[ "$user_choice" == "0" ]]; then
        push_existing_repo
    else
        echo " Invalid input. Please enter 1 or 0."
        log_json "ERROR" "$(basename "$0")" "Invalid main choice: $user_choice"
        return 1
    fi

    if [ $? -eq 0 ]; then
        echo " Push operation completed successfully."
    else
        echo " Push operation failed. Check the above messages."
        log_json "ERROR" "$(basename "$0")" "Push operation failed"
    fi
}

# 🚨 Script starts here
main

