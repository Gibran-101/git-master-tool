#!/bin/bash

# ─────────────────────────────────────────────────────
# Git Clone Utility
# Author: Gibran (aka "The Git Whisperer")
# ─────────────────────────────────────────────────────

# Run SSH setup if needed
setup_ssh_agent() {
    echo " Setting up SSH agent..."
    eval "$(ssh-agent -s)" >/dev/null

    read -p "  Enter path to your private SSH key (default: ~/.ssh/id_rsa): " ssh_key
    ssh_key=${ssh_key:-~/.ssh/id_rsa}

    if [ -f "$ssh_key" ]; then
        ssh-add "$ssh_key"
    else
        echo " SSH key not found at $ssh_key"
        echo " Fix the path or generate a key using: ssh-keygen -t rsa"
        return 1
    fi
}

# Perform the clone
clone_repo() {
    read -p " Choose URL format (https/ssh): " url_choice

    if [[ "$url_choice" != "https" && "$url_choice" != "ssh" ]]; then
        echo " Invalid format. Choose either 'https' or 'ssh'."
        return 1
    fi

    read -p " Enter the Git repository URL to clone: " url
    if [[ -z "$url" ]]; then
        echo " Repository URL cannot be empty."
        return 1
    fi

    if [[ "$url_choice" == "ssh" ]]; then
        setup_ssh_agent || return 1
    fi

    echo " Cloning from: $url"
    if git clone "$url"; then
        echo " Clone successful!"
    else
        echo " Clone failed. Check your URL or authentication method."
        return 1
    fi
}

# Run directly only if script is not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    clone_repo
fi

