#!/usr/bin/env bash
#
# set-static-ip-nmcli.sh
# Configure a NetworkManager connection with a static IPv4 address using nmcli,
# with robust error handling, timeouts, and rollback support.
#
# Usage:
#   sudo ./set-static-ip-nmcli.sh -i ens192 -a 10.54.240.204 -p 25 -g 10.54.240.129 [-d 8.8.8.8,1.1.1.1] [--dry-run] [-t 20]
#
# Exit codes:
#   0  Success
#   1  Not root or nmcli missing
#   2  Usage / argument validation error
#   3  Interface / connection profile not found
#   4  Backup export failed
#   5  Apply settings failed
#   6  Restarting connection failed
#   7  Verification failed
#   8  Rollback failed (after a prior failure)

set -euo pipefail

# --- Globals ---
BACKUP=""
CONN_NAME=""
IFACE=""
ADDR=""
PREFIX=""
GATEWAY=""
DNS_LIST=""
DRY_RUN=0
NM_TIMEOUT=15  # seconds for nmcli -w

# --- Logging helpers ---
log()  { printf '[INFO] %s\n' "$*" >&2; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
err()  { printf '[ERROR] %s\n' "$*" >&2; }

# --- Trap for diagnostics ---
# Reports command and line on unhandled error (still allows our custom handling).
trap 'rc=$?; err "Unhandled error at line $LINENO. Last command failed. Exit code: $rc"; exit $rc' ERR

# --- Show usage ---
usage() {
  cat <<'EOF'
Usage:
  sudo ./set-static-ip-nmcli.sh -i <interface> -a <ipv4_address> -p <prefix_len> -g <gateway> [-d <dns_list>] [--dry-run] [-t <timeout>]

Required:
  -i  Network interface (e.g., ens192)
  -a  IPv4 address (e.g., 10.54.240.204)
  -p  Prefix length (e.g., 25 for /25)
  -g  IPv4 gateway (e.g., 10.54.240.129)

Optional:
  -d  Comma-separated DNS servers (e.g., 8.8.8.8,1.1.1.1)
  --dry-run  Show what would be done without making changes
  -t  Timeout (seconds) for nmcli commands (default 15)

Examples:
  sudo ./set-static-ip-nmcli.sh -i ens192 -a 10.54.240.204 -p 25 -g 10.54.240.129
  sudo ./set-static-ip-nmcli.sh -i ens192 -a 10.54.240.204 -p 25 -g 10.54.240.129 -d 8.8.8.8,1.1.1.1 -t 20
EOF
}

# --- Validator helpers ---
is_ipv4() {
  local ip="$1"
  # Basic pattern + numeric ranges
  [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
  IFS='.' read -r o1 o2 o3 o4 <<<"$ip"
  for o in "$o1" "$o2" "$o3" "$o4"; do
    [[ "$o" -ge 0 && "$o" -le 255 ]] || return 1
  done
  return 0
}

is_prefix() {
  local p="$1"
  [[ "$p" =~ ^[0-9]+$ ]] && [[ "$p" -ge 0 && "$p" -le 32 ]]
}

# --- Command runner (with dry-run support) ---
run() {
  local desc="$1"; shift
  if (( DRY_RUN )); then
    log "[dry-run] $desc: $*"
    return 0
  fi
  log "$desc: $*"
  if ! "$@"; then
    err "Failed: $desc"
    return 1
  fi
}

# --- Parse arguments ---
while (( "$#" )); do
  case "$1" in
    -i) IFACE="${2:-}"; shift 2 ;;
    -a) ADDR="${2:-}"; shift 2 ;;
    -p) PREFIX="${2:-}"; shift 2 ;;
    -g) GATEWAY="${2:-}"; shift 2 ;;
    -d) DNS_LIST="${2:-}"; shift 2 ;;
    -t) NM_TIMEOUT="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) err "Unknown argument: $1"; usage; exit 2 ;;
  esac
done

# --- Basic validation ---
if [[ -z "${IFACE}" || -z "${ADDR}" || -z "${PREFIX}" || -z "${GATEWAY}" ]]; then
  err "Missing required arguments."
  usage
  exit 2
fi

if [[ $EUID -ne 0 ]]; then
  err "Please run as root (use sudo)."
  exit 1
fi

if ! command -v nmcli >/dev/null 2>&1; then
  err "nmcli not found. Ensure NetworkManager is installed."
  exit 1
fi

if ! is_ipv4 "$ADDR"; then
  err "Invalid IPv4 address: $ADDR"
  exit 2
fi

if ! is_prefix "$PREFIX"; then
  err "Invalid prefix length (0-32 expected): $PREFIX"
  exit 2
fi

if ! is_ipv4 "$GATEWAY"; then
  err "Invalid IPv4 gateway: $GATEWAY"
  exit 2
fi

# --- Ensure the interface exists in NetworkManager ---
if ! nmcli -t -f DEVICE device status | awk -F: '{print $1}' | grep -qx "$IFACE"; then
  err "Interface '$IFACE' not found in NetworkManager."
  nmcli device status || true
  exit 3
fi

# --- Resolve connection name bound to the device ---
CONN_NAME="$(nmcli -t -f NAME,DEVICE connection show --active | awk -F: -v dev="$IFACE" '$2==dev {print $1; exit}')"
if [[ -z "$CONN_NAME" ]]; then
  CONN_NAME="$(nmcli -t -f NAME,DEVICE connection show | awk -F: -v dev="$IFACE" '$2==dev {print $1; exit}')"
fi
if [[ -z "$CONN_NAME" ]]; then
  err "Could not determine the connection profile for device '$IFACE'."
  err "Tip: Create/attach a connection profile to this device first (e.g., 'nmcli con add ...')."
  exit 3
fi
log "Using connection profile: $CONN_NAME (device: $IFACE)"

# --- Backup current profile ---
BACKUP="backup-${CONN_NAME// /_}-$(date +%Y%m%d-%H%M%S).nmconnection"
if ! run "Export backup to $BACKUP" nmcli connection export "$CONN_NAME" "$BACKUP"; then
  exit 4
fi

# --- Apply settings ---
CIDR="${ADDR}/${PREFIX}"
if ! run "Set IPv4 method manual" nmcli -w "$NM_TIMEOUT" connection modify "$CONN_NAME" ipv4.method manual; then
  warn "Attempting rollback..."
  if ! nmcli connection import type file file "$BACKUP" >/dev/null 2>&1; then
    err "Rollback failed. Manual intervention required."
    exit 8
  fi
  exit 5
fi

if ! run "Set IPv4 address to $CIDR" nmcli -w "$NM_TIMEOUT" connection modify "$CONN_NAME" ipv4.addresses "$CIDR"; then
  warn "Attempting rollback..."
  if ! nmcli connection import type file file "$BACKUP" >/dev/null 2>&1; then
    err "Rollback failed. Manual intervention required."
    exit 8
  fi
  exit 5
fi

if ! run "Set IPv4 gateway to $GATEWAY" nmcli -w "$NM_TIMEOUT" connection modify "$CONN_NAME" ipv4.gateway "$GATEWAY"; then
  warn "Attempting rollback..."
  if ! nmcli connection import type file file "$BACKUP" >/dev/null 2>&1; then
    err "Rollback failed. Manual intervention required."
    exit 8
  fi
  exit 5
fi

if [[ -n "$DNS_LIST" ]]; then
  DNS_SPACED="${DNS_LIST//,/ }"
  if ! run "Set DNS to $DNS_SPACED" nmcli -w "$NM_TIMEOUT" connection modify "$CONN_NAME" ipv4.dns "$DNS_SPACED"; then
    warn "Attempting rollback..."
    if ! nmcli connection import type file file "$BACKUP" >/dev/null 2>&1; then
      err "Rollback failed. Manual intervention required."
      exit 8
    fi
    exit 5
  fi
fi

# --- Restart connection (down/up) ---
# NOTE: On remote hosts, this may drop your SSH session.
if ! run "Bring connection down" nmcli -w "$NM_TIMEOUT" connection down "$CONN_NAME"; then
  warn "Down failed; attempting to continue with up..."
fi

if ! run "Bring connection up" nmcli -w "$NM_TIMEOUT" connection up "$CONN_NAME"; then
  warn "Attempting rollback to previous profile..."
  # Try rollback import and activate the old profile name if preserved
  if ! nmcli connection import type file file "$BACKUP" >/dev/null 2>&1; then
    err "Rollback failed. Manual intervention required."
    exit 8
  fi
  # Try to reactivate after import (best-effort)
  nmcli -w "$NM_TIMEOUT" connection up "$CONN_NAME" || true
  exit 6
fi

# --- Verification ---
VERIFIED=0
{
  ip -4 addr show dev "$IFACE" | grep -q "$ADDR/$PREFIX" && VERIFIED=1
} || true

if (( VERIFIED == 0 )); then
  warn "Verification: IP $CIDR not present on $IFACE after restart."
  warn "Routes and nmcli summary will be printed for troubleshooting."
fi

log "IPv4 addresses on $IFACE:"
ip -4 addr show dev "$IFACE" | sed 's/^/    /' || true

log "Default IPv4 routes:"
ip -4 route show default | sed 's/^/    /' || true

log "nmcli connection summary:"
nmcli -f NAME,DEVICE,IP4.METHOD,IP4.ADDRESS,IP4.GATEWAY,IP4.DNS connection show "$CONN_NAME" | sed 's/^/    /' || true

if (( VERIFIED == 0 )); then
  err "Verification failed: expected $CIDR on $IFACE."
  exit 7
fi

log "Success. Backup saved at: $BACKUP"
exit 0
