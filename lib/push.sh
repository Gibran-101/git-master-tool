#!/bin/bash

# 💡 Validator to check if input is empty
validate_input() {
    if [ -z "$1" ]; then
        echo " $2"
        return 1
    fi
}

# 🧠 Check if 'origin' already set
ensure_remote_origin() {
    if git remote get-url origin >/dev/null 2>&1; then
        echo " Remote 'origin' already exists. Skipping add."
    else
        git remote add origin "$1"
        echo " Remote 'origin' set to $1"
    fi
}

# 🚀 Setup for brand new repo
init_new_repo() {
    echo "🛠️ Initializing a new Git repository..."
    git init

    read -p " Enter the files to add (space-separated): " files_to_add
    validate_input "$files_to_add" "Please provide files to add." || return 1

    for file in $files_to_add; do
        if [ ! -e "$file" ]; then
            echo " File '$file' does not exist."
            return 1
        fi
    done

    git add $files_to_add

    read -p " Enter commit message: " commit_msg
    validate_input "$commit_msg" "Commit message can't be empty." || return 1
    git commit -m "$commit_msg"

    git branch -M main

    read -p " Choose URL format (https/ssh): " url_format
    if [[ "$url_format" != "https" && "$url_format" != "ssh" ]]; then
        echo " Invalid URL format. Use 'https' or 'ssh'."
        return 1
    fi

    read -p " Enter the remote repo URL: " repo_url
    validate_input "$repo_url" "Remote URL can't be empty." || return 1
    ensure_remote_origin "$repo_url"

    if [[ "$url_format" == "ssh" ]]; then
        eval "$(ssh-agent -s)" >/dev/null
        read -p " Enter SSH private key path (default: ~/.ssh/id_rsa): " ssh_key
        ssh_key=${ssh_key:-~/.ssh/id_rsa}
        ssh-add "$ssh_key" 2>/dev/null || echo "⚠️ Failed to add SSH key. Make sure the path is correct."
    fi

    git push -u origin main || {
        echo " Push failed. Check URL or authentication."
        return 1
    }

    echo " Repository initialized and pushed successfully!"
}

# 🧑‍ Commit and push for existing repo
push_existing_repo() {
    echo " Choose how to add files:"
    echo "1. Add all (git add .)"
    echo "2. Add only tracked changes (git add -u)"
    echo "3. Add specific files"
    read -p "Your choice (1/2/3): " add_mode

    case "$add_mode" in
        1) git add . ;;
        2) git add -u ;;
        3)
            read -p "Enter filenames (space-separated): " file_list
            validate_input "$file_list" "Please provide files to add." || return 1
            git add $file_list
            ;;
        *)
            echo " Invalid choice. Aborting."
            return 1
            ;;
    esac

    read -p " Enter commit message: " commit_msg
    validate_input "$commit_msg" "Commit message can't be empty." || return 1
    git commit -m "$commit_msg"

    current_branch=$(git branch --show-current)
    git push origin "$current_branch" || {
        echo " Push failed. Check branch or remote."
        return 1
    }

    echo " Changes pushed to branch '$current_branch'."
}

# 🔁 Entrypoint
main() {
    read -p " Enter '1' to create a new repo, '0' to use an existing one: " user_choice

    if [[ "$user_choice" == "1" ]]; then
        init_new_repo
    elif [[ "$user_choice" == "0" ]]; then
        push_existing_repo
    else
        echo " Invalid input. Please enter 1 or 0."
        return 1
    fi

    # Final success/failure message
    if [ $? -eq 0 ]; then
        echo " Push operation completed successfully."
    else
        echo " Push operation failed. Check the above messages."
    fi
}

# 🚨 Script starts here
main

