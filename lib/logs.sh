#!/bin/bash

# ─────────────────────────────────────────────────────
# Git Logs Utility Script
# Author: Gibran
# ─────────────────────────────────────────────────────

source ./common_utils.sh
source ./logger.sh

SCRIPT_NAME="$(basename "$0")"

# 1. Detailed git log
basic_log() {
    echo " THE FOLLOWING ARE THE DETAILED LOGS:"
    log_json "INFO" "$SCRIPT_NAME" "Viewed detailed git log"
    git log
}

# 2. Git log in oneline format
oneline_log() {
    echo " THE FOLLOWING SHOWS LOGS IN ONELINE:"
    log_json "INFO" "$SCRIPT_NAME" "Viewed oneline git log"
    git log --oneline
}

# 3. Graph visualization of git log
graph_view_logs() {
    echo " VISUALIZATION OF LOGS (graph view):"
    log_json "INFO" "$SCRIPT_NAME" "Viewed graph-based git log"
    git log --graph --oneline --decorate --all
}

# 4. Filter logs by author
logs_by_author() {
    author_name=$(prompt_with_validation "Enter the author name ") || return 1
    log_json "INFO" "$SCRIPT_NAME" "Requested logs for author: $author_name"

    if git log --author="$author_name" --oneline | grep -q .; then
        git log --author="$author_name"
    else
        echo " Author '$author_name' not found in commit history."
        log_json "WARNING" "$SCRIPT_NAME" "No commits found for author: $author_name"
        return 1
    fi
}

# 5. View last N commits
access_last_N_commits() {
    counter=$(prompt_with_validation "Please enter N value, to access recent commits ") || return 1

    if ! [[ "$counter" =~ ^[0-9]+$ ]]; then
        echo " Invalid number entered."
        log_json "ERROR" "$SCRIPT_NAME" "Invalid number entered for commit count: $counter"
        return 1
    fi

    log_json "INFO" "$SCRIPT_NAME" "Viewed last $counter commits"
    git log -n "$counter" --oneline
}

# 6. Export logs to a file
export_logs() {
    user_response=$(prompt_with_validation "Would you like to export logs (y/ n) ") || return 1

    if [ "$user_response" = "y" ]; then
        log_type=$(prompt_with_validation "Select log type (basic/ oneline/ graph) ") || return 1
        filename=$(prompt_with_validation "Please enter filename (without extension) ") || return 1

        case "$log_type" in
            "basic") git log > "$filename.txt" ;;
            "oneline") git log --oneline > "$filename.txt" ;;
            "graph") git log --graph --oneline --decorate --all > "$filename.txt" ;;
            *)
                echo " Invalid log type. Choose: basic / oneline / graph"
                log_json "ERROR" "$SCRIPT_NAME" "Invalid log type for export: $log_type"
                return 1
                ;;
        esac

        if [ $? -eq 0 ]; then
            echo " Logs exported successfully to $filename.txt"
            log_json "SUCCESS" "$SCRIPT_NAME" "Exported $log_type logs to $filename.txt"
        else
            echo " Failed to export logs."
            log_json "ERROR" "$SCRIPT_NAME" "Failed to export logs to $filename.txt"
        fi

    elif [ "$user_response" = "no" ]; then
        echo " Export cancelled."
        log_json "INFO" "$SCRIPT_NAME" "User declined to export logs"
    else
        echo " Invalid response. Please type yes or no."
        log_json "ERROR" "$SCRIPT_NAME" "Invalid response to export prompt: $user_response"
    fi
}

# Menu for selecting log operations
main_logs_menu() {
    echo ""
    echo " Git Logging Operations Menu"
    echo "1. Detailed Log"
    echo "2. Oneline Log"
    echo "3. Graph Log"
    echo "4. Logs by Author"
    echo "5. Last N Commits"
    echo "6. Export Logs"
    echo "7. Exit"
    echo ""

    selected_option=$(prompt_with_validation "Please select an option (1-7) ") || return 1

    case "$selected_option" in
        1) basic_log ;;
        2) oneline_log ;;
        3) graph_view_logs ;;
        4) logs_by_author ;;
        5) access_last_N_commits ;;
        6) export_logs ;;
        7)
            echo " Exiting logs manager. Bye!"
            log_json "INFO" "$SCRIPT_NAME" "Exited logs manager"
            exit 0
            ;;
        *)
            echo " Invalid option. Choose between 1-7."
            log_json "ERROR" "$SCRIPT_NAME" "Invalid menu option selected: $selected_option"
            ;;
    esac
}

# Run the menu only if this script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_logs_menu
fi

