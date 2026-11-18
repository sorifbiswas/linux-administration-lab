# Group Management

## Overview

A **group** is a collection of users that share the same access rights. Groups make it easy to give several people access to the same files or resources without setting permissions user by user.

## Types of Groups

| Type | Description |
|---|---|
| **Primary group** | The group assigned to a user in `/etc/passwd`. New files the user creates belong to this group |
| **Supplementary (secondary) groups** | Additional groups a user belongs to, used for extra access |
| **System groups** | Used by services and the OS (e.g. `adm`, `www-data`, `docker`) |

A user has exactly one primary group but can belong to many supplementary groups.

## Important Files

| File | Purpose |
|---|---|
| `/etc/group` | Group names, GIDs and members |
| `/etc/gshadow` | Group passwords and administrators (root only) |
| `/etc/passwd` | Contains each user's primary GID |

### `/etc/group` format

```
devs:x:1002:alice,bob
│    │ │    └─ Members (comma-separated)
│    │ └─ GID
│    └─ Password placeholder
└─ Group name
```

## Creating Groups

```bash
sudo groupadd devs                  # Create a group
sudo groupadd -g 2000 qa            # Create with a specific GID
sudo groupadd -r svcgroup           # Create a system group
sudo addgroup testers               # Debian/Ubuntu friendly version
```

## Adding Users to Groups

```bash
# Add to a supplementary group (-a is essential)
sudo usermod -aG devs alice

# Add to several groups at once
sudo usermod -aG devs,qa,docker alice

# Change the primary group
sudo usermod -g devs alice

# Debian/Ubuntu alternatives
sudo adduser alice devs
sudo gpasswd -a alice devs
```

> **Important:** `usermod -G devs alice` without `-a` **replaces** all of alice's supplementary groups. Always use `-aG` to append.

## Removing Users from Groups

```bash
sudo gpasswd -d alice devs          # Remove alice from devs
sudo deluser alice devs             # Debian/Ubuntu equivalent
```

## Modifying and Deleting Groups

```bash
sudo groupmod -n developers devs    # Rename a group
sudo groupmod -g 2500 developers    # Change GID
sudo groupdel developers            # Delete a group
```

> A group cannot be deleted while it is the primary group of an existing user. Change or remove those users first.

## Viewing Group Information

```bash
groups                      # Groups of the current user
groups alice                # Groups of a specific user
id alice                    # UID, GID and all groups
getent group devs           # Details for one group
cat /etc/group              # All groups
cut -d: -f1 /etc/group      # Group names only
members devs                # List members (sudo apt install members)
lid -g devs                 # Alternative (libuser package)
```

## Group Administrators

A group administrator can add and remove members without being root.

```bash
sudo gpasswd -A alice devs          # Make alice an administrator of devs
gpasswd -a bob devs                 # alice can now add bob
sudo gpasswd -M alice,bob,carol devs  # Set the full member list
```

## Switching Groups in a Session

```bash
newgrp devs                 # Start a shell with devs as the active group
id                          # Verify
exit                        # Return to the previous group
```

Group membership changes take effect at the next login. Use `newgrp` or log out and back in to apply them.

## Example: Shared Project Directory

```bash
# Create the group and add members
sudo groupadd devs
sudo usermod -aG devs alice
sudo usermod -aG devs bob

# Create the shared directory
sudo mkdir /srv/project
sudo chown root:devs /srv/project
sudo chmod 2770 /srv/project        # setgid + rwx for owner and group

# Verify
ls -ld /srv/project                 # drwxrws--- 2 root devs ...
```

With the setgid bit (`2` in `2770`), every new file created inside inherits the `devs` group. Users outside the group have no access.

## Example: Giving Docker Access Without sudo

```bash
sudo usermod -aG docker alice
# Alice logs out and back in, then:
docker ps
```

## Common System Groups

| Group | Purpose |
|---|---|
| `sudo` / `wheel` | Allowed to use `sudo` |
| `adm` | Read system log files |
| `www-data` | Web server processes (Debian/Ubuntu) |
| `docker` | Run Docker without `sudo` |
| `dialout` | Access serial ports |
| `cdrom`, `audio`, `video` | Access to hardware devices |

## Common Errors

| Error | Cause | Fix |
|---|---|---|
| `group 'devs' already exists` | Name in use | Pick another name or reuse the group |
| `group 'devs' does not exist` | Typo or not created | Check `getent group devs`, then `groupadd` |
| `cannot remove user's primary group` | Group is still a primary group | Change that user's primary group first |
| New group access not working | Old session | Log out and in, or use `newgrp` |

## Practice

1. Create groups `devs` and `qa`.
2. Create two users and add them to `devs`. Add one of them to `qa` as well.
3. Verify memberships with `id` and `getent group`.
4. Create a shared directory for `devs` with the setgid bit, then create a file in it as each user and check the group.
5. Remove a user from `devs` and confirm they lose access.
6. Rename `qa` to `testers`, then delete it.

## Notes

- Add your own output and observations here.
- Screenshot: `../screenshots/group-management.png`
- Related: [user-management](user-management.md), [chown](../permissions/chown.md), [chmod](../permissions/chmod.md)
