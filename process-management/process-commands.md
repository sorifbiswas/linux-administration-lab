# Process Management

## Overview

A **process** is a running instance of a program. Every process has a unique **PID** (process ID), a **PPID** (parent process ID), an owner, a state and resource usage. The first process started by the kernel is PID 1 (`systemd` or `init`), and every other process descends from it.

## Process States

| Code | State | Meaning |
|---|---|---|
| `R` | Running | Executing or ready to run |
| `S` | Sleeping | Waiting for an event (interruptible) |
| `D` | Uninterruptible sleep | Waiting on I/O, cannot be killed |
| `T` | Stopped | Paused (e.g. `Ctrl+Z`) |
| `Z` | Zombie | Finished, but parent has not collected its exit status |

## Foreground and Background

| Type | Description |
|---|---|
| Foreground | Occupies the terminal until it finishes |
| Background | Runs while you keep using the terminal |
| Daemon | Background service with no terminal (e.g. `sshd`) |

## Viewing Processes

```bash
ps                              # Processes in the current shell
ps aux                          # All processes (BSD style)
ps -ef                          # All processes (full format)
ps -u alice                     # Processes of one user
ps -p 1234                      # One process by PID
ps -ef --forest                 # Process tree
ps -eo pid,ppid,user,%cpu,%mem,stat,comm   # Custom columns
ps aux --sort=-%mem | head -10  # Top 10 memory users
ps aux --sort=-%cpu | head -10  # Top 10 CPU users

pstree                          # Tree view
pstree -p                       # With PIDs
pgrep sshd                      # PIDs matching a name
pgrep -l -u alice               # Name and PID for a user
pidof sshd                      # PID of a program
```

### `ps aux` columns

| Column | Meaning |
|---|---|
| `USER` | Owner of the process |
| `PID` | Process ID |
| `%CPU` / `%MEM` | CPU and memory share |
| `VSZ` / `RSS` | Virtual / resident memory (KB) |
| `TTY` | Controlling terminal (`?` = none) |
| `STAT` | State code |
| `START` / `TIME` | Start time / CPU time used |
| `COMMAND` | Command line |

## Live Monitoring

```bash
top                             # Interactive monitor
htop                            # Friendlier version (sudo apt install htop)
watch -n 2 'ps aux --sort=-%cpu | head -5'   # Refresh every 2 seconds
uptime                          # Load averages
vmstat 2 5                      # System stats every 2s, 5 times
free -h                         # Memory
```

### `top` keys

| Key | Action |
|---|---|
| `q` | Quit |
| `k` | Kill a process (asks for PID) |
| `r` | Renice a process |
| `M` | Sort by memory |
| `P` | Sort by CPU |
| `u` | Filter by user |
| `1` | Show each CPU core |
| `h` | Help |

### Reading load average

`uptime` shows three numbers: the 1, 5 and 15-minute load averages. As a rule of thumb, a load consistently above the number of CPU cores (`nproc`) means the system is overloaded.

## Controlling Jobs

```bash
sleep 300 &                     # Start in the background
jobs                            # List jobs in this shell
fg %1                           # Bring job 1 to the foreground
bg %1                           # Resume job 1 in the background
# Ctrl+Z                        # Pause the foreground process
# Ctrl+C                        # Terminate the foreground process

nohup ./long-task.sh &          # Keep running after logout
nohup ./long-task.sh > out.log 2>&1 &
disown %1                       # Detach a job from the shell
```

## Signals and Killing Processes

```bash
kill 1234                       # Send SIGTERM (polite stop)
kill -9 1234                    # Send SIGKILL (force stop)
kill -HUP 1234                  # Reload configuration
kill -STOP 1234                 # Pause
kill -CONT 1234                 # Resume
kill -l                         # List all signals

pkill firefox                   # Kill by name
pkill -u alice                  # Kill all of a user's processes
killall nginx                   # Kill all processes with this name
```

| Signal | Number | Meaning |
|---|---|---|
| `SIGHUP` | 1 | Hang up, often means reload config |
| `SIGINT` | 2 | Interrupt (`Ctrl+C`) |
| `SIGKILL` | 9 | Force kill, cannot be caught or ignored |
| `SIGTERM` | 15 | Graceful terminate (default) |
| `SIGSTOP` | 19 | Pause, cannot be caught |
| `SIGCONT` | 18 | Resume a stopped process |

> **Always try `kill` (SIGTERM) first.** It lets the program save data and clean up. Use `kill -9` only when a process ignores SIGTERM, since it gives no chance to clean up. Check the PID twice before killing anything.

## Priority (nice)

Niceness ranges from `-20` (highest priority) to `19` (lowest). The default is `0`. Only root can lower niceness.

```bash
nice -n 10 ./heavy-task.sh      # Start with lower priority
sudo nice -n -5 ./important.sh  # Start with higher priority
renice 15 -p 1234               # Change a running process
sudo renice -5 -p 1234
ps -eo pid,ni,comm | head       # View niceness
```

## Services with systemd

Most long-running processes are managed as services.

```bash
systemctl status ssh                # State of a service
sudo systemctl start ssh
sudo systemctl stop ssh
sudo systemctl restart ssh
sudo systemctl reload ssh           # Reload config without restart
sudo systemctl enable ssh           # Start at boot
sudo systemctl disable ssh
sudo systemctl enable --now ssh     # Enable and start at once

systemctl list-units --type=service --state=running
systemctl list-unit-files --state=enabled
systemctl --failed                  # Services that failed
journalctl -u ssh                   # Logs for one service
journalctl -u ssh -f                # Follow logs live
journalctl -u ssh --since "1 hour ago"
```

## Investigating a Process

```bash
ls -l /proc/1234/                   # Process info as files
cat /proc/1234/status
cat /proc/1234/cmdline | tr '\0' ' '
ls -l /proc/1234/exe                # The program being run
ls -l /proc/1234/fd                 # Open files
lsof -p 1234                        # Open files (sudo apt install lsof)
lsof -i :80                         # What is using port 80
ss -tulpn | grep :22                # Which process owns port 22
strace -p 1234                      # Trace system calls (needs root)
```

## Example: Finding and Stopping a Runaway Process

```bash
# 1. Find the culprit
ps aux --sort=-%cpu | head -5

# 2. Inspect it
ps -p 4321 -o pid,ppid,user,%cpu,%mem,etime,cmd

# 3. Ask it to stop politely
kill 4321

# 4. Check whether it is gone
sleep 2
ps -p 4321 || echo "Process stopped."

# 5. Force it only if it ignored SIGTERM
kill -9 4321
```

## Example: Run a Task in the Background

```bash
sleep 600 &                         # Start
echo $!                             # PID of the last background job
jobs -l                             # List with PIDs
kill %1                             # Stop it using the job number
```

## Example: Dealing with Zombie Processes

```bash
ps aux | awk '$8 ~ /^Z/ {print}'    # List zombies
ps -eo pid,ppid,stat,comm | grep ' Z'
```

A zombie is already dead and uses no resources beyond a process table entry, so `kill` does nothing. Fix it by restarting or signalling its **parent** process (the PPID).

## Common Problems

| Problem | Cause | Fix |
|---|---|---|
| `Operation not permitted` on kill | Process belongs to another user | Use `sudo` |
| Process ignores `kill` | Stuck or uninterruptible (`D` state) | `kill -9`, or fix the I/O problem or reboot |
| `No such process` | PID already ended or wrong PID | Re-check with `ps` or `pgrep` |
| Job stops after closing terminal | Tied to the shell session | Use `nohup`, `disown`, `tmux` or `screen` |
| High load but low CPU | Processes blocked on disk or network I/O | Check `vmstat` and `iostat` |

## Practice

1. List all running processes and find the PID of `systemd` (it should be 1).
2. Start `sleep 500 &`, find it with `pgrep`, then stop it with `kill`.
3. Use `top` to identify the process using the most memory. Sort with `M`.
4. Start a process with `nice -n 15`, then verify its niceness with `ps -o pid,ni,comm`.
5. Pause a job with `Ctrl+Z`, then resume it with `bg` and `fg`.
6. Check the status of the `ssh` service and read its last 20 log lines with `journalctl`.
7. Find which process is listening on port 22.

## Notes

- Add your own output and observations here.
- Screenshot: `../screenshots/process-commands.png`
- Related: [basic-commands](../basics/basic-commands.md), [system-info.sh](../bash-scripting/system-info.sh)
