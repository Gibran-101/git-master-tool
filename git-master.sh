#!/bin/bash

# Always use the script's directory as the base
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

input_validator() {
    if [ -z "$1" ]; then
        echo "$2"
        return 1
    fi
}

push_strategies(){ ./lib/push.sh; }
clone_repo(){ ./lib/clone.sh; }
branch_mgmt(){ ./lib/branch.sh; }
pull_strategies(){ ./lib/pull.sh; }
revert_reset_options(){ ./lib/revert_reset.sh; }
stash_operations(){ ./lib/stash.sh; }
log_viewer(){ ./lib/logs.sh; }

master_control() {
    echo ""
    echo "The Git Toolbox"
    echo "1. Git Push Strategies"
    echo "2. Clone Repository"
    echo "3. Branch Management"
    echo "4. Git Pull Strategies"
    echo "5. Revert/ Reset Options"
    echo "6. Git Stash Operations"
    echo "7. Git Log Viewer"
    echo "8. Exit"
    read -p "Please select the option you desire to proceed with: " usr_choice
    input_validator "$usr_choice" "Please select a valid option"

    case "$usr_choice" in
        1) push_strategies ;;
        2) clone_repo ;;
        3) branch_mgmt ;;
        4) pull_strategies ;;
        5) revert_reset_options ;;
        6) stash_operations ;;
        7) log_viewer ;;
        8)
            echo " Exiting Git Master."
            exit 0
            ;;
        *)
            echo " Invalid option. Please choose between 1 and 7."
            ;;
    esac
}

#  Loop it like a boss
while true; do
    master_control
done

