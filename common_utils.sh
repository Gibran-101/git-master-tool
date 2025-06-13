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

