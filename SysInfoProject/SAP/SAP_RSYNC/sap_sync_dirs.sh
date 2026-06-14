#!/bin/bash

# ==========================================
# Configuration & Variables
# ==========================================
TARGET_IP="10.84.242.225"
TARGET_USER="root"
SID="SP1"
LOG_DIR="/var/log/sap_sync" # Ensure this directory exists or change to /tmp
LOG_FILE="${LOG_DIR}/sync_$(date +%Y%m%d_%H%M%S).log"
DRY_RUN=false

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# ==========================================
# Parameter Parsing
# ==========================================
# Check if the --dry-run flag was passed when executing the script
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "=========================================="
    echo " ℹ️ RUNNING IN DRY-RUN MODE"
    echo " No actual files will be transferred/deleted."
    echo "=========================================="
    echo
fi

# ==========================================
# Arrays (Targets & Options)
# ==========================================
directories=(
  "/usr/sap/${SID}/ASCS01/sec/"
  "/usr/sap/${SID}/D00/sec/"
  "/usr/sap/${SID}/D00/log/"
  "/sapmnt/${SID}/"
)

rsync_opts=(
  -aHAXv 
  --numeric-ids 
  --delete 
  --progress
)

# Append the dry-run flag to rsync options if enabled
if [ "$DRY_RUN" = true ]; then
    rsync_opts+=("--dry-run")
fi

# ==========================================
# Functions
# ==========================================

# Standardized logging function
log_message() {
    local msg="$1"
    # Print to console and append to log file simultaneously
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $msg" | tee -a "$LOG_FILE"
}

# Error handler
handle_error() {
    local failed_dir="$1"
    echo
    log_message "❌ ERROR: Synchronization failed on directory: $failed_dir"
    log_message "⚠️ Script aborted to prevent partial state issues."
    exit 1
}

# ==========================================
# Main Execution Loop
# ==========================================
log_message "🚀 Starting synchronization script..."
log_message "Target: ${TARGET_USER}@${TARGET_IP}"
log_message "Logging output to: $LOG_FILE"

for dir in "${directories[@]}"; do
    echo
    log_message "▶️ Queued target: $dir"
  
    read -p "Press Enter or type 'y' to run (any other key to abort): " choice
  
    if [[ -n "$choice" && ! "$choice" =~ ^[Yy]([Ee][Ss])?$ ]]; then
        log_message "🛑 Stopped by user before syncing: $dir"
        exit 1
    fi

    log_message "⏳ Synchronizing $dir..."

    # Execute rsync. 
    # 2>&1 redirects stderr to stdout so we capture errors in the log file.
    # We pipe to 'tee -a' to show progress on screen and save it to the log.
    rsync "${rsync_opts[@]}" "$dir" "${TARGET_USER}@${TARGET_IP}:${dir}" 2>&1 | tee -a "$LOG_FILE"

    # Capture the exit status of the rsync command, NOT the tee command.
    # PIPESTATUS[0] holds the exit code of the first command in the pipe.
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        handle_error "$dir"
    fi

    log_message "✅ Successfully completed: $dir"
done

echo
log_message "🎉 All directories synchronized successfully."
