#!/bin/bash

# Usage function
usage() {
  echo "Usage: $0 <SAP SID> [--detailed]"
  echo "Example: $0 PRD --detailed"
  exit 1
}

# Check arguments
if [ -z "$1" ]; then
  usage
fi

SID=$1
DETAILED=false

# Check for optional --detailed flag
if [ "$2" == "--detailed" ]; then
  DETAILED=true
fi

PROFILE_DIR="/usr/sap/${SID}/SYS/profile"

# Check if directory exists
if [ ! -d "$PROFILE_DIR" ]; then
  echo "Profile directory not found: $PROFILE_DIR"
  exit 2
fi

echo "Searching for 'login/no_automatic_user_sapstar' in profile files under ${PROFILE_DIR}..."
echo

# Loop through all profile files
for file in "$PROFILE_DIR"/*; do
  if [ -f "$file" ]; then
    matches=$(grep -n "login/no_automatic_user_sapstar" "$file")
    if [ -n "$matches" ]; then
      echo "Found in: $(basename "$file")"
      while IFS= read -r line; do
        line_num=$(echo "$line" | cut -d: -f1)
        param_line=$(echo "$line" | cut -d: -f2-)
        value=$(echo "$param_line" | awk -F= '{gsub(/ /, "", $2); print $2}')
        
        echo "  Line $line_num"
        if [ "$DETAILED" = true ]; then
          echo "    $param_line"
        fi

        if [ "$value" == "0" ]; then
          echo "    ➤ SAP* is ENABLED (value = 0)"
        elif [ "$value" == "1" ]; then
          echo "    ➤ SAP* is DISABLED (value = 1)"
        else
          echo "    ➤ Unknown value: '$value' — please verify manually"
        fi
      done <<< "$matches"
      echo
    fi
  fi
done
