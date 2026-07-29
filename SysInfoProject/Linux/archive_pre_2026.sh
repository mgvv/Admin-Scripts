#!/bin/bash

# Function to display usage instructions
usage() {
  echo "Usage: $0 <source_directory> <destination_directory>"
  echo ""
  echo "Compresses all files in <source_directory> modified prior to 2026"
  echo "into a single zip file saved in <destination_directory>."
  echo ""
  echo "Example:"
  echo "  $0 /usr/sap/int/gp1/tmcc/ariba/dna/arc /backup/archives"
  exit 1
}

# Check if required parameters are passed or if help is requested
if [ $# -lt 2 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  usage
fi

SRC_DIR="$1"
DEST_DIR="$2"

# Check if source directory exists
if [ ! -d "$SRC_DIR" ]; then
  echo "Error: Source directory '$SRC_DIR' does not exist."
  exit 1
fi

# Create destination directory if it doesn't exist
if [ ! -d "$DEST_DIR" ]; then
  echo "Destination directory '$DEST_DIR' does not exist. Creating it now..."
  mkdir -p "$DEST_DIR" || { echo "Error: Failed to create directory '$DEST_DIR'."; exit 1; }
fi

# Archive name with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ZIP_PATH="$DEST_DIR/archive_pre_2026_$TIMESTAMP.zip"

cd "$SRC_DIR" || exit 1

echo "Finding files modified before 2026 in $SRC_DIR..."

# Find files older than 2026-01-01 and move them into the zip
find . -maxdepth 1 -type f ! -newermt "2026-01-01" -print0 | \
  xargs -0 zip -m "$ZIP_PATH"

if [ $? -eq 0 ]; then
  echo "Successfully compressed files to: $ZIP_PATH"
  echo "Original files were removed from: $SRC_DIR"
else
  echo "An error occurred during compression. Original files were preserved."
  exit 1
fi
