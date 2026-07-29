# SAP Ariba File Archival Utility

A reliable Bash script designed to identify, compress into ZIP format, and purge log/archive files modified prior to **January 1, 2026**.

---

## Features

- **Dynamic Parameters**: Accepts custom source and destination directories.
- **Dry-Run Mode (`-d`)**: Previews matching files without executing changes or deleting files.
- **Execution Logging**: Automatically creates a `.log` file listing every file archived.
- **Revert Mode (`-r`)**: Unzips and restores archived files back into the original directory on demand.
- **Safe Deletion**: Uses `zip -m` so source files are removed only after successful archive creation.

---

## Usage

### 1. Dry Run (Preview Changes)
```bash
./archive_pre_2026.sh /usr/sap/int/gp1/tmcc/ariba/dna/arc /backup/archives --dry-run
