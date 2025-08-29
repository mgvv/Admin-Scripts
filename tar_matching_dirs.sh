#!/bin/bash
#Arguments.
#./tar_matching_dirs.sh /path/to/base "ALL|#" /path/to/target

# Arguments
BASE_DIR="${1:-.}"
LIMIT="${2:-0}"
TARGET_DIR="${3:-.}"

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Clean up old .tar.gz files in the target directory
echo "Cleaning up old archives in $TARGET_DIR..."
find "$TARGET_DIR" -maxdepth 1 -type f -name '*.tar.gz' -exec rm -f {} \;

# Log file setup
LOG_FILE="archive_log_$(date +%Y%m%d_%H%M%S).log"
LOG_ARCHIVE="${LOG_FILE%.log}.tar.gz"

# Get server info
HOSTNAME=$(hostname)
IP_ADDRESS=$(hostname -I | awk '{print $1}')

# Start logging with server info
{
    echo "Archiving started at $(date)"
    echo "Server Hostname: $HOSTNAME"
    echo "Server IP Address: $IP_ADDRESS"
    echo "----------------------------------------"
} > "$LOG_FILE"

# Check if base directory exists
if [ ! -d "$BASE_DIR" ]; then
    echo "Error: Base directory '$BASE_DIR' does not exist." | tee -a "$LOG_FILE"
    exit 1
fi

# Counter for limiting archives
count=0

# Find and process matching directories (only one level deep)
find "$BASE_DIR" -mindepth 2 -maxdepth 2 -type d -regextype posix-extended -regex '.*/[0-9]{6}-[0-9]{6}' | while read -r dir; do
    # Check limit unless it's "ALL"
    if [[ "$LIMIT" != "ALL" && "$LIMIT" -gt 0 && "$count" -ge "$LIMIT" ]]; then
        break
    fi

    dir_name=$(basename "$dir")
    parent_dir=$(dirname "$dir")
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    tar_file="${TARGET_DIR}/${dir_name}.tar.gz"

    echo "[$timestamp] Archiving: $dir" | tee -a "$LOG_FILE"

    if tar -czf "$tar_file" -C "$parent_dir" "$dir_name" 2>>"$LOG_FILE"; then
        echo "[$timestamp] Success: Created $tar_file" | tee -a "$LOG_FILE"
    else
        echo "[$timestamp] Error: Failed to archive $dir. See details below:" | tee -a "$LOG_FILE"
        tail -n 5 "$LOG_FILE" | tee -a "$LOG_FILE"
    fi

    count=$((count + 1))
done

echo "Archiving completed at $(date)" >> "$LOG_FILE"

# Package the log file and move it to target directory
if tar -czf "$LOG_ARCHIVE" "$LOG_FILE"; then
    mv "$LOG_ARCHIVE" "$TARGET_DIR/"
    echo "Log file archived as ${TARGET_DIR}/$(basename "$LOG_ARCHIVE")"
else
    echo "Failed to archive the log file."
fi
