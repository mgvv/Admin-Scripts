#!/usr/bin/env bash
# top-swap.sh — Show top processes by swap usage with full command lines.
# Default: top 10. Use -n N to change. Use --tsv for tab-separated output. Use --all to show all.
# User filtering: --mine, -u/--user USER[,USER2], -U/--uid UID[,UID2]
# --show-user: include a User column (pretty & TSV)

set -euo pipefail

# Ensure Bash 4+ (associative arrays required)
if [[ -z "${BASH_VERSINFO:-}" || "${BASH_VERSINFO[0]}" -lt 4 ]]; then
  echo "This script requires Bash 4+ (found: ${BASH_VERSION:-unknown}). Run with: bash $0 ..." >&2
  exit 1
fi

TOP=10
OUTPUT="pretty"   # "pretty" or "tsv"
SHOW_ALL=0
SHOW_USER=0

# User filtering
ONLY_MINE=0
declare -a USERS=()   # usernames
declare -a UIDS=()    # numeric UIDs

usage() {
  cat <<'EOF'
Usage: top-swap.sh [-n N] [--tsv] [--all] [--mine] [-u USER[,USER2] ...] [-U UID[,UID2] ...] [--show-user] [-h]

Options:
  -n N             Show top N processes by swap (default: 10)
  --tsv            Output as tab-separated values
  --all            Show all processes with non-zero swap (no top limit)
  --mine           Show only processes owned by the current user (real UID)
  -u, --user USER  Filter by username (repeatable or comma-separated)
  -U, --uid UID    Filter by numeric UID (repeatable or comma-separated)
  --show-user      Include a User column (pretty & TSV)
  -h               Show this help

Notes:
  - Use 'bash ./top-swap.sh' (not 'sh'). Run with sudo if /proc is restricted.
  - Filtering uses Real UID from /proc/<pid>/status (Uid: line).
  - Kernel threads or unreadable cmdlines are shown as [Name].
EOF
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n)
      [[ $# -ge 2 ]] || { echo "Error: -n requires a number" >&2; exit 1; }
      TOP="$2"; shift 2;;
    --tsv)
      OUTPUT="tsv"; shift;;
    --all)
      SHOW_ALL=1; shift;;
    --mine)
      ONLY_MINE=1; shift;;
    -u|--user)
      [[ $# -ge 2 ]] || { echo "Error: $1 requires an argument" >&2; exit 1; }
      IFS=',' read -r -a tmp_users <<< "$2"; USERS+=("${tmp_users[@]}"); shift 2;;
    -U|--uid)
      [[ $# -ge 2 ]] || { echo "Error: $1 requires an argument" >&2; exit 1; }
      IFS=',' read -r -a tmp_uids <<< "$2"; UIDS+=("${tmp_uids[@]}"); shift 2;;
    --show-user)
      SHOW_USER=1; shift;;
    -h|--help)
      usage; exit 0;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1;;
  esac
done

# Ensure required tools exist
for cmd in awk sort head tr id getent; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Missing required command: $cmd" >&2; exit 1; }
done

# Build the UID filter set
declare -A UID_SET=()
if [[ "$ONLY_MINE" -eq 1 ]]; then
  UID_SET["$(id -u)"]=1
fi

# Loop only if arrays have elements (avoid empty element under set -u)
if ((${#USERS[@]})); then
  for u in "${USERS[@]}"; do
    if uid=$(id -u "$u" 2>/dev/null); then
      UID_SET["$uid"]=1
    else
      echo "Warning: user '$u' not found (skipping)" >&2
    fi
  done
fi

if ((${#UIDS[@]})); then
  for uid in "${UIDS[@]}"; do
    if [[ "$uid" =~ ^[0-9]+$ ]]; then
      UID_SET["$uid"]=1
    else
      echo "Warning: invalid UID '$uid' (skipping)" >&2
    fi
  done
fi

# Build a comma-separated filter string
UID_FILTER=""
for k in "${!UID_SET[@]}"; do
  UID_FILTER+="${UID_FILTER:+,}$k"
done

# Locale-neutral sort for numbers
export LC_ALL=C

# Function to generate the raw list: <swap_kB>\t<PID>\t<UID>\t<Name>
gen_list() {
  awk -v uid_filter="$UID_FILTER" -F':' '
    BEGIN {
      use_filter = (length(uid_filter) > 0)
      if (use_filter) {
        n = split(uid_filter, allow, /,/)
        for (i=1; i<=n; i++) allow_uids[allow[i]] = 1
      }
    }
    FNR==1 { pid=""; name=""; swap=""; uid="" }  # reset per file
    { gsub(/^[ \t]+/, "", $2) }                  # trim leading spaces
    $1=="Pid"    { pid=$2; next }
    $1=="Name"   { name=$2; next }
    $1=="Uid"    { split($2, u, /[ \t]+/); uid=u[1]; next }   # Real UID
    $1=="VmSwap" {
      if ($2 != "" && $2 != "0 kB") {
        if (!use_filter || (uid in allow_uids)) {
          split($2, v, /[ \t]+/)                 # v[1] = numeric kB
          printf "%s\t%s\t%s\t%s\n", v[1], pid, uid, name
        }
      }
    }
  ' /proc/[0-9]*/status 2>/dev/null
}

# Fetch and optionally limit top N
if [[ "$SHOW_ALL" -eq 1 ]]; then
  mapfile -t LINES < <( gen_list | sort -k1,1nr )
else
  mapfile -t LINES < <( gen_list | sort -k1,1nr | head -n "$TOP" )
fi

# If no results, exit gracefully
if [[ ${#LINES[@]} -eq 0 ]]; then
  if [[ -n "$UID_FILTER" ]]; then
    echo "No processes with non-zero swap found for the specified user(s) or insufficient permissions." >&2
  else
    echo "No processes with non-zero swap found (or insufficient permissions)." >&2
  fi
  exit 0
fi

# Username cache for --show-user
declare -A USER_CACHE=()

resolve_user() {
  local uid="$1"
  if [[ -n "${USER_CACHE[$uid]:-}" ]]; then
    echo "${USER_CACHE[$uid]}"; return
  fi
  local name
  name="$(getent passwd "$uid" | cut -d: -f1 || true)"
  [[ -n "$name" ]] || name="#$uid"
  USER_CACHE["$uid"]="$name"
  echo "$name"
}

# Header
if [[ "$OUTPUT" == "pretty" ]]; then
  if [[ "$SHOW_USER" -eq 1 ]]; then
    printf "%10s %-30s %-12s %12s  %s\n" "PID" "Name" "User" "Swap(kB)" "Command"
  else
    printf "%10s %-30s %12s  %s\n" "PID" "Name" "Swap(kB)" "Command"
  fi
fi

# Print rows: each line is <swap_kB>\t<PID>\t<UID>\t<Name>
for line in "${LINES[@]}"; do
  IFS=$'\t' read -r swap_kb pid uid name <<< "$line"

  # Read full cmdline; convert NULs to spaces
  cmdline=""
  if [[ -r "/proc/$pid/cmdline" ]]; then
    cmdline="$(tr '\0' ' ' <"/proc/$pid/cmdline" 2>/dev/null || true)"
  fi
  [[ -n "$cmdline" ]] || cmdline="[$name]"

  if [[ "$OUTPUT" == "tsv" ]]; then
    if [[ "$SHOW_USER" -eq 1 ]]; then
      user="$(resolve_user "$uid")"
      printf "%s\t%s\t%s\t%s\t%s\n" "$pid" "$name" "$user" "$swap_kb" "$cmdline"
    else
      printf "%s\t%s\t%s\t%s\n" "$pid" "$name" "$swap_kb" "$cmdline"
    fi
  else
    if [[ "$SHOW_USER" -eq 1 ]]; then
      user="$(resolve_user "$uid")"
      printf "%10s %-30s %-12s %12s  %s\n" "$pid" "$name" "$user" "$swap_kb" "$cmdline"
    else
      printf "%10s %-30s %12s  %s\n" "$pid" "$name" "$swap_kb" "$cmdline"
    fi
  fi
done
