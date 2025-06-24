#!/bin/bash

# ─────────────────────────────────────────────────────
# Git Clone Utility
# Author: Gibran
# ─────────────────────────────────────────────────────

# Must be sourced with SCRIPT_DIR set
if [[ -z "$SCRIPT_DIR" ]]; then
    echo " ERROR: SCRIPT_DIR not set in clone.sh"
    return 1
fi

source "$SCRIPT_DIR/common_utils.sh"
source "$SCRIPT_DIR/logger.sh"

SCRIPT_NAME="clone.sh"

clone_master() {
    # -------------------------------
    #  Setup SSH agent
    # -------------------------------
    setup_ssh_agent() {
        echo " Setting up SSH agent..."
        eval "$(ssh-agent -s)" >/dev/null

        local ssh_key
        ssh_key=$(prompt_with_validation "Enter path to your SSH key (default: ~/.ssh/id_rsa)") || return 1
        ssh_key=${ssh_key:-~/.ssh/id_rsa}

        if [ -f "$ssh_key" ]; then
            ssh-add "$ssh_key"
            log_json "SUCCESS" "$SCRIPT_NAME" "SSH key added: $ssh_key"
        else
            echo "  SSH key not found at $ssh_key"
            echo "    Generate one with: ssh-keygen -t rsa"
            log_json "ERROR" "$SCRIPT_NAME" "SSH key not found at $ssh_key"
            return 1
        fi
    }

    # -------------------------------
    #  Clone Repo
    # -------------------------------
    local url_choice
    url_choice=$(prompt_with_validation "Choose URL format (https/ ssh): ") || return 1
    log_json "INFO" "$SCRIPT_NAME" "User selected URL format: $url_choice"

    if [[ "$url_choice" != "https" && "$url_choice" != "ssh" ]]; then
        echo " Invalid format. Choose either 'https' or 'ssh'."
        log_json "ERROR" "$SCRIPT_NAME" "Invalid URL format entered: $url_choice"
        return 1
    fi

    local url
    url=$(prompt_with_validation "Enter the Git repository URL to clone: ") || return 1
    log_json "INFO" "$SCRIPT_NAME" "Repository URL received for cloning"

    if [[ "$url_choice" == "ssh" ]]; then
        setup_ssh_agent || return 1
    fi

    echo " Cloning from: $url"
    if git clone "$url"; then
        echo "  Clone successful!"
        log_json "SUCCESS" "$SCRIPT_NAME" "Cloned repository from $url"
    else
        echo "  Clone failed. Check your URL or authentication method."
        log_json "ERROR" "$SCRIPT_NAME" "Failed to clone from $url"
        return 1
    fi
}

