#!/bin/bash

# Validate that input is not empty
validator() {
    if [ -z "$1" ]; then
        echo "$2"
        return 1
    fi
}

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
    read -p " Please enter the author name: " author_name
    validator "$author_name" " Please enter the author name" || return 1
    git log --author="$author_name"
}

# 5. View last N commits
access_last_N_commits() {
    read -p " Please enter how many recent commits to show: " counter
    validator "$counter" " Please enter a number" || return 1

    if ! [[ "$counter" =~ ^[0-9]+$ ]]; then
        echo " Invalid number entered."
        return 1
    fi

    git log -n "$counter" --oneline
}

# 6. Export logs to a file
export_logs() {
    read -p " Would you like to export your logs? (yes/no): " user_response
    user_response=$(echo "$user_response" | tr '[:upper:]' '[:lower:]')
    validator "$user_response" " Please enter a response" || return 1

    if [ "$user_response" = "yes" ]; then
        read -p " Select log type (basic/oneline/graph): " log_type
        log_type=$(echo "$log_type" | tr '[:upper:]' '[:lower:]')

        read -p " Enter filename (without extension): " filename
        validator "$log_type" " Please select a log type" || return 1
        validator "$filename" " Please enter a filename" || return 1

        case "$log_type" in
            "basic") git log > "$filename.txt" ;;
            "oneline") git log --oneline > "$filename.txt" ;;
            "graph") git log --graph --oneline --decorate --all > "$filename.txt" ;;
            *)
                echo " Invalid log type selected. Choose: basic / oneline / graph"
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
        echo "⚠️ Invalid response. Please type yes or no."
    fi
}

# Menu for selecting log operations
main_menu() {
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

    read -p " Select an option (1-7): " selected_option

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

# Kick off the script
main_menu

