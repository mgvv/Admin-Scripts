#!/bin/bash
# NFS Client Setup Script with REMOTE_DIR Argument

# Usage check
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <SERVER_IP> <MOUNT_DIR> <REMOTE_DIR>"
    exit 1
fi

SERVER_IP="$1"
MOUNT_DIR="$2"
REMOTE_DIR="$3"

# Check if mount point exists
if [ -d "$MOUNT_DIR" ]; then
    echo "⚠️  Mount point $MOUNT_DIR already exists."
    read -p "Do you want to continue using this mount point? (y/n): " CONFIRM
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        echo "❌ Operation cancelled by user."
        exit 1
    fi
else
    echo " Creating mount point $MOUNT_DIR..."
    if ! mkdir -p "$MOUNT_DIR"; then
        echo "❌ Failed to create mount point."
        exit 1
    fi
fi

# Mount the NFS share
echo " Mounting $SERVER_IP:$REMOTE_DIR to $MOUNT_DIR..."
if mount | grep -q "$MOUNT_DIR"; then
    echo "✅ Already mounted."
else
    if ! mount "$SERVER_IP:$REMOTE_DIR" "$MOUNT_DIR"; then
        echo "❌ Mount failed. Please check server availability and permissions."
        exit 1
    fi
    echo "✅ Mount successful."
fi

# Summary
echo -e "
📦 NFS Client Mount Summary:"
echo "Server IP       : $SERVER_IP"
echo "Remote Share    : $REMOTE_DIR"
echo "Mount Point     : $MOUNT_DIR"
mount | grep "$MOUNT_DIR"

# Ask to add to /etc/fstab
read -p "Do you want to make this mount permanent in /etc/fstab? (y/n): " ADD_FSTAB
if [[ "$ADD_FSTAB" == "y" || "$ADD_FSTAB" == "Y" ]]; then
    echo "$SERVER_IP:$REMOTE_DIR $MOUNT_DIR nfs defaults 0 0" >> /etc/fstab
    echo "✅ Entry added to /etc/fstab."
fi
