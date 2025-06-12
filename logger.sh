#!/bin/bash

LOG_FILE="./git_script_log.json"

log_json() {
    local level="$1"
    local script_name="$2"
    local message="$3"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    echo "{
  \"timestamp\": \"${timestamp}\",
  \"level\": \"${level}\",
  \"script\": \"${script_name}\",
  \"message\": \"${message}\"
}" >> "$LOG_FILE"
}
