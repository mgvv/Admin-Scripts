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

```
set-static-ip-nmcli.sh
```

Make it executable:

```bash
chmod +x set-static-ip-nmcli.sh
```

Run as root (required by NetworkManager):

```bash
sudo ./set-static-ip-nmcli.sh ...
```

---

## 🚀 Usage

### Basic static IP configuration

```bash
sudo ./set-static-ip-nmcli.sh   -i ens192   -a 10.54.240.204   -p 25   -g 10.54.240.129
```

### Add DNS servers

```bash
sudo ./set-static-ip-nmcli.sh   -i ens192   -a 10.54.240.204   -p 25   -g 10.54.240.129   -d 8.8.8.8,1.1.1.1
```

### Adjust nmcli timeout

```bash
sudo ./set-static-ip-nmcli.sh -t 30 ...
```

### Dry-run mode (no changes made)

```bash
sudo ./set-static-ip-nmcli.sh --dry-run   -i ens192   -a 10.54.240.204   -p 25   -g 10.54.240.129
```

---

## 📝 Parameters

| Flag | Description | Required |
|------|-------------|----------|
| `-i` | Network interface (`ens192`, `eth0`, etc.) | ✔ |
| `-a` | IPv4 address | ✔ |
| `-p` | Prefix length (`25` for `/25`) | ✔ |
| `-g` | Default IPv4 gateway | ✔ |
| `-d` | One or more DNS servers (comma-separated) | ✘ |
| `-t` | Timeout (seconds) for `nmcli` operations | ✘ |
| `--dry-run` | Do not apply — only show commands | ✘ |
| `-h` | Show help | ✘ |

---

## 🔒 Rollback and Backup

Before modifying anything, the script exports a full backup:

```
backup-<connection-name>-YYYYMMDD-HHMMSS.nmconnection
```

If any command fails during configuration or interface restart:

- The script **automatically imports** the backup
- Attempts to restore the previous connection state

You can manually restore a backup at any time:

```bash
sudo nmcli connection import type file file backup-file.nmconnection
```

---

## 🧪 Verification

After applying changes, the script prints:

- IPv4 address on the interface
- Default routes
- NetworkManager connection summary

If verification fails, the script exits with a failure code.

---

## ❗ Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | Not root / `nmcli` missing |
| `2` | Invalid arguments / validation failure |
| `3` | Interface or connection profile missing |
| `4` | Backup export failed |
| `5` | Failed to apply IPv4 settings |
| `6` | Failed to restart connection |
| `7` | Verification failure |
| `8` | Rollback failed; manual fix required |

---

## ⚠️ Remote Server Warning

Running:

```
nmcli connection down <profile>
```

**will disconnect your SSH session**.

If using this script over SSH, consider:

- Running inside a console (iLO, iDRAC, VMware console)
- Using `at` or `systemd-run` to schedule a rollback if the server becomes unreachable

Ask if you want an automated rollback timer added.

---

## 🛠 Requirements

- Linux with **NetworkManager**
- `nmcli` available in `$PATH`
- Root privileges (`sudo`)

---

## 📄 License

MIT License (or specify your own — let me know if you want a template added).

---

## 🤝 Contributing

Pull requests and improvements are welcome!  
Feel free to open issues for feature requests or bug reports.

---

## 👤 Author

**Manuel Gabriel Veliz**  
Contract SAP Basis Engineer

---
