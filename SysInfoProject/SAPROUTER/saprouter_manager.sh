#!/bin/bash
# saprouter_manager.sh
# Purpose: Manage SAProuter (start, stop, status, restart) with extended options

# Variables
SAPROUTER_BIN="/usr/sap/SR1/saprouter/saprouter"
LOG_DIR="/usr/sap/SR1/saprouter/log"
PID_FILE="/usr/sap/SR1/saprouter/saprouter.pid"
MAX_CONN=10000
CERT="p:CN=hhd-tfsrt01, OU=0000706563, OU=SAProuter, O=SAP, C=DE"

# Defaults
TRACE_LEVEL=3
ENABLE_TRACE=true

# Usage function
usage() {
    echo "Usage: $0 {start|stop|status|restart} [OPTIONS]"
    echo
    echo "Options:"
    echo "  --no-trace            Disable trace level"
    echo "  --trace-level <level> Set custom trace level (default: 3)"
    echo "  --help                Show this help message"
    echo
    echo "Examples:"
    echo "  $0 start              Start SAProuter with default trace level"
    echo "  $0 start --no-trace   Start SAProuter without trace"
    echo "  $0 start --trace-level 2"
    exit 0
}

# Parse command
ACTION="$1"
shift || true

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-trace)
            ENABLE_TRACE=false
            shift
            ;;
        --trace-level)
            TRACE_LEVEL="$2"
            shift 2
            ;;
        --help)
            usage
            ;;
        *)
            echo "Invalid option: $1"
            usage
            ;;
    esac
done

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Functions
start_saprouter() {
    if [[ -f "$PID_FILE" ]] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "SAProuter is already running with PID $(cat $PID_FILE)"
        exit 0
    fi

    CMD="$SAPROUTER_BIN -r -Y 0 -C 1000 -D -J 20000000 -W $MAX_CONN -K \"$CERT\""
    if $ENABLE_TRACE; then
        CMD="$CMD -V $TRACE_LEVEL"
    fi

    echo "Starting SAProuter..."
    nohup bash -c "$CMD" >> "$LOG_DIR/saprouter.log" 2>&1 &
    echo $! > "$PID_FILE"
    echo "SAProuter started with PID $(cat $PID_FILE)"
}

stop_saprouter() {
    if [[ -f "$PID_FILE" ]] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "Stopping SAProuter..."
        kill $(cat "$PID_FILE")
        rm -f "$PID_FILE"
        echo "SAProuter stopped."
    else
        echo "SAProuter is not running."
    fi
}

status_saprouter() {
    if [[ -f "$PID_FILE" ]] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "SAProuter is running with PID $(cat $PID_FILE)"
    else
        echo "SAProuter is not running."
    fi
}

restart_saprouter() {
    stop_saprouter
    sleep 2
    start_saprouter
}

# Execute action
case "$ACTION" in
    start)
        start_saprouter
        ;;
    stop)
        stop_saprouter
        ;;
    status)
        status_saprouter
        ;;
    restart)
        restart_saprouter
        ;;
    *)
        usage
        ;;
esac
