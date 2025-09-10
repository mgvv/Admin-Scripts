#!/bin/bash
# NFS Server Setup Script with Backup and Rollback

# Usage check
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <SHARE_DIR> <CLIENT_IP>"
    exit 1
fi

SHARE_DIR="$1"
CLIENT_IP="$2"
EXPORTS_FILE="/etc/exports"
BACKUP_FILE="/etc/exports.bak_$(date +%Y%m%d_%H%M%S)"

# Check if the directory exists
if [ -d "$SHARE_DIR" ]; then
    echo "⚠️  Directory $SHARE_DIR already exists."
    read -p "Do you want to continue using this directory? (y/n): " CONFIRM
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        echo "❌ Operation cancelled by user."
        exit 1
    fi
else
    echo "📁 Creating directory $SHARE_DIR..."
    if ! mkdir -p "$SHARE_DIR"; then
        echo "❌ Failed to create directory $SHARE_DIR."
        exit 1
    fi
    chown nobody:nogroup "$SHARE_DIR"
fi

# Backup /etc/exports
echo "🗂️ Backing up $EXPORTS_FILE to $BACKUP_FILE..."
if ! cp "$EXPORTS_FILE" "$BACKUP_FILE"; then
    echo "❌ Failed to back up $EXPORTS_FILE."
    exit 1
fi

# Check if the export rule already exists
if grep -q "$SHARE_DIR $CLIENT_IP" "$EXPORTS_FILE"; then
    echo "🔁 Export rule for $CLIENT_IP already exists in $EXPORTS_FILE."
else
    echo "➕ Adding export rule for $CLIENT_IP..."
    echo "$SHARE_DIR $CLIENT_IP(rw,sync,no_subtree_check)" >> "$EXPORTS_FILE"
fi

# Apply export configuration
echo "🔄 Applying export configuration..."
if ! exportfs -a; then
    echo "❌ Failed to apply export configuration."
    read -p "Do you want to rollback to the previous exports file? (y/n): " ROLLBACK
    if [[ "$ROLLBACK" == "y" || "$ROLLBACK" == "Y" ]]; then
        echo "⏪ Restoring backup..."
        if cp "$BACKUP_FILE" "$EXPORTS_FILE"; then
            exportfs -a
            echo "✅ Rollback successful."
        else
            echo "❌ Rollback failed. Manual intervention required."
        fi
    else
        echo "⚠️ Changes not rolled back. Please check manually."
    fi
    exit 1
fi

# Summary
echo -e "
📦 NFS Export Summary:"
echo "Shared Directory : $SHARE_DIR"
echo "Client IP        : $CLIENT_IP"
echo "Export Options   : rw, sync, no_subtree_check"
echo "Backup File      : $BACKUP_FILE"
echo "Export List:"
exportfs -v
