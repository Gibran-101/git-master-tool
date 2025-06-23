#!/bin/bash

# ==========================================
# Git Audit Utility Script
# Author: Gibran
# ==========================================

# Optional, only if this file gets called from a wrapper
# "$SCRIPT_DIR/lib/audit.sh"

source "$SCRIPT_DIR/../common_utils.sh"
source "$SCRIPT_DIR/../logger.sh"

SCRIPT_NAME="$(basename "$0")"

# Ensure we're in a Git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo " Not a Git repository. Initialize or cd into one first."
    log_json "ERROR" "$SCRIPT_NAME" "Attempted audit outside a Git repo"
    exit 1
fi
log_json "INFO" "$SCRIPT_NAME" "Inside a valid Git repository"

#  Top Contributors
top_contributors() {
    echo "‍ Top Contributors:"
    git shortlog -s -n
    log_json "INFO" "$SCRIPT_NAME" "Displayed top contributors"
}

#  Most Frequently Committed Files
most_committed_file() {
    echo " Most Frequently Committed Files:"
    git log --name-only --pretty=format: | sort | uniq -c | sort -nr | head -n 10
    log_json "INFO" "$SCRIPT_NAME" "Displayed most frequently committed files"
}

#  Commit Frequency Over Time
commit_frequency() {
    echo " Commit Activity Report (most active days):"
    git log --date=short --pretty=format:"%ad" | sort | uniq -c | sort -nr | head
    log_json "INFO" "$SCRIPT_NAME" "Displayed commit frequency report"
}

#  Frequently Changed Files (commit stats)
frequent_commit_files() {
    echo " Files frequently modified in commits:"
    git log --pretty=format:"%h - %an" --shortstat | grep "files changed"
    log_json "INFO" "$SCRIPT_NAME" "Displayed frequent file change stats"
}

#  Combined Status Report (Uncommitted + Remote Sync)
repo_status_report() {
    echo " Current Repo Status:"
    git status --short
    echo ""
    echo " Local vs Remote Sync:"
    git status -sb
    log_json "INFO" "$SCRIPT_NAME" "Displayed working directory + sync status"
}

#  Merged vs Unmerged Branch Health Check
branch_health_check() {
    echo " Branch Health Check:"
    echo "  1. View merged branches"
    echo "  2. View unmerged branches"
    user_choice=$(prompt_with_validation "Your choice (1/2): ") || return 1

    if [[ "$user_choice" == "1" ]]; then
        git branch --merged
        log_json "INFO" "$SCRIPT_NAME" "Displayed merged branches"
    elif [[ "$user_choice" == "2" ]]; then
        git branch --no-merged
        log_json "INFO" "$SCRIPT_NAME" "Displayed unmerged branches"
    else
        echo " Invalid input"
        log_json "ERROR" "$SCRIPT_NAME" "Invalid input for branch health check: $user_choice"
    fi
}

#  Menu for Audit
main_audit_menu() {
    echo
    echo "Audit Management Options:"
    echo "1. Top Contributors"
    echo "2. Most Committed Files"
    echo "3. Commit Activity Report"
    echo "4. File Change Stats"
    echo "5. Repository Status Report"
    echo "6. Branch Health Check"
    echo "7. Exit Audit Manager"
    echo

    option=$(prompt_with_validation "Select an option (1 - 7): ") || return 1
    log_json "INFO" "$SCRIPT_NAME" "User selected option $option"

    case "$option" in
        1) top_contributors ;;
        2) most_committed_file ;;
        3) commit_frequency ;;
        4) frequent_commit_files ;;
        5) repo_status_report ;;
        6) branch_health_check ;;
        7)
            echo " Exiting Audit Manager."
            log_json "INFO" "$SCRIPT_NAME" "User exited audit manager"
            exit 0
            ;;
        *)
            echo " Invalid option. Please choose 1–7."
            log_json "ERROR" "$SCRIPT_NAME" "Invalid menu option: $option"
            ;;
    esac
}

# 🔁 Entrypoint
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_audit_menu
fi

