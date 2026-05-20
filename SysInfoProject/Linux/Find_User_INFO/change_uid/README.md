# change_uid.sh - Safe Linux UID Modification Script

A robust, interactive bash script designed to safely change a user's User ID (UID) in Linux. 

Changing a UID manually can leave behind orphaned files and cause system conflicts if the user has running processes. This script automates the safety checks, handles active processes, permanently changes the UID, and performs a comprehensive filesystem scan to update file ownership everywhere—not just in the home directory.

## ✨ Features

* **Dry-Run Mode (`--dry-run`):** Safely simulate the entire process. See which processes would be killed and exactly which files would be modified without making any actual changes to your system.
* **Filesystem-Wide Updates:** Automatically scans the system to find and update files owned by the old UID. Intelligently skips virtual filesystems (`/proc`, `/sys`, `/dev`) to prevent permission errors and speed up the scan.
* **Process Management:** Detects if the target user is currently running any processes and provides an interactive prompt to safely terminate them before modifying the account.
* **Collision Detection:** Verifies that your chosen new UID is not already taken by another user or system account.
* **Detailed Auditing:** Generates a line-by-line log of every file modified, including timestamps. 
* **Custom Log Paths (`--log-dir`):** Save your audit logs to a centralized directory of your choosing (defaults to `/var/log` or `/tmp` for dry-runs).

## 📋 Prerequisites

* **OS:** Linux
* **Privileges:** Root access (`sudo`) is required to modify users and change system-wide file ownership.
* **Dependencies:** Standard coreutils (`usermod`, `find`, `chown`, `pgrep`, `pkill`)

## 🚀 Installation

Clone the repository and make the script executable:

```bash
# Clone the repository
git clone [https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git](https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git)

# Navigate into the directory
cd YOUR_REPOSITORY

# Make the script executable
chmod +x change_uid.sh
```

## 💻 Usage
The script can be run interactively. Simply execute it with sudo and follow the on-screen prompts to enter the username and the new UID.

### Basic Execution
```bash
sudo ./change_uid.sh
Dry-Run (Simulation)
Highly recommended before making permanent changes on production servers.
```

```bash
sudo ./change_uid.sh --dry-run
Custom Log Directory
Direct the output logs to a specific folder. If the directory does not exist, the script will attempt to create it.
```

```bash
sudo ./change_uid.sh --log-dir /opt/admin/logs
```

### Help Menu

```bash
sudo ./change_uid.sh --help
```

## ⚠️ Important Safety Notes
Time Consumption: The filesystem scan (find /) can take several minutes on systems with large hard drives or network-attached storage. Please be patient and do not interrupt the script while it is running.

Symlinks: The script uses chown -h to change the ownership of symbolic links themselves, rather than following the link and accidentally changing the target file's owner.

Backups: Always ensure you have a backup of critical system configurations before modifying user accounts.
