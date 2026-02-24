# Static IPv4 Configuration Script for NetworkManager (`nmcli`)

This repository contains a hardened Bash script that automates the process of configuring a static IPv4 address on Linux systems using **NetworkManager** (`nmcli`).  
It includes full error handling, rollback capabilities, validation logic, and optional dry-run mode for safe change previews.

---

## 📌 Features

- Configure IPv4 static addressing with:
  - IP address + prefix
  - Gateway
  - DNS servers (optional)
- Automatic detection of active `nmcli` connection profile
- Comprehensive error handling and exit codes
- Automatic **backup** of existing connection profile
- Rollback on failure (restores original `.nmconnection`)
- Timeout support for slow networking services
- Dry-run mode for change validation
- Safe logging with clear `[INFO]`, `[WARN]`, and `[ERROR]` blocks
- IPv4 format validation for correctness and safety

---

## 📂 Script File

The script shipped with this repository:

