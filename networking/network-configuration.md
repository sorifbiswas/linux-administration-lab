# Network Configuration

## Overview

Settings made with the `ip` command disappear after a reboot. **Persistent** network configuration is stored in files and managed by a network service. Which tool you use depends on the distribution.

| Distribution | Default tool | Config location |
|---|---|---|
| Ubuntu Server 18.04+ | Netplan (with systemd-networkd) | `/etc/netplan/*.yaml` |
| Ubuntu Desktop | Netplan (with NetworkManager) | `/etc/netplan/*.yaml` |
| RHEL / Rocky / AlmaLinux / Fedora | NetworkManager | `/etc/NetworkManager/system-connections/` |
| Debian | ifupdown or systemd-networkd | `/etc/network/interfaces` |

Check which one is running on your system:

```bash
systemctl status NetworkManager
systemctl status systemd-networkd
ls /etc/netplan/
```

## Key Network Files

| File | Purpose |
|---|---|
| `/etc/hostname` | System hostname |
| `/etc/hosts` | Local name-to-IP mappings |
| `/etc/resolv.conf` | DNS servers (often managed automatically) |
| `/etc/nsswitch.conf` | Order of name resolution (files, DNS) |
| `/etc/netplan/*.yaml` | Netplan configuration (Ubuntu) |
| `/etc/network/interfaces` | ifupdown configuration (Debian) |

## Hostname

```bash
hostnamectl                             # Show hostname and system info
sudo hostnamectl set-hostname lab-server
hostname                                # Verify
```

Local name resolution in `/etc/hosts`:

```
127.0.0.1       localhost
127.0.1.1       lab-server
192.168.1.20    fileserver.lab.local fileserver
```

## Netplan (Ubuntu)

Configuration is written in YAML. Indentation uses **spaces only** (no tabs).

### DHCP (automatic IP)

`/etc/netplan/01-netcfg.yaml`

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: true
```

### Static IP

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: false
      addresses:
        - 192.168.1.100/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
```

> On older Ubuntu releases you may see `gateway4: 192.168.1.1`. This is deprecated. Use `routes` instead.

### Applying Netplan Changes

```bash
sudo netplan try        # Apply with automatic rollback if you lose connectivity
sudo netplan apply      # Apply immediately
sudo netplan generate   # Validate and generate backend config
sudo netplan get        # Show the merged configuration
```

> Use `netplan try` when working over SSH. It reverts after 120 seconds unless you confirm, protecting you from locking yourself out.

Netplan files should have restricted permissions:

```bash
sudo chmod 600 /etc/netplan/*.yaml
```

## NetworkManager (nmcli)

`nmcli` is the command-line client for NetworkManager.

### Viewing

```bash
nmcli general status
nmcli device status                 # Interfaces and their state
nmcli connection show               # Saved connection profiles
nmcli connection show "Wired connection 1"
nmcli device show enp0s3            # Details of an interface
```

### Static IP

```bash
sudo nmcli connection modify "Wired connection 1" \
  ipv4.method manual \
  ipv4.addresses 192.168.1.100/24 \
  ipv4.gateway 192.168.1.1 \
  ipv4.dns "8.8.8.8 1.1.1.1"

sudo nmcli connection up "Wired connection 1"
```

### Back to DHCP

```bash
sudo nmcli connection modify "Wired connection 1" \
  ipv4.method auto \
  ipv4.addresses "" ipv4.gateway ""

sudo nmcli connection up "Wired connection 1"
```

### Other Useful nmcli Commands

```bash
sudo nmcli connection add type ethernet ifname enp0s3 con-name lab-static \
  ipv4.method manual ipv4.addresses 10.0.0.10/24 ipv4.gateway 10.0.0.1

sudo nmcli connection delete lab-static
sudo nmcli device disconnect enp0s3
sudo nmcli device connect enp0s3
sudo nmcli networking off && sudo nmcli networking on
nmcli device wifi list                       # Available Wi-Fi networks
nmcli device wifi connect "SSID" password "secret"
nmtui                                        # Text-based menu interface
```

## ifupdown (Debian)

`/etc/network/interfaces`

```
auto lo
iface lo inet loopback

# DHCP
auto enp0s3
iface enp0s3 inet dhcp

# Static alternative
# auto enp0s3
# iface enp0s3 inet static
#     address 192.168.1.100
#     netmask 255.255.255.0
#     gateway 192.168.1.1
#     dns-nameservers 8.8.8.8 1.1.1.1
```

```bash
sudo ifdown enp0s3 && sudo ifup enp0s3
sudo systemctl restart networking
```

## DNS Configuration

```bash
cat /etc/resolv.conf                # Current DNS servers
resolvectl status                   # systemd-resolved view
resolvectl query google.com         # Test resolution
dig google.com                      # Detailed DNS query
dig @8.8.8.8 google.com             # Query a specific server
nslookup google.com
```

On systems using systemd-resolved, `/etc/resolv.conf` is a symlink and should not be edited by hand. Set DNS in Netplan or NetworkManager instead.

## Testing the Configuration

```bash
ip -br addr                         # Address assigned?
ip route show default               # Gateway set?
ping -c 3 192.168.1.1               # Gateway reachable?
ping -c 3 8.8.8.8                   # Internet reachable?
ping -c 3 google.com                # DNS working?
```

## Firewall Basics

```bash
# UFW (Ubuntu)
sudo ufw status
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw enable

# firewalld (RHEL family)
sudo firewall-cmd --state
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
```

> Allow SSH (port 22) before enabling a firewall on a remote machine.

## Example: Switch a Server to a Static IP (Ubuntu)

```bash
# 1. Note the current settings
ip -br addr
ip route show default
ls /etc/netplan/

# 2. Back up the existing file
sudo cp /etc/netplan/01-netcfg.yaml /etc/netplan/01-netcfg.yaml.bak

# 3. Edit the file
sudo nano /etc/netplan/01-netcfg.yaml

# 4. Test with automatic rollback
sudo netplan try

# 5. Verify
ip -br addr
ping -c 3 8.8.8.8
```

## Common Errors

| Problem | Cause | Fix |
|---|---|---|
| Netplan YAML error | Tabs or wrong indentation | Use spaces, check with `netplan generate` |
| Config not applied | Wrong interface name | Confirm the name with `ip link` |
| Permissions too open warning | Netplan file readable by others | `chmod 600` the file |
| No internet but gateway pings | Missing or wrong DNS | Check `resolvectl status` and nameservers |
| Lost SSH after change | Wrong IP or gateway | Use `netplan try`, or console access to fix |

## Practice

1. Check which network manager your system uses.
2. Change your hostname, then verify it with `hostnamectl`.
3. Add an entry to `/etc/hosts` and test it with `ping`.
4. Write a Netplan (or `nmcli`) configuration for a static IP, and test it with `netplan try`.
5. Switch back to DHCP and confirm you receive an address.
6. Allow SSH through the firewall and check with `ufw status`.

## Notes

- Add your own output and observations here.
- Screenshot: `../screenshots/network-configuration.png`
- Related: [ip-commands](ip-commands.md)
