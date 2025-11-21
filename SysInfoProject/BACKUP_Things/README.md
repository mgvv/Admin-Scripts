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

```bash
# Ubuntu/Debian
sudo apt install zip unzip

# RHEL/CentOS
sudo yum install zip unzip

