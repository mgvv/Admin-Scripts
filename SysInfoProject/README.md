
# SysInfo Bash Script

This is a modular, menu-driven Bash script designed to provide system information and perform basic administrative tasks on a Linux server or desktop.

## 📁 Modules

- **main.sh**: Core logic and execution flow.
- **functions.sh**: Utility functions for formatting and display.
- **menu.sh**: Menu rendering and user input handling.

## 🚀 Features

- View OS, hostname, DNS, and network info
- Monitor memory, disk, and process usage
- Manage users and groups
- Perform file operations (create, delete, compress, etc.)
- Create symbolic links with validation
- Logging and root access checks

## 🛠️ Requirements

- Bash shell
- Root privileges (required for user and system operations)

## 📦 Usage

1. Make sure all scripts are executable:
   ```bash
   chmod +x main.sh functions.sh menu.sh
   ```

2. Run the main script:
   ```bash
   sudo ./main.sh
   ```

3. Follow the on-screen menu to perform operations.

## 📝 Logging

All actions are logged to `/var/log/sysinop.log`.

## 🔒 Security

The script checks for root access before execution and validates inputs for critical operations.

## 📬 Author

Originally created by Sathish Arthar (Jan 2014)
Enhanced and modularized for maintainability and security.
