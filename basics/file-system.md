# Linux File System

## Overview

Linux uses a single hierarchical directory tree that starts at the root directory `/`. Everything is a file: regular files, directories, devices and even running process information. There are no drive letters like `C:`; additional disks are *mounted* into the tree.

The layout follows the **Filesystem Hierarchy Standard (FHS)**.

## Directory Structure

```
/
├── bin     → Essential user commands (ls, cp, cat)
├── boot    → Kernel and bootloader files
├── dev     → Device files (disks, terminals)
├── etc     → System configuration files
├── home    → Users' personal directories
├── lib     → Shared libraries for /bin and /sbin
├── media   → Mount point for removable media
├── mnt     → Temporary mount point
├── opt     → Optional third-party software
├── proc    → Virtual files: processes and kernel info
├── root    → Home directory of the root user
├── run     → Runtime data since last boot
├── sbin    → System administration binaries
├── srv     → Data served by the system (web, ftp)
├── sys     → Virtual files: devices and kernel
├── tmp     → Temporary files (may be cleared on reboot)
├── usr     → User programs, libraries, documentation
└── var     → Variable data: logs, caches, spools
```

## Important Directories for Admins

| Path | Purpose | Examples |
|---|---|---|
| `/etc` | Configuration | `/etc/passwd`, `/etc/ssh/sshd_config`, `/etc/fstab` |
| `/var/log` | Log files | `syslog`, `auth.log`, `dmesg` |
| `/home` | User data | `/home/alice` |
| `/proc` | Live kernel and process info | `/proc/cpuinfo`, `/proc/meminfo` |
| `/dev` | Hardware devices | `/dev/sda`, `/dev/null` |
| `/tmp` | Scratch space | Temporary downloads and files |
| `/usr/bin` | Most user commands | `python3`, `git`, `vim` |

## Path Types

| Type | Description | Example |
|---|---|---|
| Absolute | Starts from `/` | `/var/log/syslog` |
| Relative | Starts from the current directory | `../docs/notes.md` |
| Home shortcut | `~` means your home directory | `~/projects` |
| Current dir | `.` | `./script.sh` |
| Parent dir | `..` | `cd ..` |

## File Types

The first character of `ls -l` output shows the file type:

| Symbol | Type |
|---|---|
| `-` | Regular file |
| `d` | Directory |
| `l` | Symbolic link |
| `c` | Character device |
| `b` | Block device |
| `s` | Socket |
| `p` | Named pipe |

## Commands

```bash
# Explore the tree
ls /
ls -l /etc
tree -L 1 /              # Install with: sudo apt install tree

# Where am I?
pwd

# Disk usage
df -h                    # Free space per filesystem
du -sh /var/log          # Size of a directory
du -h --max-depth=1 /var # Size of each subdirectory

# Mounted filesystems
mount | column -t
findmnt
lsblk                    # Disks and partitions

# Find files
find /etc -name "*.conf"
find /var/log -type f -size +1M
locate passwd            # Requires: sudo apt install plocate
which bash               # Location of a command
file /bin/ls             # Identify a file's type

# Links
ln -s /var/log/syslog ~/syslog-link   # Symbolic link
ln file1 file1-hard                   # Hard link
ls -li                                # Show inode numbers

# Inspect a file
stat /etc/passwd
```

## Hard Links vs Symbolic Links

| | Hard link | Symbolic (soft) link |
|---|---|---|
| Points to | Same inode (the data) | A path (the name) |
| Works across filesystems | No | Yes |
| Can link directories | No | Yes |
| If original is deleted | Data remains | Link breaks |

## Practice

1. Run `ls -l /` and identify the type of each entry.
2. Use `df -h` and note which filesystem holds `/`.
3. Find the 5 largest directories in `/var`: `sudo du -h /var | sort -rh | head -5`.
4. Create a symbolic link to a file and verify it with `ls -l`.
5. Read `/proc/cpuinfo` and `/proc/meminfo`.

## Notes

- Add your own output and observations here.
- Screenshot: `../screenshots/file-system.png`
