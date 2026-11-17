# Linux Administration Lab

Hands-on notes, commands and scripts from my Linux system administration practice. Each topic has its own folder with short notes and real commands I ran in a lab environment.

## Lab Environment

| Item | Details |
|---|---|
| Distribution | Ubuntu 24.04 LTS *(update with yours)* |
| Platform | VirtualBox / VMware / WSL / Cloud VM *(update with yours)* |
| Shell | Bash |
| Access | Terminal / SSH |

## Repository Structure

```
linux-administration-lab/
├── README.md
├── basics/                 # Intro, file system, essential commands
├── permissions/            # chmod, chown, permission model
├── users-groups/           # User and group management
├── networking/             # ip commands, network configuration
├── bash-scripting/         # Automation scripts
├── process-management/     # Monitoring and controlling processes
└── screenshots/            # Terminal output as proof of work
```

## Topics Covered

| Folder | What's inside |
|---|---|
| [basics](basics/) | What Linux is, the directory hierarchy, everyday commands |
| [permissions](permissions/) | Read/write/execute, `chmod`, `chown`, special bits |
| [users-groups](users-groups/) | Creating, modifying and deleting users and groups |
| [networking](networking/) | Inspecting interfaces and routes, configuring networks |
| [bash-scripting](bash-scripting/) | `hello.sh`, `system-info.sh`, `backup-demo.sh` |
| [process-management](process-management/) | `ps`, `top`, `kill`, `systemctl` and more |
| [screenshots](screenshots/) | Evidence of commands executed in the lab |

## Getting Started

```bash
# Clone the repository
git clone https://github.com/sorifbiswas/linux-administration-lab.git
cd linux-administration-lab

# Make the scripts executable
chmod +x bash-scripting/*.sh

# Try one
./bash-scripting/hello.sh
```

## Skills Demonstrated

- Navigating and understanding the Linux file system
- Managing file permissions and ownership
- Creating and administering users and groups
- Inspecting and configuring network settings
- Monitoring and controlling processes and services
- Writing Bash scripts to automate routine tasks

## Notes

- Commands that modify the system use `sudo`. Run them only in a lab or test machine.
- Screenshots in `screenshots/` are named after the topic they belong to.

## License

This project is for learning purposes. Feel free to use and adapt it.
