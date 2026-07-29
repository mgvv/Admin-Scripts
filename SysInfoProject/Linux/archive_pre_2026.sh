#!/bin/bash

# Function to display usage instructions
usage() {
  echo "Usage:"
  echo "  Run Archival: $0 <source_dir> <dest_dir> [--dry-run]"
  echo "  Revert Zip:   $0 -r <zip_file_path> <source_dir>"
  echo ""
  echo "Options:"
  echo "  -d, --dry-run    Preview files modified prior to 2026 without compressing/deleting."
  echo "  -r, --revert     Unzip archive back into the original source directory."
  echo "  -h, --help       Show this help message."
  echo ""
  echo "Examples:"
  echo "  $0 /usr/sap/int/gp1/tmcc/ariba/dna/arc /backup/archives"
  echo "  $0 /usr/sap/int/gp1/tmcc/ariba/dna/arc /backup/archives --dry-run"
  echo "  $0 -r /backup/archives/archive_pre_2026_20260729_150000.zip /usr/sap/int/gp1/tmcc/ariba/dna/arc"
  exit 1
}

# ----------------------------------------------------
# 1. HANDLE REVERT MODE (-r / --revert)
# ----------------------------------------------------
if [ "$1" = "-r" ] || [ "$1" = "--revert" ]; then
  ZIP_PATH="$2"
  SRC_DIR="$3"

  if [ -z "$ZIP_PATH" ] || [ -z "$SRC_DIR" ]; then
    echo "Error: Missing parameters for revert mode."
    usage
  fi

  if [ ! -f "$ZIP_PATH" ]; then
    echo "Error: Zip file '$ZIP_PATH' does not exist."
    exit 1
  fi

  if [ ! -d "$SRC_DIR" ]; then
    echo "Creating missing target directory for restoration: $SRC_DIR"
    mkdir -p "$SRC_DIR" || exit 1
  fi

  echo "Reverting contents of '$ZIP_PATH' back to '$SRC_DIR'..."
  unzip -o "$ZIP_PATH" -d "$SRC_DIR"

  if [ $? -eq 0 ]; then
    echo "Successfully reverted files to $SRC_DIR."
    echo "Note: The zip file $ZIP_PATH remains intact."
    exit 0
  else
    echo "Error: Failed to unzip files."
    exit 1
  fi
fi

# ----------------------------------------------------
# 2. PARSE PARAMETERS & HELP/DRY-RUN
# ----------------------------------------------------
if [ $# -lt 2 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  usage
fi

SRC_DIR="$1"
DEST_DIR="$2"
DRY_RUN=false

if [ "$3" = "-d" ] || [ "$3" = "--dry-run" ]; then
  DRY_RUN=true
fi

# Validate directories
if [ ! -d "$SRC_DIR" ]; then
  echo "Error: Source directory '$SRC_DIR' does not exist."
  exit 1
fi

if [ "$DRY_RUN" = false ] && [ ! -d "$DEST_DIR" ]; then
  echo "Destination directory '$DEST_DIR' does not exist. Creating it now..."
  mkdir -p "$DEST_DIR" || { echo "Error: Failed to create '$DEST_DIR'."; exit 1; }
fi

# ----------------------------------------------------
# 3. DRY RUN EXECUTION
# ----------------------------------------------------
if [ "$DRY_RUN" = true ]; then
  echo "--- [DRY RUN MODE] ---"
  echo "Scanning '$SRC_DIR' for files modified prior to 2026..."
  
  MATCHED_FILES=$(find "$SRC_DIR" -maxdepth 1 -type f ! -newermt "2026-01-01")
  
  if [ -z "$MATCHED_FILES" ]; then
    echo "No files modified prior to 2026 were found."
  else
    echo "The following files would be compressed and deleted:"
    echo "$MATCHED_FILES"
  fi
  echo "--- Dry run complete. No files were modified. ---"
  exit 0
fi

# ----------------------------------------------------
# 4. ARCHIVAL & LOGGING EXECUTION
# ----------------------------------------------------
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ZIP_PATH="$DEST_DIR/archive_pre_2026_$TIMESTAMP.zip"
LOG_PATH="$DEST_DIR/archive_pre_2026_$TIMESTAMP.log"

echo "Finding files modified before 2026 in $SRC_DIR..."

cd "$SRC_DIR" || exit 1

# List files into the log first
find . -maxdepth 1 -type f ! -newermt "2026-01-01" > "$LOG_PATH"

if [ ! -s "$LOG_PATH" ]; then
  echo "No files modified prior to 2026 found. Cleaning up empty log file."
  rm -f "$LOG_PATH"
  exit 0
fi

# Perform compression and deletion
find . -maxdepth 1 -type f ! -newermt "2026-01-01" -print0 | \
  xargs -0 zip -m "$ZIP_PATH"

if [ $? -eq 0 ]; then
  echo "=========================================="
  echo "Archival Completed Successfully!"
  echo "Zip Archive: $ZIP_PATH"
  echo "Log File:    $LOG_PATH"
  echo "=========================================="
else
  echo "An error occurred during compression. Original files were preserved."
  exit 1
fi
