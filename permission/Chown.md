# chown: Change File Ownership

## Overview

`chown` (change owner) changes the user and/or group that owns a file or directory. Changing the owner requires root privileges (`sudo`). The owner of a file can change its group only to a group they belong to; for any other change, use `sudo`.

```
chown [options] [owner][:group] file...
```

## Syntax Forms

| Command | Effect |
|---|---|
| `chown alice file` | Change owner to `alice` |
| `chown alice:devs file` | Change owner to `alice` and group to `devs` |
| `chown :devs file` | Change only the group to `devs` |
| `chown alice: file` | Change owner to `alice` and group to alice's login group |
| `chown --reference=ref file` | Copy owner and group from another file |

`chgrp` is a related command that changes only the group:

```bash
chgrp devs file.txt
```

## Basic Examples

```bash
# Check current ownership
ls -l report.txt
# -rw-r--r-- 1 root root 120 Nov 17 10:00 report.txt

# Change the owner
sudo chown alice report.txt

# Change owner and group
sudo chown alice:devs report.txt

# Change only the group
sudo chown :devs report.txt

# Verify
ls -l report.txt
# -rw-r--r-- 1 alice devs 120 Nov 17 10:00 report.txt
```

## Useful Options

| Option | Purpose |
|---|---|
| `-R` | Recursive: apply to a directory and everything inside |
| `-v` | Verbose: show each file processed |
| `-c` | Report only when a change is made |
| `-h` | Change a symbolic link itself, not its target |
| `--from=CURRENT` | Change only if the current owner matches |
| `--reference=FILE` | Use another file's ownership |

```bash
sudo chown -R alice:devs /srv/project
sudo chown -v bob notes.txt
sudo chown --from=alice bob file.txt    # Only changes if alice owns it
sudo chown --reference=template.conf new.conf
```

## Example: Shared Project Directory

```bash
# Create a group and add users
sudo groupadd devs
sudo usermod -aG devs alice
sudo usermod -aG devs bob

# Create the directory
sudo mkdir /srv/project

# Set ownership and permissions
sudo chown -R alice:devs /srv/project
sudo chmod -R 2775 /srv/project     # setgid keeps the group on new files

ls -ld /srv/project
# drwxrwsr-x 2 alice devs 4096 Nov 17 10:15 /srv/project
```

## Example: Fixing Web Server Files

```bash
sudo chown -R www-data:www-data /var/www/html
sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;
```

## Example: Fixing Files Created as Root

If you ran a command with `sudo` and ended up with root-owned files in your home directory:

```bash
sudo chown -R $USER:$USER ~/project
```

## Checking Ownership

```bash
ls -l file.txt
ls -ld directory/
stat file.txt
stat -c '%U:%G %a %n' file.txt      # Owner:group, octal mode, name
find /home -user alice              # Files owned by alice
find /home -group devs              # Files owned by group devs
find / -nouser 2>/dev/null          # Files with no valid owner
```

## chown vs chmod

| | `chown` | `chmod` |
|---|---|---|
| Changes | Who owns the file | What the owner, group and others may do |
| Needs sudo | Usually yes | Only if you do not own the file |
| Affects | User and group | Permission bits |

## Common Errors

| Error | Cause | Fix |
|---|---|---|
| `Operation not permitted` | Not root | Run with `sudo` |
| `invalid user: 'alice'` | User does not exist | Check with `getent passwd alice` |
| `invalid group: 'devs'` | Group does not exist | Create it with `groupadd` or check `getent group` |

## Cautions

- Be careful with `-R` on system paths. Running `sudo chown -R user /` or on `/etc`, `/usr` or `/var` can break the system.
- Double-check the path before pressing Enter.
- Use `-v` or run `ls -l` first to confirm what will change.

## Practice

1. Create a file as your user, then change its owner to another user with `sudo chown`.
2. Change only the group of a file to a group you created.
3. Create a directory, apply `chown -R`, and verify with `ls -lR`.
4. Use `find` to list all files owned by your user in `/tmp`.
5. Combine `chown` and `chmod` to set up a shared directory where new files inherit the group.

## Notes

- Add your own output and observations here.
- Screenshot: `../screenshots/chown.png`
- Related: [linux-permissions](linux-permissions.md), [chmod](chmod.md), [group-management](../users-groups/group-management.md)
