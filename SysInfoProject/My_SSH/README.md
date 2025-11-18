cat << 'EOF' > README.md
# SSH Key Setup Script for User `mgveliz`

## 📋 Overview
This repository contains a Bash script (`setup_ssh_mgveliz.sh`) designed to automate the provisioning of SSH access for the user **mgveliz**. 

It ensures that the SSH directory structure exists, applies the correct security permissions (chmod 700/600), and safely appends the specific public key to the `authorized_keys` file without creating duplicates.

## 🚀 Features
* **Safety Checks:** Verifies the target user exists before running.
* **Idempotency:** Checks if the specific public key already exists to avoid duplicate entries.
* **Security Compliance:** Enforces strict permissions:
    * `~/.ssh` directory: **700** (`drwx------`)
    * `authorized_keys` file: **600** (`-rw-------`)
* **Ownership Fix:** Ensures all files are owned by `mgveliz:mgveliz` regardless of who runs the script (sudo).

## 🛠️ Prerequisites
* **OS:** Linux (Debian, Ubuntu, RHEL, SUSE, etc.)
* **Privileges:** Must be run with `sudo` or as root.
* **User:** The target user `mgveliz` must already exist on the system.

## 💻 Usage

1.  **Download or Clone the script** to the server.

2.  **Make the script executable:**
    ```bash
    chmod +x setup_ssh_mgveliz.sh
    ```

3.  **Run the script with sudo:**
    ```bash
    sudo ./setup_ssh_mgveliz.sh
    ```

## 🔍 Script Logic Breakdown

| Step | Action | Details |
| :--- | :--- | :--- |
| 1 | **Check User** | Verifies `id mgveliz` returns a valid user. Exits if not found. |
| 2 | **Create Dir** | Creates `/home/mgveliz/.ssh` if missing (`mkdir -vp`). |
| 3 | **Perms (Dir)** | Sets `.ssh` folder to `700`. |
| 4 | **Append Key** | Greps the `authorized_keys` file for the specific key string. Appends only if missing. |
| 5 | **Perms (File)** | Sets `authorized_keys` file to `600`. |
| 6 | **Ownership** | Runs `chown -R mgveliz:mgveliz` on the `.ssh` folder to ensure the user owns their own keys. |

## 🔑 Key Details
The script installs the following RSA key (associated with `mgveliz@oxya.com`):

> `ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLSV3...`

## ⚙️ Customization
To use this script for a different user, modify the variables at the top of `setup_ssh_mgveliz.sh`:

```bash
TARGET_USER="new_username"
KEY_CONTENT="ssh-rsa AAAA..."
