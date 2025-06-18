#!/bin/bash

"$SCRIPT_DIR/lib/restore.sh"

source ./logger.sh
source ./common_utils.sh

SCRIPT_NAME="$(basename "$0")"

# 🧠 Ensure we're in a Git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "  Not a Git repository. Initialize or cd into one first."
    log_json "ERROR" "$SCRIPT_NAME" "Attempted restore outside a Git repo"
    exit 1
fi
log_json "INFO" "$SCRIPT_NAME" "Inside a valid Git repository"

# 🧾 Show current file statuses
echo ""
echo " Modified / Unstaged Files:"
git diff --name-only || echo "  (None)"
echo ""
echo " Staged Files:"
git diff --cached --name-only || echo "  (None)"
echo ""

# 🔁 Operations
discard_local() {
    filename=$(prompt_with_validation "Enter the filename to discard changes: ") || return 1
    git restore "$filename"
    log_json "INFO" "$SCRIPT_NAME" "Discarded local changes from $filename"
    echo " Discarded changes in '$filename'"
}

unstage_changes() {
    filename=$(prompt_with_validation "Enter the filename to unstage: ") || return 1
    git restore --staged "$filename"
    log_json "INFO" "$SCRIPT_NAME" "Unstaged file $filename"
    echo " Unstaged '$filename'"
}

restore_latest() {
    filename=$(prompt_with_validation "Enter the filename to restore from last commit: ") || return 1
    git restore --source=HEAD "$filename"
    log_json "INFO" "$SCRIPT_NAME" "Restored '$filename' from HEAD"
    echo " Restored '$filename' from last commit"
}

restore_selected() {
    echo " Commit Log:"
    git log --oneline -n 5
    echo ""
    commit_hash=$(prompt_with_validation "Enter commit hash: ") || return 1
    filename=$(prompt_with_validation "Enter the filename to restore: ") || return 1
    git restore --source="$commit_hash" "$filename"
    log_json "INFO" "$SCRIPT_NAME" "Restored '$filename' from commit $commit_hash"
    echo " Restored '$filename' from commit $commit_hash"
}

choose_strategy() {
    echo ""
    echo " Restore Options:"
    echo "1. Discard local changes (unstaged)"
    echo "2. Unstage staged files"
    echo "3. Restore from last commit"
    echo "4. Restore from specific commit"
    echo "5. Exit"
    echo ""

    choice=$(prompt_with_validation "Choose an option (1-5): ") || return 1

    case "$choice" in
        1) discard_local ;;
        2) unstage_changes ;;
        3) restore_latest ;;
        4) restore_selected ;;
        5)
            echo " Exiting Restore Manager."
            log_json "INFO" "$SCRIPT_NAME" "User exited restore manager"
            exit 0
            ;;
        *)
            echo " Invalid choice."
            log_json "ERROR" "$SCRIPT_NAME" "Invalid option '$choice' selected"
            ;;
    esac
}

# 🚀 Entry
choose_strategy

