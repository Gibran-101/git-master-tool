#!/bin/bash

# Always use the script's directory as the base
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common_utils.sh"

push_strategies(){ bash "$SCRIPT_DIR/lib/push.sh"; }
clone_repo(){ bash "$SCRIPT_DIR/lib/clone.sh"; }
branch_mgmt(){ bash "$SCRIPT_DIR/lib/branch.sh"; }
pull_strategies(){ bash "$SCRIPT_DIR/lib/pull.sh"; }
revert_reset_options(){ bash "$SCRIPT_DIR/lib/revert_reset.sh"; }
stash_operations(){ bash "$SCRIPT_DIR/lib/stash.sh"; }
log_viewer(){ bash "$SCRIPT_DIR/lib/logs.sh"; }

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
    
    usr_choice=$(prompt_with_validation "Please select the option you desire to proceed with: ") || return 1

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

