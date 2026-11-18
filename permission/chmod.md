# chmod: Change File Permissions

## Overview

`chmod` (change mode) sets the read, write and execute permissions of files and directories. Only the file's owner or root can change its permissions.

```
chmod [options] mode file...
```

## Two Ways to Set Permissions

### 1. Symbolic Mode

Format: `[who][operator][permissions]`

| Who | Meaning |
|---|---|
| `u` | User (owner) |
| `g` | Group |
| `o` | Others |
| `a` | All (u + g + o) |

| Operator | Meaning |
|---|---|
| `+` | Add a permission |
| `-` | Remove a permission |
| `=` | Set exactly, replacing existing |

| Permission | Meaning |
|---|---|
| `r` | Read |
| `w` | Write |
| `x` | Execute |

```bash
chmod u+x script.sh         # Give the owner execute
chmod g+w file.txt          # Give the group write
chmod o-r file.txt          # Remove read from others
chmod a+r file.txt          # Everyone can read
chmod u=rwx,g=rx,o=r file   # Set all three at once
chmod go-rwx secret.txt     # Remove all access for group and others
chmod +x script.sh          # Add execute for everyone
```

### 2. Numeric (Octal) Mode

Each digit is the sum of `r=4`, `w=2`, `x=1`, in the order user, group, others.

```bash
chmod 755 script.sh     # rwxr-xr-x
chmod 644 file.txt      # rw-r--r--
chmod 700 private/      # rwx------
chmod 600 id_rsa        # rw-------
chmod 400 readonly.txt  # r--------
```

| Mode | Symbolic | Use case |
|---|---|---|
| `755` | `rwxr-xr-x` | Scripts, programs, shared directories |
| `644` | `rw-r--r--` | Regular files |
| `700` | `rwx------` | Private directories |
| `600` | `rw-------` | Private files, SSH keys |
| `664` | `rw-rw-r--` | Group-shared files |
| `775` | `rwxrwxr-x` | Group-shared directories |
| `777` | `rwxrwxrwx` | Avoid: anyone can modify |

## Useful Options

| Option | Purpose |
|---|---|
| `-R` | Apply recursively to a directory and its contents |
| `-v` | Verbose: show every file changed |
| `-c` | Like verbose, but only report actual changes |
| `--reference=FILE` | Copy permissions from another file |

```bash
chmod -R 755 project/
chmod -v 644 notes.txt
chmod --reference=template.sh newscript.sh
```

## Recursive Permissions on Mixed Content

`chmod -R 755` makes every regular file executable too. A cleaner approach is to set files and directories separately:

```bash
find project/ -type d -exec chmod 755 {} \;
find project/ -type f -exec chmod 644 {} \;
```

Or use the capital `X`, which adds execute only to directories (and files that already have execute):

```bash
chmod -R u=rwX,g=rX,o=rX project/
```

## Special Permissions

```bash
chmod u+s program           # setuid
chmod g+s shared-dir/       # setgid
chmod +t shared-dir/        # sticky bit

chmod 4755 program          # setuid + 755
chmod 2775 shared-dir/      # setgid + 775
chmod 1777 /tmp-like-dir    # sticky + 777
```

## Example: Making a Script Executable

```bash
echo '#!/bin/bash' > hello.sh
echo 'echo "Hello, Linux!"' >> hello.sh

ls -l hello.sh          # -rw-r--r--  (not executable)
./hello.sh              # bash: ./hello.sh: Permission denied

chmod u+x hello.sh
ls -l hello.sh          # -rwxr--r--
./hello.sh              # Hello, Linux!
```

## Example: Protecting an SSH Key

SSH refuses to use private keys that other users can read.

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

## Common Errors

| Error | Cause | Fix |
|---|---|---|
| `Operation not permitted` | You are not the owner | Use `sudo` or ask the owner |
| `Permission denied` when running a script | Missing execute bit | `chmod +x script.sh` |
| `invalid mode` | Typo in the mode string | Check the syntax, e.g. `u+x` not `u+X+` |

## Practice

1. Create `test.sh` and make it executable for yourself only.
2. Convert `rwxr-x---` to octal, then apply it with `chmod`.
3. Create a directory `shared/`, give the group write access and set the setgid bit.
4. Remove all permissions from a file, then try to read it and note the error.
5. Use `find` with `chmod` to set directories to `755` and files to `644` in a folder.

## Notes

- Add your own output and observations here.
- Screenshot: `../screenshots/chmod.png`
- Related: [linux-permissions](linux-permissions.md), [chown](chown.md)
