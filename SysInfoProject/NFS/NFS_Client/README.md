# NFS Client Setup Script

This script automates the process of mounting an NFS (Network File System) share from a remote server to a local directory on a Linux client.

## 📦 Features
- Accepts server IP and mount directory as arguments
- Validates if the mount point exists and prompts the user
- Mounts the NFS share from the server
- Displays a summary of the mount
- Optionally adds the mount to `/etc/fstab` for persistence

## ⚙️ Requirements
- Linux system with NFS client utilities installed (`nfs-utils` or `nfs-common`)
- Root or sudo privileges

## 🚀 Usage
```bash
sudo ./nfs_client_setup.sh <SERVER_IP> <MOUNT_DIR>
```

### Example
```bash
sudo ./nfs_client_setup.sh 192.168.1.10 /mnt/nfs/shared
```

## 📁 Output
- Creates the mount point if it doesn't exist
- Mounts the NFS share from `/srv/nfs/shared` on the server
- Displays the current mount status

## 📌 fstab Option
After mounting, the script will ask if you want to make the mount permanent by adding an entry to `/etc/fstab`. This ensures the NFS share is mounted automatically on system boot.

## 📄 License
This script is provided as-is without warranty. Use at your own risk.
