# top-ram.sh

`top-ram.sh` is a Bash script that displays the top processes consuming the most **RAM (Resident Set Size - VmRSS)** on a Linux system. It provides detailed information including PID, process name, RAM usage in kilobytes, and the full command line used to launch the process.

## Features

- Lists processes using RAM, sorted by usage.
- Supports filtering by:
  - Specific usernames (`-u` or `--user`)
  - Specific UIDs (`-U` or `--uid`)
  - Current user only (`--mine`)
- Output options:
  - Pretty-printed table (default)
  - Tab-separated values (`--tsv`)
- Show top N processes (`-n`)
- Show all processes with non-zero RAM usage (`--all`)
- Optionally include a user column (`--show-user`)

## Requirements

- Bash 4+
- Standard Unix utilities: `awk`, `sort`, `head`, `tr`, `id`, `getent`

## Usage


bash ./top-ram.sh
