#!/bin/bash

# Always use the script's directory as the base
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common_utils.sh"

source "$SCRIPT_DIR/lib/push.sh"
push_strategies(){ push_master; }

source "$SCRIPT_DIR/lib/pull.sh"
pull_strategies(){ pull_master; }

source "$SCRIPT_DIR/lib/branch.sh"
branch_mgmt(){ branch_master; }

source "$SCRIPT_DIR/lib/clone.sh"
clone_repo(){ clone_master; }

source "$SCRIPT_DIR/lib/logs.sh"
log_viewer(){ logs_master; }

source "$SCRIPT_DIR/lib/revert_reset.sh"
revert_reset_options(){ revert_reset_master; }

source "$SCRIPT_DIR/lib/stash.sh"
stash_operations(){ stash_master; }


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

