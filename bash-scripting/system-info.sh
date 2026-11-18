#!/usr/bin/env bash
#
# system-info.sh - Prints a summary of the system: OS, CPU, memory,
#                  disk, network, users and top processes.
#
# Usage:
#   ./system-info.sh              -> print the report to the screen
#   ./system-info.sh -o report.txt -> also save the report to a file
#   ./system-info.sh -h           -> show help
#
# Make executable first:  chmod +x system-info.sh

set -u

# ---------- Helpers ----------
usage() {
    echo "Usage: $0 [-o output_file] [-h]"
    echo "  -o FILE   save the report to FILE as well as printing it"
    echo "  -h        show this help"
}

section() {
    echo
    echo "=============== $1 ==============="
}

# Run a command only if it exists, otherwise print a note.
have() { command -v "$1" >/dev/null 2>&1; }

# ---------- Options ----------
outfile=""
while getopts ":o:h" opt; do
    case "$opt" in
        o) outfile="$OPTARG" ;;
        h) usage; exit 0 ;;
        :) echo "Option -$OPTARG needs an argument." >&2; usage >&2; exit 1 ;;
        \?) echo "Unknown option: -$OPTARG" >&2; usage >&2; exit 1 ;;
    esac
done

# ---------- Report ----------
report() {
    echo "System Report - $(date '+%Y-%m-%d %H:%M:%S')"

    section "SYSTEM"
    echo "Hostname : $(hostname)"
    if [ -r /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        echo "OS       : ${PRETTY_NAME:-unknown}"
    fi
    echo "Kernel   : $(uname -r)"
    echo "Arch     : $(uname -m)"
    echo "Uptime   : $(uptime -p 2>/dev/null || uptime)"
    echo "Load avg : $(cut -d' ' -f1-3 /proc/loadavg)"

    section "CPU"
    if have lscpu; then
        lscpu | grep -E '^(Model name|CPU\(s\)|Thread|Core|Socket)'
    else
        grep -m1 'model name' /proc/cpuinfo
        echo "Cores    : $(nproc)"
    fi

    section "MEMORY"
    free -h
    mem_used_pct=$(free | awk '/^Mem:/ {printf "%.0f", $3/$2*100}')
    echo "Memory used: ${mem_used_pct}%"

    section "DISK USAGE"
    df -hT -x tmpfs -x devtmpfs -x squashfs 2>/dev/null || df -h
    root_pct=$(df / | awk 'NR==2 {gsub("%",""); print $5}')
    if [ "${root_pct:-0}" -ge 80 ]; then
        echo "WARNING: root filesystem is ${root_pct}% full!"
    fi

    section "NETWORK"
    if have ip; then
        ip -brief addr
        echo
        echo "Default route:"
        ip route show default
    else
        hostname -I
    fi
    echo
    echo "DNS servers:"
    grep -E '^nameserver' /etc/resolv.conf 2>/dev/null || echo "  (none found)"

    section "LOGGED-IN USERS"
    who || true
    echo
    echo "Current user: $(whoami) (UID $(id -u))"

    section "TOP 5 PROCESSES BY MEMORY"
    ps -eo pid,user,%mem,%cpu,comm --sort=-%mem | head -6

    section "TOP 5 PROCESSES BY CPU"
    ps -eo pid,user,%mem,%cpu,comm --sort=-%cpu | head -6

    section "LISTENING PORTS"
    if have ss; then
        ss -tuln | head -15
    else
        echo "ss not installed."
    fi

    echo
    echo "================ END OF REPORT ================"
}

# ---------- Output ----------
if [ -n "$outfile" ]; then
    report | tee "$outfile"
    echo
    echo "Report saved to: $outfile"
else
    report
fi

exit 0
