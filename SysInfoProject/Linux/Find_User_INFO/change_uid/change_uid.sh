#!/bin/bash

# --- 1. Usage Function ---
usage() {
  echo "Usage: $0 [OPTIONS]"
  echo "Change a user's UID safely, updating file ownership across the system."
  echo ""
  echo "Options:"
  echo "  -h, --help          Display this help message and exit."
  echo "  --dry-run           Simulate the process without making actual changes."
  echo "  --log-dir <path>    Specify a custom directory to save the log file."
  echo "  --scan-path <path>  Specify which directory to scan for old files (Default: /)"
  echo ""
  echo "Examples:"
  echo "  sudo $0"
  echo "  sudo $0 --dry-run --scan-path /home"
  echo "  sudo $0 --scan-path /var/www --log-dir /opt/admin/logs"
}

# --- 2. Argument Parsing ---
DRY_RUN=false
LOG_DIR=""
SCAN_PATH="/"

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --log-dir)
      if [[ -n "$2" && "$2" != -* ]]; then
        LOG_DIR="$2"
        shift 2
      else
        echo "Error: Argument for $1 is missing." >&2
        usage
        exit 1
      fi
      ;;
    --scan-path)
      if [[ -n "$2" && "$2" != -* ]]; then
        SCAN_PATH="$2"
        shift 2
      else
        echo "Error: Argument for $1 is missing." >&2
        usage
        exit 1
      fi
      ;;
    *)
      echo "Error: Unknown parameter passed: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [ "$DRY_RUN" = true ]; then
  echo "========================================="
  echo "  RUNNING IN DRY-RUN MODE (SIMULATION)   "
  echo "========================================="
fi

# Validate scan path
if [[ ! -d "$SCAN_PATH" ]]; then
  echo "Error: The scan path '$SCAN_PATH' does not exist or is not a directory." >&2
  exit 1
fi

# --- 3. Root Check ---
if [[ "${EUID}" -ne 0 ]]; then
  echo "Error: This script must be run as root. Try using sudo." >&2
  exit 1
fi

# --- 4. Gather Input ---
read -p "Enter the username: " username

if ! id "$username" &>/dev/null; then
  echo "Error: User '$username' does not exist." >&2
  exit 1
fi

current_uid=$(id -u "$username")
echo "Current UID for $username is: $current_uid"

read -p "Enter the new UID: " new_uid

if ! [[ "$new_uid" =~ ^[0-9]+$ ]]; then
  echo "Error: The new UID must be a positive integer." >&2
  exit 1
fi

if getent passwd "$new_uid" >/dev/null 2>&1; then
  existing_user=$(getent passwd "$new_uid" | cut -d: -f1)
  echo "Error: UID $new_uid is already in use by user '$existing_user'." >&2
  exit 1
fi

# --- 5. Process Check ---
if pgrep -u "$username" >/dev/null; then
  if [ "$DRY_RUN" = true ]; then
    echo "[DRY-RUN] Would prompt to terminate running processes for '$username'."
  else
    echo "Warning: User '$username' has running processes. usermod will fail if processes are running."
    read -p "Do you want to terminate these processes now? (y/N): " kill_procs
    if [[ "$kill_procs" =~ ^[Yy]$ ]]; then
      pkill -u "$username"
      echo "Processes terminated."
      sleep 2
    else
      echo "Aborting UID change. Please stop the user's processes manually and try again."
      exit 1
    fi
  fi
fi

# --- 6. Execute UID Change ---
if [ "$DRY_RUN" = true ]; then
  echo "[DRY-RUN] Would run: usermod -u $new_uid $username"
else
  echo "Changing UID for $username from $current_uid to $new_uid..."
  if usermod -u "$new_uid" "$username"; then
    echo "Success! UID for $username is now $(id -u "$username")."
  else
    echo "Error: Failed to change UID." >&2
    exit 1
  fi
fi

# --- 7. Setup Logging Directory ---
timestamp=$(date +"%Y%m%d_%H%M%S")

if [[ -z "$LOG_DIR" ]]; then
  if [ "$DRY_RUN" = true ]; then
    LOG_DIR="/tmp"
  else
    LOG_DIR="/var/log"
  fi
fi

if [[ ! -d "$LOG_DIR" ]]; then
  echo "Log directory '$LOG_DIR' does not exist. Attempting to create it..."
  mkdir -p "$LOG_DIR" 2>/dev/null || { echo "Error: Failed to create log directory '$LOG_DIR'. Check permissions." >&2; exit 1; }
fi

if [ "$DRY_RUN" = true ]; then
  log_file="${LOG_DIR}/uid_change_${username}_${timestamp}_DRYRUN.log"
else
  log_file="${LOG_DIR}/uid_change_${username}_${timestamp}.log"
fi

# --- 8. Filesystem Update & Logging ---
if [ "$DRY_RUN" = true ]; then
  echo "--------------------------------------------------------"
  echo "Scanning '$SCAN_PATH' to find files owned by UID $current_uid..."
  echo "Simulated log will be written to: $log_file"
else
  echo "--------------------------------------------------------"
  echo "Scanning '$SCAN_PATH' for leftover files owned by UID $current_uid..."
  echo "Logging changes to: $log_file"
fi

echo "=== UID Change Log for $username (Dry-Run: $DRY_RUN) ===" > "$log_file"
echo "Old UID: $current_uid -> New UID: $new_uid" >> "$log_file"
echo "Target Scan Path: $SCAN_PATH" >> "$log_file"
echo "Date: $(date)" >> "$log_file"
echo "-----------------------------------" >> "$log_file"

find "$SCAN_PATH" \( -path /proc -o -path /sys -o -path /dev \) -prune -o -user "$current_uid" -print0 2>/dev/null | while IFS= read -r -d $'\0' file; do
  if [ "$DRY_RUN" = true ]; then
    echo "[DRY-RUN] Would change ownership: $file" >> "$log_file"
  else
    chown -h "$new_uid" "$file"
    echo "[$(date +'%H:%M:%S')] Changed: $file" >> "$log_file"
  fi
done

lines=$(wc -l < "$log_file")
files_found=$((lines - 5)) # Adjusted for the new header line

echo "--------------------------------------------------------"
if [ "$DRY_RUN" = true ]; then
  echo "Done Simulation! Found $files_found files that would need ownership updates in '$SCAN_PATH'."
  echo "Review the simulated target list at: $log_file"
else
  echo "Done! Updated ownership on $files_found files inside '$SCAN_PATH'."
  echo "You can review the full list of changed files at: $log_file"
fi
