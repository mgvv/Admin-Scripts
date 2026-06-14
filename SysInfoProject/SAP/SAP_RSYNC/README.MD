```python
readme_content = """# SAP Environment Sync Script

A robust, interactive Bash script designed to securely synchronize SAP instance directories (such as `ASCS` and primary application servers) across environments using `rsync`.

## 🌟 Features

* **Interactive Execution:** Prompts the user before synchronizing each directory, allowing for granular control.
* **Dry-Run Mode:** Includes a `--dry-run` flag to simulate the transfer and safely review what will be copied or deleted without making actual changes.
* **Comprehensive Logging:** Automatically generates timestamped log files capturing both standard output and errors.
* **Strict Error Handling:** Captures pipeline errors accurately and aborts subsequent synchronizations if a directory fails, preventing inconsistent partial states.
* **Permission Preservation:** Utilizes `rsync` flags (`-aHAX`) specifically chosen to preserve critical SAP ACLs, extended attributes, and numeric IDs across systems.

## 📋 Prerequisites

* **OS:** Linux (Bash shell)
* **Packages:** `rsync` must be installed on both the source and target servers.
* **Access:** SSH passwordless access (key-based authentication) configured for the target user (e.g., `root`) to the target IP.

## ⚙️ Configuration

Before running the script, open it in your preferred text editor (like `vim` or `nano`) and adjust the variables at the top to match your environment:


```

```text
File generated successfully.

```bash
TARGET_IP="10.84.242.225"      # The destination server IP
TARGET_USER="root"             # The user used for the SSH connection
SID="SP1"                      # The SAP System ID
LOG_DIR="/var/log/sap_sync"    # Directory where logs will be stored

```

*Note: Ensure the user executing the script has write permissions to the `LOG_DIR`.*

## 🚀 Usage

### 1. Make the script executable

First, ensure the script has the correct execute permissions:

```bash
chmod +x sync_script.sh

```

### 2. Standard Execution

Run the script interactively. It will pause and ask for confirmation before syncing each path defined in the `directories` array.

```bash
./sync_script.sh

```

### 3. Dry-Run Execution (Recommended for first use)

Test the synchronization safely. This will output exactly what rsync *would* do without transferring any data.

```bash
./sync_script.sh --dry-run

```

## 📂 Targeted Directories

By default, the script is configured to synchronize the following standard NetWeaver/ABAP paths:

* `/usr/sap/<SID>/ASCS01/sec/`
* `/usr/sap/<SID>/D00/sec/`
* `/usr/sap/<SID>/D00/log/`
* `/sapmnt/<SID>/`

You can modify the `directories` array in the script to add or remove paths as needed.

## 📝 Logging

Logs are automatically stored in `/var/log/sap_sync/` (or your configured `LOG_DIR`).
Each run creates a unique file formatted as `sync_YYYYMMDD_HHMMSS.log`. You can review these logs for auditing purposes or to troubleshoot any failed transfers.
