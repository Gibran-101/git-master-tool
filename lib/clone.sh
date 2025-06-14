#!/bin/bash

# ─────────────────────────────────────────────────────
# Git Clone Utility
# Author: Gibran
# ─────────────────────────────────────────────────────

source ./common_utils.sh
source ./logger.sh

SCRIPT_NAME="$(basename "$0")"

# Run SSH setup if needed
setup_ssh_agent() {
    echo " Setting up SSH agent..."
    eval "$(ssh-agent -s)" >/dev/null

    read -p "  Enter path to your private SSH key (default: ~/.ssh/id_rsa): " ssh_key
    ssh_key=${ssh_key:-~/.ssh/id_rsa}

    if [ -f "$ssh_key" ]; then
        ssh-add "$ssh_key"
        log_json "SUCCESS" "$SCRIPT_NAME" "SSH key added: $ssh_key"
    else
        echo " SSH key not found at $ssh_key"
        echo " Fix the path or generate a key using: ssh-keygen -t rsa"
        log_json "ERROR" "$SCRIPT_NAME" "SSH key not found at $ssh_key"
        return 1
    fi
}

# Perform the clone
clone_repo() {
    url_choice=$(prompt_with_validation "Choose URL format (https/ ssh): ") || return 1
    log_json "INFO" "$SCRIPT_NAME" "User selected URL format: $url_choice"

    if [[ "$url_choice" != "https" && "$url_choice" != "ssh" ]]; then
        echo " Invalid format. Choose either 'https' or 'ssh'."
        log_json "ERROR" "$SCRIPT_NAME" "Invalid URL format entered: $url_choice"
        return 1
    fi

    url=$(prompt_with_validation "Enter the Git repository URL to clone: ") || return 1
    log_json "INFO" "$SCRIPT_NAME" "Repository URL received for cloning"

    if [[ "$url_choice" == "ssh" ]]; then
        setup_ssh_agent || return 1
    fi

    echo " Cloning from: $url"
    if git clone "$url"; then
        echo " Clone successful!"
        log_json "SUCCESS" "$SCRIPT_NAME" "Cloned repository from $url"
    else
        echo " Clone failed. Check your URL or authentication method."
        log_json "ERROR" "$SCRIPT_NAME" "Failed to clone from $url"
        return 1
    fi
}

# Run directly only if script is not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    clone_repo
fi

