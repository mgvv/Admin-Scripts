# NFS Export Setup Script

This script automates the setup of an NFS (Network File System) export on a Linux server. It includes safety checks, backup of the `/etc/exports` file, and rollback support in case of failure.

## 📦 Features
- Accepts shared directory and client IP as arguments
- Validates if the directory exists and prompts the user
- Backs up `/etc/exports` before making changes
- Adds export rule if not already present
- Applies export configuration
- Supports rollback if export fails
- Displays a summary of the export configuration

## 🛠️ Requirements
- Linux system with NFS utilities installed (`nfs-utils`)
- Root or sudo privileges

## 🚀 Usage
```bash
sudo ./nfs_export_setup.sh <SHARE_DIR> <CLIENT_IP>
```

### Example
```bash
sudo ./nfs_export_setup.sh /srv/nfs/shared 192.168.1.100
```

## 📁 Output
- Creates the shared directory if it doesn't exist
- Adds an export rule to `/etc/exports`
- Backs up the original exports file to `/etc/exports.bak_<timestamp>`
- Displays the current export list using `exportfs -v`

## 🔄 Rollback
If the export configuration fails, the script prompts the user to restore the previous version of `/etc/exports` from the backup.

## 📄 License
This script is provided as-is without warranty. Use at your own risk.
