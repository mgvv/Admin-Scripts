#!/bin/bash

# ==========================================
# Script Name: smart_backup.sh
# Description: Backup/Restore tool. Supports Interactive (-i) and CLI modes.
# ==========================================

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- 1. Usage / Help Function ---
usage() {
    echo -e "${BLUE}Usage: $0 [MODE] [OPTIONS]${NC}"
    echo ""
    echo -e "${YELLOW}MODES:${NC}"
    echo "  (No arguments)   Show this help message"
    echo "  -i               Enter Interactive Menu Mode"
    echo "  -b               Run Backup (requires -s, -d)"
    echo "  -r               Run Restore (requires -f)"
    echo ""
    echo -e "${YELLOW}BACKUP OPTIONS:${NC}"
    echo "  -s <path>        Source directory to backup"
    echo "  -d <path>        Destination directory for the archive"
    echo "  -t <type>        Format: 'gz' (default), 'bz2', or 'zip'"
    echo "  -flat            Save files directly (flat) instead of keeping directory structure"
    echo ""
    echo -e "${YELLOW}RESTORE OPTIONS:${NC}"
    echo "  -f <file>        Full path to the backup file to restore"
    echo "  -d <path>        Destination to unpack (default: current dir)"
    echo ""
    echo -e "${YELLOW}EXAMPLES:${NC}"
    echo "  Interactive:     $0 -i"
    echo "  Backup (std):    $0 -b -s /var/www -d /backups -t gz"
    echo "  Backup (flat):   $0 -b -s /var/logs -d . -flat"
    echo "  Restore:         $0 -r -f /backups/site.tar.gz -d /var/www"
    exit 1
}

check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}Error: '$1' is not installed.${NC}"
        exit 1
    fi
}

# --- 2. Core Logic Functions ---

core_backup() {
    local SRC=$1
    local DEST=$2
    local FMT=$3
    local FLAT=$4

    # Validations
    SRC=${SRC%/}
    DEST=${DEST%/}
    
    if [ -z "$SRC" ] || [ -z "$DEST" ]; then
        echo -e "${RED}Error: Source (-s) and Destination (-d) are required.${NC}"
        exit 1
    fi
    if [ ! -d "$SRC" ]; then
        echo -e "${RED}Error: Source directory '$SRC' does not exist.${NC}"
        exit 1
    fi
    mkdir -p "$DEST"

    # Filename Setup
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BASE_NAME=$(basename "$SRC")
    BACKUP_NAME="${BASE_NAME}_${TIMESTAMP}"

    # Path Strategy
    if [ "$FLAT" == "true" ]; then
        # Go inside, grab contents (spills out when unpacked)
        cd "$SRC" || exit
        TARGET="."
    else
        # Go to parent, grab folder name (creates folder when unpacked)
        PARENT_DIR=$(dirname "$SRC")
        TARGET=$(basename "$SRC")
        cd "$PARENT_DIR" || exit
    fi

    echo -e "${BLUE}Backing up '$SRC' to '$DEST'...${NC}"

    case $FMT in
        gz|tar.gz)
            tar -czf "${DEST}/${BACKUP_NAME}.tar.gz" $TARGET
            FINAL_FILE="${DEST}/${BACKUP_NAME}.tar.gz"
            ;;
        bz2|tar.bz2)
            tar -cjf "${DEST}/${BACKUP_NAME}.tar.bz2" $TARGET
            FINAL_FILE="${DEST}/${BACKUP_NAME}.tar.bz2"
            ;;
        zip)
            check_dependency "zip"
            zip -r "${DEST}/${BACKUP_NAME}.zip" $TARGET
            FINAL_FILE="${DEST}/${BACKUP_NAME}.zip"
            ;;
        *)
            # Default to GZ if unknown
            tar -czf "${DEST}/${BACKUP_NAME}.tar.gz" $TARGET
            FINAL_FILE="${DEST}/${BACKUP_NAME}.tar.gz"
            ;;
    esac

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Success: $FINAL_FILE${NC}"
    else
        echo -e "${RED}Backup Failed.${NC}"
    fi
}

core_restore() {
    local FILE=$1
    local DEST=$2

    if [ -z "$FILE" ]; then
        echo -e "${RED}Error: Backup file (-f) is required.${NC}"
        exit 1
    fi
    if [ ! -f "$FILE" ]; then
        echo -e "${RED}Error: File '$FILE' not found.${NC}"
        exit 1
    fi

    # Default dest to current dir if empty
    DEST=${DEST:-.}
    mkdir -p "$DEST"

    echo -e "${BLUE}Restoring '$FILE' to '$DEST'...${NC}"

    if [[ "$FILE" == *.tar.gz || "$FILE" == *.tgz ]]; then
        tar -xzf "$FILE" -C "$DEST"
    elif [[ "$FILE" == *.tar.bz2 ]]; then
        tar -xjf "$FILE" -C "$DEST"
    elif [[ "$FILE" == *.zip ]]; then
        check_dependency "unzip"
        unzip "$FILE" -d "$DEST"
    else
        echo -e "${RED}Unknown format. Cannot extract.${NC}"
        exit 1
    fi

    echo -e "${GREEN}Restore Complete.${NC}"
}

# --- 3. Interactive Wrapper ---
run_interactive() {
    while true; do
        clear
        echo -e "${BLUE}=== INTERACTIVE BACKUP TOOL ===${NC}"
        echo "1) Create Backup"
        echo "2) Restore Backup"
        echo "3) Exit"
        read -p "Choice: " OPT
        
        case $OPT in
            1)
                read -p "Source Folder: " I_SRC
                read -p "Dest Folder: " I_DEST
                echo "Format: 1) gz 2) bz2 3) zip"
                read -p "Select [1-3]: " F_OPT
                case $F_OPT in
                    1) I_FMT="gz" ;;
                    2) I_FMT="bz2" ;;
                    3) I_FMT="zip" ;;
                    *) I_FMT="gz" ;;
                esac
                
                echo "Structure: 1) Keep Folder Name  2) Flat (Content Only)"
                read -p "Select [1-2]: " S_OPT
                if [ "$S_OPT" == "2" ]; then I_FLAT="true"; else I_FLAT="false"; fi
                
                core_backup "$I_SRC" "$I_DEST" "$I_FMT" "$I_FLAT"
                ;;
            2)
                read -p "Backup File Path: " I_FILE
                read -p "Restore To (Enter for current): " I_DEST
                core_restore "$I_FILE" "$I_DEST"
                ;;
            3) exit 0 ;;
            *) echo "Invalid" ;;
        esac
        echo "Press Enter..."
        read
    done
}

# --- 4. Main Execution & Argument Parsing ---

# If no arguments provided, show Usage
if [ $# -eq 0 ]; then
    usage
fi

MODE=""
SRC=""
DEST=""
FILE=""
FMT="gz"
FLAT="false"

# Parse Arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -i|--interactive)
            run_interactive
            exit 0
            ;;
        -b|--backup)
            MODE="backup"
            shift
            ;;
        -r|--restore)
            MODE="restore"
            shift
            ;;
        -s|--source)
            SRC="$2"
            shift; shift
            ;;
        -d|--dest)
            DEST="$2"
            shift; shift
            ;;
        -f|--file)
            FILE="$2"
            shift; shift
            ;;
        -t|--type)
            FMT="$2"
            shift; shift
            ;;
        -flat)
            FLAT="true"
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
done

# Execute based on mode
if [ "$MODE" == "backup" ]; then
    core_backup "$SRC" "$DEST" "$FMT" "$FLAT"
elif [ "$MODE" == "restore" ]; then
    core_restore "$FILE" "$DEST"
else
    usage
fi
