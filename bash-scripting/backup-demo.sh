#!/usr/bin/env bash
#
# backup-demo.sh - Creates a timestamped, compressed backup of a directory,
#                  verifies it, and removes old backups (retention).
#
# Usage:
#   ./backup-demo.sh <source_dir> [-d backup_dir] [-k keep] [-n]
#
# Options:
#   -d DIR   where to store backups        (default: $HOME/backups)
#   -k NUM   number of backups to keep     (default: 5)
#   -n       dry run: show what would happen, create/delete no backups
#   -h       show this help
#
# Examples:
#   ./backup-demo.sh ~/documents
#   ./backup-demo.sh /etc -d /tmp/etc-backups -k 3
#   ./backup-demo.sh ~/documents -n
#
# Restore a backup:
#   tar -xzf ~/backups/documents_20261118_101500.tar.gz -C /restore/path
#
# Automate with cron (daily at 02:00):
#   0 2 * * * /path/to/backup-demo.sh /home/alice/documents >> /var/log/backup.log 2>&1
#
# Make executable first:  chmod +x backup-demo.sh

set -euo pipefail

# ---------- Defaults ----------
BACKUP_DIR="${HOME}/backups"
KEEP=5
DRY_RUN=false

# ---------- Helpers ----------
usage() {
    sed -n '3,19p' "$0" | sed 's/^# \{0,1\}//'
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

die() {
    echo "Error: $*" >&2
    exit 1
}

# ---------- Parse arguments ----------
if [ $# -lt 1 ]; then
    usage
    exit 1
fi

case "$1" in
    -h|--help) usage; exit 0 ;;
esac

SOURCE="$1"
shift

while getopts ":d:k:nh" opt; do
    case "$opt" in
        d) BACKUP_DIR="$OPTARG" ;;
        k) KEEP="$OPTARG" ;;
        n) DRY_RUN=true ;;
        h) usage; exit 0 ;;
        :) die "Option -$OPTARG needs an argument." ;;
        \?) die "Unknown option: -$OPTARG" ;;
    esac
done

# ---------- Validate ----------
[ -d "$SOURCE" ] || die "Source directory not found: $SOURCE"
[ -r "$SOURCE" ] || die "Source directory is not readable: $SOURCE"
[[ "$KEEP" =~ ^[1-9][0-9]*$ ]] || die "-k must be a positive number."

# Resolve to an absolute path and get the folder name
SOURCE="$(cd "$SOURCE" && pwd)"
NAME="$(basename "$SOURCE")"
[ "$SOURCE" = "/" ] && NAME="root"

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
ARCHIVE="${BACKUP_DIR}/${NAME}_${TIMESTAMP}.tar.gz"

# ---------- Safety: backup dir must not be inside the source ----------
mkdir -p "$BACKUP_DIR"
BACKUP_ABS="$(cd "$BACKUP_DIR" && pwd)"
case "$BACKUP_ABS/" in
    "$SOURCE"/*) die "Backup directory cannot be inside the source directory." ;;
esac

# ---------- Check free space ----------
need_kb=$(du -sk "$SOURCE" 2>/dev/null | cut -f1)
free_kb=$(df -Pk "$BACKUP_ABS" | awk 'NR==2 {print $4}')
if [ "$free_kb" -lt "$need_kb" ]; then
    die "Not enough free space in $BACKUP_ABS (need ~${need_kb} KB, have ${free_kb} KB)."
fi

# ---------- Backup ----------
log "Source      : $SOURCE"
log "Destination : $ARCHIVE"
log "Retention   : keep last $KEEP backups"

if $DRY_RUN; then
    log "DRY RUN: no files will be created or deleted."
else
    tar -czf "$ARCHIVE" -C "$(dirname "$SOURCE")" "$NAME"
    log "Archive created ($(du -h "$ARCHIVE" | cut -f1))."

    # Verify the archive can be read
    if tar -tzf "$ARCHIVE" >/dev/null 2>&1; then
        log "Verification passed."
    else
        rm -f "$ARCHIVE"
        die "Verification failed. Archive removed."
    fi
fi

# ---------- Retention: remove the oldest backups ----------
mapfile -t backups < <(ls -1t "$BACKUP_ABS"/"${NAME}"_*.tar.gz 2>/dev/null || true)
total=${#backups[@]}

if [ "$total" -gt "$KEEP" ]; then
    log "Found $total backups, removing $((total - KEEP)) old one(s)."
    for old in "${backups[@]:$KEEP}"; do
        if $DRY_RUN; then
            log "Would delete: $old"
        else
            rm -f -- "$old"
            log "Deleted: $old"
        fi
    done
else
    log "Found $total backup(s), nothing to clean up."
fi

log "Done."
exit 0
