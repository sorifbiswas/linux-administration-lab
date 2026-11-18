# User Management

## Overview

Every person or service that uses a Linux system does so through a **user account**. Each user has a unique **UID**, a primary **group**, a home directory and a login shell.

## Types of Users

| Type | UID range | Description |
|---|---|---|
| Root | 0 | Superuser with full access |
| System users | 1-999 | Run services (e.g. `www-data`, `sshd`). Usually no login |
| Regular users | 1000+ | Normal human accounts |

## Important Files

| File | Purpose |
|---|---|
| `/etc/passwd` | User account info (name, UID, GID, home, shell) |
| `/etc/shadow` | Encrypted passwords and password aging (root only) |
| `/etc/group` | Group definitions and members |
| `/etc/sudoers` | Who may use `sudo` (edit with `visudo`) |
| `/etc/skel/` | Template files copied to new home directories |
| `/etc/login.defs` | Defaults for new accounts (UID ranges, password aging) |

### `/etc/passwd` format

```
alice:x:1001:1001:Alice Smith:/home/alice:/bin/bash
│     │ │    │    │           │           └─ Login shell
│     │ │    │    │           └─ Home directory
│     │ │    │    └─ Comment (full name)
│     │ │    └─ Primary GID
│     │ └─ UID
│     └─ Password placeholder (real hash is in /etc/shadow)
└─ Username
```

## Creating Users

```bash
# Basic: create user with home directory and bash shell
sudo useradd -m -s /bin/bash alice

# With a comment, specific UID and extra groups
sudo useradd -m -s /bin/bash -c "Alice Smith" -u 1500 -G sudo,devs alice

# Set the password
sudo passwd alice

# Ubuntu/Debian friendly interactive tool
sudo adduser bob
```

| `useradd` option | Purpose |
|---|---|
| `-m` | Create the home directory |
| `-s` | Set login shell |
| `-c` | Comment / full name |
| `-u` | Specify UID |
| `-g` | Primary group |
| `-G` | Supplementary groups (comma-separated) |
| `-d` | Custom home directory |
| `-e` | Account expiry date (`YYYY-MM-DD`) |

> `useradd` is the low-level tool and does not create a home directory unless you pass `-m`. `adduser` (Debian/Ubuntu) is a friendlier wrapper that asks questions and sets everything up.

## Modifying Users

```bash
# Add to a supplementary group (-a is essential, otherwise existing groups are replaced)
sudo usermod -aG devs alice

# Change login shell
sudo usermod -s /bin/zsh alice

# Change home directory and move its contents
sudo usermod -d /home/newalice -m alice

# Rename the user
sudo usermod -l alicia alice

# Lock and unlock an account
sudo usermod -L alice
sudo usermod -U alice

# Set an expiry date
sudo usermod -e 2027-01-31 alice
```

## Passwords and Aging

```bash
sudo passwd alice               # Set or change password
sudo passwd -l alice            # Lock password
sudo passwd -u alice            # Unlock password
sudo passwd -e alice            # Force change at next login
sudo chage -l alice             # Show aging info
sudo chage -M 90 alice          # Max password age: 90 days
sudo chage -m 7 alice           # Min days between changes
sudo chage -W 14 alice          # Warn 14 days before expiry
```

## Deleting Users

```bash
sudo userdel alice              # Delete user, keep home directory
sudo userdel -r alice           # Delete user and home directory
sudo deluser --remove-home bob  # Debian/Ubuntu equivalent
```

> Check for running processes first: `ps -u alice`. Deleting an account while it is logged in can fail.

## Viewing User Information

```bash
whoami                          # Current user
id                              # UID, GID and groups of current user
id alice                        # Info for a specific user
groups alice                    # Groups a user belongs to
getent passwd alice             # Look up the passwd entry
cat /etc/passwd                 # All accounts
cut -d: -f1 /etc/passwd         # Usernames only
awk -F: '$3 >= 1000 {print $1}' /etc/passwd   # Regular users
who                             # Who is logged in
w                               # Who is logged in and what they run
last                            # Login history
lastlog                         # Last login of every user
```

## Switching Users and Privileges

```bash
su - alice                      # Switch to alice (with her environment)
sudo -u alice command           # Run one command as alice
sudo -i                         # Root shell
sudo visudo                     # Safely edit /etc/sudoers
```

Grant sudo access by adding the user to the admin group:

```bash
sudo usermod -aG sudo alice     # Debian/Ubuntu
sudo usermod -aG wheel alice    # RHEL/Fedora
```

## Example: Onboard a New User

```bash
sudo useradd -m -s /bin/bash -c "Bob Jones" bob
sudo passwd bob
sudo usermod -aG devs bob
sudo chage -d 0 bob             # Force password change at first login
id bob
ls -la /home/bob
```

## Example: Offboard a User

```bash
sudo usermod -L bob             # Lock the account first
sudo pkill -u bob               # End their processes
sudo tar -czf /backup/bob-home.tar.gz /home/bob
sudo userdel -r bob
```

## Common Errors

| Error | Cause | Fix |
|---|---|---|
| `user 'alice' already exists` | Name taken | Choose another or modify the existing user |
| `user alice is currently used by process` | User is logged in | Log them out or `pkill -u alice` |
| User cannot log in | Locked account, bad shell or no home | Check `passwd -S alice`, `/etc/passwd` and the home directory |
| Group membership not applied | Session started before the change | Log out and back in, or run `newgrp` |

## Practice

1. Create a user `labuser` with a home directory and bash shell.
2. Set a password and switch to the user with `su - labuser`.
3. Add `labuser` to a supplementary group and verify with `id`.
4. Lock the account, try to log in, then unlock it.
5. Set the password to expire in 90 days using `chage`.
6. Delete the user and their home directory.

## Notes

- Add your own output and observations here.
- Screenshot: `../screenshots/user-management.png`
- Related: [group-management](group-management.md), [chown](../permissions/chown.md)
