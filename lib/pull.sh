#!/bin/bash

# ============================
# Git Pull Utility Script
# Author: Gibran
# ============================

"$SCRIPT_DIR/lib/push.sh"

source ./common_utils.sh
source ./logger.sh

SCRIPT_NAME="$(basename "$0")"

# Ensure we're inside a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo " Not a Git repository. Initialize or cd into one first."
    log_json "ERROR" "$SCRIPT_NAME" "Attempted to pull outside a Git repo"
    exit 1
fi
log_json "INFO" "$SCRIPT_NAME" "Inside a valid Git repo"

# Remote  and Branch input
read -p " Enter remote name (default: origin): " remote
remote=${remote:-origin}
echo "   Using remote: $remote"
log_json "INFO" "$SCRIPT_NAME" "Remote selected: $remote"

read -p " Enter branch name (default: current branch): " branch
branch=${branch:-$(git branch --show-current)}
echo "   Using branch: $branch"
log_json "INFO" "$SCRIPT_NAME" "Branch selected: $branch"

# Pull strategy selection
choose_strategy() {
    echo ""
    echo "Choose your pull strategy:"
    echo "1. Merge (default)"
    echo "2. Rebase"
    echo "3. Fast-forward only"
    echo "4. Allow unrelated histories"
    choice=$(prompt_with_validation "Your choice: ") || return 1

    local flag=""
    case "$choice" in
        2)
            echo " Using rebase strategy"
            flag="--rebase"
            log_json "INFO" "$SCRIPT_NAME" "Strategy chosen: rebase"
            ;;
        3)
            echo " Using fast-forward only strategy"
            flag="--ff-only"
            log_json "INFO" "$SCRIPT_NAME" "Strategy chosen: fast-forward only"
            ;;
        4)
            echo "  Allowing unrelated histories"
            flag="--allow-unrelated-histories"
            log_json "INFO" "$SCRIPT_NAME" "Strategy chosen: allow unrelated histories"
            ;;
        *)
            echo " Using default merge strategy"
            log_json "INFO" "$SCRIPT_NAME" "Strategy chosen: merge (default)"
            ;;
    esac

    echo "$flag"
}

# Call strategy picker and execute
strategy_flag=$(choose_strategy)

echo ""
echo " Running: git pull $strategy_flag $remote $branch"
log_json "INFO" "$SCRIPT_NAME" "Executing: git pull $strategy_flag $remote $branch"
git pull $strategy_flag "$remote" "$branch"

# Result
if [ $? -eq 0 ]; then
    echo " Pull successful."
    log_json "SUCCESS" "$SCRIPT_NAME" "Git pull completed successfully"
else
    echo " Pull failed. Fix your conflicts or remote issues like you fix your bad habits — slowly and with guidance."
    log_json "ERROR" "$SCRIPT_NAME" "Git pull failed for $remote/$branch"
fi

