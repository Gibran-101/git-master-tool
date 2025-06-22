#!/bin/bash

prompt_with_validation() {
    local prompt="$1"
    local var
    while true; do
        read -p "$prompt (or type 'exit' to cancel): " var
        if [[ -z "$var" ]]; then
            echo " Input cannot be empty. Try again."
        elif [[ "$var" == "exit" ]]; then
            echo " Cancelled."
            return 1
        else
            echo "$var"
            return 0
        fi
    done
}

generate_commit_msg() {
    if ! git diff --cached --quiet; then
        echo "Generating AI-based commit message..."

        diff_data=$(git diff --cached)

        json_payload=$(jq -n --arg msg "$diff_data" '{
            "model": "gpt-4",
            "messages": [
                {"role": "system", "content": "You are a helpful assistant that writes clean, concise, conventional commit messages based on git diffs."},
                {"role": "user", "content": $msg}
            ],
            "temperature": 0.5
        }')

        response=$(curl -s https://api.openai.com/v1/chat/completions \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $OPENAI_API_KEY" \
            -d "$json_payload")

        commit_msg=$(echo "$response" | jq -r '.choices[0].message.content')

        echo ""
        echo " AI Suggestion: $commit_msg"
        echo ""
        read -p "Use this commit message? (Y/n): " confirm
        if [[ "$confirm" =~ ^[Nn]$ ]]; then
            prompt_with_validation "Enter your custom commit message: "
        else
            echo "$commit_msg"
        fi
    else
        echo " No staged changes to commit."
        return 1
    fi
}


