# Basic Linux Commands

## Command Syntax

```
command [options] [arguments]
```

Example: `ls -l /etc` runs `ls` with the option `-l` on the argument `/etc`.

## Navigation

```bash
pwd                     # Print current directory
ls                      # List files
ls -l                   # Long format (permissions, owner, size, date)
ls -a                   # Include hidden files (names starting with .)
ls -lh                  # Human-readable sizes
ls -lt                  # Sort by modification time
cd /var/log             # Change directory (absolute path)
cd ..                   # Go up one level
cd ~                    # Go to home directory
cd -                    # Go back to previous directory
```

## Creating Files and Directories

```bash
mkdir projects                  # Create a directory
mkdir -p projects/lab/test      # Create nested directories
touch notes.txt                 # Create an empty file / update timestamp
echo "Hello Linux" > hello.txt  # Write text to a file (overwrites)
echo "Another line" >> hello.txt # Append text to a file
```

## Copying, Moving and Deleting

```bash
cp notes.txt backup.txt         # Copy a file
cp -r projects projects-copy    # Copy a directory recursively
mv backup.txt archive.txt       # Rename a file
mv archive.txt ~/projects/      # Move a file
rm archive.txt                  # Delete a file
rm -r projects-copy             # Delete a directory and its contents
rm -i file.txt                  # Ask before deleting
rmdir emptydir                  # Delete an empty directory
```

> **Warning:** `rm` has no recycle bin. Deleted files are gone. Never run `rm -rf /` or `rm -rf` on a path you have not double-checked.

## Viewing File Contents

```bash
cat hello.txt           # Print entire file
less /var/log/syslog    # Scroll through a file (q to quit)
head -n 5 hello.txt     # First 5 lines
tail -n 5 hello.txt     # Last 5 lines
tail -f /var/log/syslog # Follow a file as it grows
wc -l hello.txt         # Count lines (-w words, -c bytes)
```

## Searching

```bash
grep "error" /var/log/syslog        # Lines containing "error"
grep -i "error" file.txt            # Case-insensitive
grep -r "TODO" ~/projects           # Search recursively
grep -n "root" /etc/passwd          # Show line numbers
find / -name "hello.txt" 2>/dev/null # Find a file by name
find ~ -type f -mtime -1            # Files modified in the last day
```

## Pipes and Redirection

| Symbol | Meaning |
|---|---|
| `>` | Redirect output to a file (overwrite) |
| `>>` | Redirect output to a file (append) |
| `<` | Take input from a file |
| `2>` | Redirect errors |
| `\|` | Send output of one command to another |

```bash
ls -l /etc | less
cat /etc/passwd | grep bash | wc -l
ls /nonexistent 2> errors.txt
ps aux | grep ssh
history | tail -n 10
```

## Getting Help

```bash
man ls              # Manual page (q to quit)
ls --help           # Quick option summary
whatis ls           # One-line description
apropos "copy file" # Search manuals by keyword
type cd             # Is it a builtin, alias or program?
```

## System Information

```bash
whoami              # Current user
id                  # UID, GID and groups
hostname            # System name
date                # Current date and time
cal                 # Calendar
uptime              # Uptime and load average
df -h               # Disk space
free -h             # Memory usage
uname -a            # Kernel info
```

## Working with sudo

```bash
sudo apt update             # Run a command as root
sudo -i                     # Open a root shell
sudo !!                     # Re-run the previous command with sudo
```

## Useful Shortcuts

| Shortcut | Action |
|---|---|
| `Tab` | Autocomplete commands and paths |
| `↑` / `↓` | Browse command history |
| `Ctrl + C` | Stop the running command |
| `Ctrl + L` | Clear the screen |
| `Ctrl + R` | Search command history |
| `Ctrl + A` / `Ctrl + E` | Jump to start / end of line |
| `Ctrl + D` | Log out / end input |

## Practice

1. Create a folder `lab-practice` with subfolders `docs` and `scripts`.
2. Create three files inside `docs` and write a line of text into each.
3. Copy `docs` to `docs-backup`, then rename one file inside it.
4. Use `grep` to find a word across all files in `docs`.
5. Run `ls -l /etc | wc -l` and explain what it does.
6. Delete `lab-practice` when finished.

## Notes

- Add your own output and observations here.
- Screenshot: `../screenshots/basic-commands.png`
