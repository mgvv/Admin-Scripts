# top-swap.sh — Top processes by swap usage (with full command lines)

`top-swap.sh` scans `/proc` to show the **top processes by swap usage** on Linux, including **PID**, **Name**, optional **User**, **Swap (kB)**, and the **full command line**. It’s efficient (reads `cmdline` only for the top entries) and supports user filtering and machine-friendly TSV output.

---

## ✨ Features

- 🔎 Shows **PID**, **Name**, **Swap (kB)**, and **full command line**
- 👤 Optional **User** column with `--show-user`
- 🔐 **User filtering**: `--mine`, `-u user1[,user2]`, `-U uid1[,uid2]`
- 🧮 Choose **top N** with `-n N` or show **all** with `--all`
- 📄 **TSV output** (`--tsv`) for scripting
- 🧵 Gracefully handles kernel threads / unreadable `cmdline` (prints `[Name]`)
- 🚀 Designed for speed: reads `/proc/<pid>/cmdline` **only** for top rows

---

## 🧩 Requirements

- **Linux** with `/proc` mounted
- **Bash 4+** (associative arrays)
- Tools: `awk`, `sort`, `head`, `tr`, `id`, `getent`
- Permissions: You may need `sudo` on systems using `hidepid` or to read other users’ `cmdline`

Check your Bash version:

echo "$BASH_VERSION"
