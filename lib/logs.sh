#!/bin/bash

# ─────────────────────────────────────────────────────
# Git Logs Utility Script
# Author: Gibran
# ─────────────────────────────────────────────────────

# Validate that input is not empty
source ./common_utils.sh

# 1. Detailed git log
basic_log() {
    echo " THE FOLLOWING ARE THE DETAILED LOGS:"
    git log
}

# 2. Git log in oneline format
oneline_log() {
    echo " THE FOLLOWING SHOWS LOGS IN ONELINE:"
    git log --oneline
}

# 3. Graph visualization of git log
graph_view_logs() {
    echo " VISUALIZATION OF LOGS (graph view):"
    git log --graph --oneline --decorate --all
}

# 4. Filter logs by author
logs_by_author() {
    author_name=$(prompt_with_validation "Enter the author name ") || return 1
    git log --author="$author_name"
}

# 5. View last N commits
access_last_N_commits() {
    counter=$(prompt_with_validation "Please enter N value, to access recent commits ") || return 1

    if ! [[ "$counter" =~ ^[0-9]+$ ]]; then
        echo " Invalid number entered."
        return 1
    fi

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
                return 1
                ;;
        esac

        if [ $? -eq 0 ]; then
            echo " Logs exported successfully to $filename.txt"
        else
            echo " Failed to export logs."
        fi

    elif [ "$user_response" = "no" ]; then
        echo " Export cancelled."
    else
        echo " Invalid response. Please type yes or no."
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
            exit 0
            ;;
        *)
            echo " Invalid option. Choose between 1-7."
            ;;
    esac
}

# Run the menu only if this script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_logs_menu
fi


