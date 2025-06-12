#!/bin/bash

# ============================
# Git Pull Utility Script
# Author: Gibran (and the sassiest GPT alive)
# ============================

# Validate input
validator() {
    if [ -z "$1" ]; then
        echo "$2"
        return 1
    fi
}

# Ensure we're inside a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo " Not a Git repository. Initialize or cd into one first."
    exit 1
fi

# Prompt for remote and branch
read -p "Enter remote name (default: origin): " remote
remote="${remote:-origin}"

read -p "Enter branch name (default: current branch): " branch
branch="${branch:-$(git branch --show-current)}"

# Pull strategy selection
choose_strategy() {
    echo ""
    echo "Choose your pull strategy:"
    echo "1. Merge (default)"
    echo "2. Rebase"
    echo "3. Fast-forward only"
    echo "4. Allow unrelated histories"
    read -p "Your choice: " choice

    local flag=""
    case "$choice" in
        2)
            echo " Using rebase strategy"
            flag="--rebase"
            ;;
        3)
            echo " Using fast-forward only strategy"
            flag="--ff-only"
            ;;
        4)
            echo "⚠️ Allowing unrelated histories"
            flag="--allow-unrelated-histories"
            ;;
        *)
            echo " Using default merge strategy"
            ;;
    esac

    echo "$flag"
}

# Call strategy picker and execute
strategy_flag=$(choose_strategy)

echo ""
echo " Running: git pull $strategy_flag $remote $branch"
git pull $strategy_flag "$remote" "$branch"

# Result
if [ $? -eq 0 ]; then
    echo " Pull successful."
else
    echo " Pull failed. Fix your conflicts or remote issues like you fix your bad habits — slowly and with guidance."
fi

