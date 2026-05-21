# change_uid.sh - Safe Linux UID Modification Script

A robust, interactive bash script designed to safely change a user's User ID (UID) in Linux. 

Changing a UID manually can leave behind orphaned files and cause system conflicts if the user has running processes. This script automates the safety checks, handles active processes, permanently changes the UID, and performs a surgical filesystem scan to update file ownership exactly where you need it.

## ✨ Features

* **Targeted Scanning (`--scan-path`):** Save time by restricting the file ownership update to a specific directory (e.g., `/home` or `/var/www`). Defaults to scanning the entire root (`/`) if omitted.
* **Dry-Run Mode (`--dry-run`):** Safely simulate the entire process. See which processes would be killed and exactly which files would be modified without making any actual changes to your system.
* **Custom Log Paths (`--log-dir`):** Save your audit logs to a centralized directory of your choosing (defaults to `/var/log` or `/tmp` for dry-runs).
* **Process Management:** Detects if the target user is currently running any processes and provides an interactive prompt to safely terminate them before modifying the account.
* **Collision Detection:** Verifies that your chosen new UID is not already taken by another user or system account.
* **Detailed Auditing:** Generates a line-by-line log of every file modified, including the target scan path and timestamps. 

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
(Note: Replace YOUR_USERNAME and YOUR_REPOSITORY with your actual GitHub details).

## 💻 Usage
The script is interactive. Execute it with sudo and follow the on-screen prompts to enter the username and the new UID. You can append optional flags to customize its behavior.

Basic Execution (Scans entire filesystem)
```bash
sudo ./change_uid.sh
```

### Targeted Scan (Recommended for speed)
Limit the file ownership updates to a specific folder, such as the user's web directory.

```bash
sudo ./change_uid.sh --scan-path /var/www/html
```
### Dry-Run (Simulation)
Highly recommended before making permanent changes. Simulates the update on a specific directory and outputs the simulated log to a custom folder.

```bash
sudo ./change_uid.sh --dry-run --scan-path /home --log-dir /tmp/uid_tests
```
### Custom Log Directory
Direct the output logs to a specific folder. If the directory does not exist, the script will attempt to create it automatically.

```bash
sudo ./change_uid.sh --scan-path /opt/data --log-dir /opt/admin/logs
```
### Help Menu
```bash
sudo ./change_uid.sh --help
```
## ⚠️ Important Safety Notes
Time Consumption: If you do not provide a --scan-path, the script runs a full filesystem scan (find /). This can take several minutes on systems with large hard drives or network-attached storage.

Virtual Filesystems: The script intelligently ignores /proc, /sys, and /dev to prevent permission errors and speed up scans.

Symlinks: The script uses chown -h to change the ownership of symbolic links themselves, rather than following the link and accidentally changing the target file's owner.

Backups: Always ensure you have a backup of critical system configurations before modifying user accounts.

## 📄 License
This project is licensed under the MIT License. You are free to use, modify, and distribute this script as needed.
