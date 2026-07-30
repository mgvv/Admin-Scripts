#!/bin/bash

# Function to display usage instructions
usage() {
  echo "Usage: $0 <log_file_path> <source_directory> [--dry-run]"
  echo ""
  echo "Deletes files listed in <log_file_path> from <source_directory>."
  echo ""
  echo "Options:"
  echo "  -d, --dry-run    Preview files that will be deleted without actually deleting them."
  echo "  -h, --help       Display this help message."
  echo ""
  echo "Examples:"
  echo "  $0 /backup/archives/archive_pre_2026_20260730_120000.log /usr/sap/int/gp1/tmcc/ariba/dna/arc"
  echo "  $0 /backup/archives/archive_pre_2026_20260730_120000.log /usr/sap/int/gp1/tmcc/ariba/dna/arc --dry-run"
  exit 1
}

# Check for parameters or help request
if [ $# -lt 2 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  usage
fi

LOG_FILE="$1"
SRC_DIR="$2"
DRY_RUN=false

if [ "$3" = "-d" ] || [ "$3" = "--dry-run" ]; then
  DRY_RUN=true
fi

# Validate inputs
if [ ! -f "$LOG_FILE" ]; then
  echo "Error: Log file '$LOG_FILE' does not exist."
  exit 1
fi

if [ ! -d "$SRC_DIR" ]; then
  echo "Error: Source directory '$SRC_DIR' does not exist."
  exit 1
fi

echo "=========================================="
if [ "$DRY_RUN" = true ]; then
  echo " Mode: DRY RUN (No files will be deleted)"
else
  echo " Mode: EXECUTION (Files WILL be removed)"
fi
echo " Log File:  $LOG_FILE"
echo " Target Dir: $SRC_DIR"
echo "=========================================="

DELETED_COUNT=0
SKIPPED_COUNT=0

# Read log file line by line
while IFS= read -r FILE_ENTRY || [ -n "$FILE_ENTRY" ]; do
  # Skip empty lines
  [ -z "$FILE_ENTRY" ] && continue

  # Clean up trailing/leading dots or slashes from path in log
  CLEAN_NAME=$(echo "$FILE_ENTRY" | sed -e 's/^\.\///')
  TARGET_PATH="$SRC_DIR/$CLEAN_NAME"

  if [ -f "$TARGET_PATH" ]; then
    if [ "$DRY_RUN" = true ]; then
      echo "[WOULD DELETE] $TARGET_PATH"
      ((DELETED_COUNT++))
    else
      rm "$TARGET_PATH"
      if [ $? -eq 0 ]; then
        echo "[DELETED] $TARGET_PATH"
        ((DELETED_COUNT++))
      else
        echo "[ERROR] Failed to delete: $TARGET_PATH"
      fi
    fi
  else
    echo "[SKIP] File not found: $TARGET_PATH"
    ((SKIPPED_COUNT++))
  fi
done < "$LOG_FILE"

echo "=========================================="
echo "Summary:"
echo "  Files processable/deleted: $DELETED_COUNT"
echo "  Files skipped (not found): $SKIPPED_COUNT"
echo "=========================================="
