```bash
cat << 'EOF' > README.md
# Smart Backup & Restore Tool

A versatile, hybrid Bash script for Linux that handles directory backups and restorations. It supports both a user-friendly **Interactive Menu** for manual use and a **Command Line Interface (CLI)** for automation and cron jobs.

## 🚀 Features

* **Hybrid Modes:** Use the interactive menu (`-i`) or command-line flags.
* **Multiple Formats:** Support for `.tar.gz` (Standard), `.tar.bz2` (High Compression), and `.zip` (Windows compatible).
* **Path Flexibility:** Choose between keeping the directory structure or a "Flat" backup (contents only).
* **Smart Restore:** Auto-detects the archive format during restoration—no need to specify the file type manually.
* **Safe:** Checks for required dependencies (`zip`, `unzip`) before attempting operations.

## 📋 Prerequisites

The script uses standard Linux tools. For `.zip` support, ensure you have `zip` and `unzip` installed:

\`\`\`bash
# Ubuntu/Debian
sudo apt install zip unzip

# RHEL/CentOS
sudo yum install zip unzip
\`\`\`

## ⚙️ Installation

1.  Download or create the script file:
    \`\`\`bash
    nano smart_backup.sh
    \`\`\`
2.  Paste the script code and save.
3.  Make the script executable:
    \`\`\`bash
    chmod +x smart_backup.sh
    \`\`\`

## 📖 Usage

Running the script without arguments displays the help menu:

\`\`\`bash
./smart_backup.sh
\`\`\`

### 1. Interactive Mode
Best for manual, ad-hoc backups. This launches a text-based menu wizard.

\`\`\`bash
./smart_backup.sh -i
\`\`\`

### 2. Backup via CLI
Best for scripts and automation.

**Syntax:**
\`\`\`bash
./smart_backup.sh -b -s <SOURCE> -d <DESTINATION> [OPTIONS]
\`\`\`

**Examples:**

* **Standard Backup (keeps folder name):**
    \`\`\`bash
    ./smart_backup.sh -b -s /var/www/html -d /backups
    \`\`\`
* **Backup with specific format (bzip2):**
    \`\`\`bash
    ./smart_backup.sh -b -s /home/user/docs -d /backups -t bz2
    \`\`\`
* **"Flat" Backup (contents only, useful for dumping files directly):**
    \`\`\`bash
    ./smart_backup.sh -b -s /var/log -d /tmp/logs -flat
    \`\`\`

### 3. Restore via CLI

**Syntax:**
\`\`\`bash
./smart_backup.sh -r -f <BACKUP_FILE> -d <DESTINATION>
\`\`\`

**Example:**
\`\`\`bash
./smart_backup.sh -r -f /backups/html_20231010.tar.gz -d /var/www
\`\`\`

---

## 🚩 Argument Reference

| Flag | Argument | Description |
| :--- | :--- | :--- |
| **-i** | None | Enter **Interactive Mode**. |
| **-b** | None | Trigger **Backup Mode**. Requires \`-s\` and \`-d\`. |
| **-r** | None | Trigger **Restore Mode**. Requires \`-f\`. |
| **-s** | \`<path>\` | **Source** directory to backup. |
| **-d** | \`<path>\` | **Destination** directory (for saving backup or unpacking restore). |
| **-f** | \`<file>\` | **File** path of the archive to restore. |
| **-t** | \`<type>\` | Compression type: \`gz\` (default), \`bz2\`, or \`zip\`. |
| **-flat**| None | **Flat Mode**: Backs up files inside the folder, not the folder itself. |
| **-h** | None | Show help/usage message. |

## 🤖 Automation (Cron Job Example)

To run a backup every day at 3:00 AM using this script:

1.  Open crontab: \`crontab -e\`
2.  Add the following line:

\`\`\`cron
0 3 * * * /path/to/smart_backup.sh -b -s /home/user/data -d /mnt/backups -t gz
\`\`\`
EOF
