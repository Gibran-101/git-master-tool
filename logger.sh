#!/bin/bash

# Define the path to the log file
LOG_FILE="./git_activity_log.json"

# ---------------------------------------------
# Map of log levels to 2-letter codes
# e.g., INFO -> IN, SUCCESS -> SU
declare -A LEVEL_CODES=(
    ["INFO"]="IN"
    ["SUCCESS"]="SU"
    ["ERROR"]="ER"
    ["WARNING"]="WR"
)

# ---------------------------------------------
# Map of script names to 2-letter codes
# Used for generating unique serial keys
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

# ----------------------------------------------------
# Function to generate a unique serial key per log
# Format: <SCRIPT_CODE><LEVEL_CODE><XX>
# Example: PSIN01, RSER05, etc.
generate_serial_key() {
    local script_name="$1"         # Name of the calling script
    local log_level="$2"           # Log level like INFO, ERROR, etc.

    # Lookup corresponding short codes
    local script_code="${SCRIPT_CODES[$script_name]}"
    local level_code="${LEVEL_CODES[$log_level]}"

    # If mapping fails, return fallback serial key
    if [[ -z "$script_code" || -z "$level_code" ]]; then
        echo "XXXX00"
        return
    fi

    local prefix="${script_code}${level_code}"  # e.g., PSIN

    # Try to find the last used serial key for this prefix
    if [ -f "$LOG_FILE" ]; then
        last_serial=$(jq -r \
            --arg prefix "$prefix" \
            '[.[] | select(.serial_key | startswith($prefix))] | .[-1].serial_key' "$LOG_FILE" | grep -o '..$')
    else
        last_serial="00"  # Start from 00 if no log file
    fi

    # Increment the serial number safely
    if [[ "$last_serial" =~ ^[0-9]+$ ]]; then
        new_serial=$(printf "%02d" $((10#$last_serial + 1)))  # Avoid octal interpretation
    else
        new_serial="01"
    fi

    # Final serial key like PSIN01
    echo "${prefix}${new_serial}"
}

# ----------------------------------------------------
# Function to write a structured JSON log entry
log_json() {
    local level="$1"          # Log level (e.g. INFO, SUCCESS)
    local script_name="$2"    # Script name (e.g. push.sh)
    local message="$3"        # Custom message

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")  # UTC ISO timestamp

    local serial_key
    serial_key=$(generate_serial_key "$script_name" "$level")  # Get unique serial

    # Create JSON object using jq
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

    # Append to log file (as JSON array)
    if [ -s "$LOG_FILE" ]; then
        tmp=$(mktemp)
        jq ". += [$log_entry]" "$LOG_FILE" > "$tmp" && mv "$tmp" "$LOG_FILE"
    else
        echo "[$log_entry]" > "$LOG_FILE"
    fi
}

