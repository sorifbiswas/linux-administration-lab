# Linux Introduction

## What is Linux?

Linux is a free, open-source, Unix-like operating system kernel created by Linus Torvalds in 1991. Combined with GNU tools and other software, it forms complete operating systems called **distributions** (distros). Linux powers most servers, cloud infrastructure, Android devices, and supercomputers.

## Key Concepts

| Term | Meaning |
|---|---|
| **Kernel** | The core of the OS. Manages hardware, memory, processes and devices |
| **Shell** | Command-line interface that lets you talk to the kernel (e.g. Bash, Zsh) |
| **Distribution** | Kernel + tools + package manager, packaged together (Ubuntu, Debian, RHEL, Fedora) |
| **Package manager** | Tool for installing and updating software (`apt`, `dnf`, `yum`) |
| **Root** | The superuser account with full system privileges |
| **Terminal** | The program that gives you access to the shell |

## Why Linux for Administration?

- Open source and free to use
- Stable, secure and highly configurable
- Dominant in servers, cloud (AWS, Azure, GCP) and containers
- Powerful command line for automation
- Large community and documentation

## Popular Distributions

| Family | Examples | Package manager |
|---|---|---|
| Debian | Debian, Ubuntu, Linux Mint | `apt` |
| Red Hat | RHEL, CentOS Stream, Rocky, AlmaLinux, Fedora | `dnf` / `yum` |
| Arch | Arch Linux, Manjaro | `pacman` |
| SUSE | openSUSE, SLES | `zypper` |

## Linux Architecture

```
+-----------------------------+
|        User / Apps          |
+-----------------------------+
|     Shell (Bash, Zsh)       |
+-----------------------------+
|   System libraries (glibc)  |
+-----------------------------+
|        Linux Kernel         |
+-----------------------------+
|          Hardware           |
+-----------------------------+
```

## Commands

Check the system you are working on:

```bash
uname -a                # Kernel and system info
uname -r                # Kernel version only
cat /etc/os-release     # Distribution name and version
hostnamectl             # Hostname, OS, kernel, architecture
uptime                  # How long the system has been running
whoami                  # Current user
echo $SHELL             # Current shell
lscpu                   # CPU details
free -h                 # Memory usage
```

## Practice

1. Identify your distribution and version using `cat /etc/os-release`.
2. Find your kernel version with `uname -r`.
3. Check how long your system has been up with `uptime`.
4. Open the manual for a command: `man uname`.

## Notes

- Add your own output and observations here.
- Screenshot: `../screenshots/linux-intro.png`
