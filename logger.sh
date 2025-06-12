#!/bin/bash

LOG_FILE="./git_activity_log.json"

# Map full log levels to 2-letter codes
declare -A LEVEL_CODES=(
    ["INFO"]="IN"
    ["SUCCESS"]="SU"
    ["ERROR"]="ER"
    ["WARNING"]="WR"
)

# Map script names to codes
declare -A SCRIPT_CODES=(
    ["push.sh"]="PS"
    ["clone.sh"]="CL"
    ["branch.sh"]="BR"
    ["pull.sh"]="PL"
    ["revert_reset.sh"]="RS"
    ["stash.sh"]="ST"
    ["logs.sh"]="LG"
    ["git-master.sh"]="GM"
)

generate_serial_key() {
    local script_name="$1"
    local log_level="$2"

    local script_code="${SCRIPT_CODES[$script_name]}"
    local level_code="${LEVEL_CODES[$log_level]}"

    if [[ -z "$script_code" || -z "$level_code" ]]; then
        echo "XXXX00"
        return
    fi

    local prefix="${script_code}${level_code}"

    # Get the last serial number used for this prefix
    if [ -f "$LOG_FILE" ]; then
        last_serial=$(jq -r \
            --arg prefix "$prefix" \
            '[.[] | select(.serial_key | startswith($prefix))] | .[-1].serial_key' "$LOG_FILE" | grep -o '..$')
    else
        last_serial="00"
    fi

    if [[ "$last_serial" =~ ^[0-9]+$ ]]; then
        new_serial=$(printf "%02d" $((10#$last_serial + 1)))
    else
        new_serial="01"
    fi

    echo "${prefix}${new_serial}"
}


log_json() {
    local level="$1"
    local script_name="$2"
    local message="$3"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    local serial_key
    serial_key=$(generate_serial_key "$script_name" "$level")

    # Create JSON log object
    local log_entry
    log_entry=$(jq -n \
        --arg timestamp "$timestamp" \
        --arg level "$level" \
        --arg script "$script_name" \
        --arg message "$message" \
        --arg serial_key "$serial_key" \
        '{
            timestamp: $timestamp,
            level: $level,
            script: $script,
            message: $message,
            serial_key: $serial_key
        }')

    # Append to the log file
    if [ -s "$LOG_FILE" ]; then
        # If file exists and is not empty, remove closing bracket, add comma and new entry
        tmp=$(mktemp)
        jq ". += [$log_entry]" "$LOG_FILE" > "$tmp" && mv "$tmp" "$LOG_FILE"
    else
        echo "[$log_entry]" > "$LOG_FILE"
    fi
}

