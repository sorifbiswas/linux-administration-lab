# ip Commands

## Overview

The `ip` command (from the **iproute2** package) is the modern tool for viewing and configuring network interfaces, IP addresses, routes and neighbours. It replaces the older `ifconfig`, `route` and `arp` commands.

```
ip [options] object command [arguments]
```

| Object | Purpose |
|---|---|
| `link` | Network interfaces (layer 2) |
| `addr` | IP addresses |
| `route` | Routing table |
| `neigh` | ARP / neighbour table |
| `rule` | Policy routing rules |
| `netns` | Network namespaces |

> Changes made with `ip` are **temporary**. They are lost after a reboot or network restart. See [network-configuration](network-configuration.md) for persistent settings.

## Old vs New Commands

| Old (net-tools) | New (iproute2) |
|---|---|
| `ifconfig` | `ip addr`, `ip link` |
| `ifconfig eth0 up` | `ip link set eth0 up` |
| `route -n` | `ip route` |
| `arp -a` | `ip neigh` |
| `netstat -tulpn` | `ss -tulpn` |

## Viewing Interfaces

```bash
ip link show                    # All interfaces and their state
ip link show eth0               # One interface
ip -s link show eth0            # With packet statistics
ip -br link                     # Brief, one line per interface
```

Common interface names:

| Name | Meaning |
|---|---|
| `lo` | Loopback (127.0.0.1) |
| `eth0`, `enp0s3` | Ethernet |
| `wlan0`, `wlp2s0` | Wireless |
| `docker0`, `virbr0` | Virtual bridges |

## Viewing IP Addresses

```bash
ip addr show                    # All addresses
ip a                            # Short form
ip -br addr                     # Brief overview
ip -4 addr                      # IPv4 only
ip -6 addr                      # IPv6 only
ip addr show dev eth0           # One interface
```

Sample output:

```
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP
    link/ether 08:00:27:ab:cd:ef brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.50/24 brd 192.168.1.255 scope global eth0
    inet6 fe80::a00:27ff:feab:cdef/64 scope link
```

| Field | Meaning |
|---|---|
| `UP` / `LOWER_UP` | Interface enabled / cable connected |
| `mtu` | Maximum packet size |
| `link/ether` | MAC address |
| `inet` | IPv4 address and prefix length |
| `inet6` | IPv6 address |

## Managing Interfaces

```bash
sudo ip link set eth0 up            # Enable
sudo ip link set eth0 down          # Disable
sudo ip link set eth0 mtu 1400      # Change MTU
sudo ip link set eth0 address 02:00:00:00:00:01   # Change MAC (interface must be down)
sudo ip link set eth0 promisc on    # Promiscuous mode
```

## Managing IP Addresses

```bash
sudo ip addr add 192.168.1.50/24 dev eth0       # Add an address
sudo ip addr add 192.168.1.51/24 dev eth0       # Add a second address
sudo ip addr del 192.168.1.51/24 dev eth0       # Remove an address
sudo ip addr flush dev eth0                     # Remove all addresses
```

## Routing

```bash
ip route                                    # Show routing table
ip route show default                       # Default gateway
ip route get 8.8.8.8                        # Which route would be used?

sudo ip route add default via 192.168.1.1                # Set default gateway
sudo ip route add 10.0.0.0/24 via 192.168.1.254          # Route to a network
sudo ip route add 10.0.1.0/24 dev eth0                   # Directly connected network
sudo ip route del 10.0.0.0/24                            # Delete a route
sudo ip route replace default via 192.168.1.1            # Add or replace
```

## ARP / Neighbours

```bash
ip neigh                                    # View ARP table
ip neigh show dev eth0
sudo ip neigh add 192.168.1.10 lladdr 08:00:27:11:22:33 dev eth0
sudo ip neigh del 192.168.1.10 dev eth0
sudo ip neigh flush all                     # Clear the table
```

## Related Diagnostic Commands

```bash
ping -c 4 8.8.8.8               # Test connectivity
ping -c 4 google.com            # Test DNS + connectivity
traceroute 8.8.8.8              # Path to a host (sudo apt install traceroute)
tracepath 8.8.8.8               # Similar, no root needed
ss -tulpn                       # Listening ports and their processes
ss -s                           # Socket summary
dig google.com                  # DNS lookup (sudo apt install dnsutils)
nslookup google.com
hostname -I                     # Quick view of all IPs
curl ifconfig.me                # Public IP address
resolvectl status               # DNS settings (systemd-resolved)
```

### `ss` flags

| Flag | Meaning |
|---|---|
| `-t` | TCP |
| `-u` | UDP |
| `-l` | Listening sockets |
| `-p` | Show the process |
| `-n` | Numeric (no name resolution) |

## Example: Temporary Static IP Configuration

```bash
# 1. Check the current state
ip -br addr
ip route

# 2. Remove existing addresses and set a new one
sudo ip addr flush dev eth0
sudo ip addr add 192.168.1.100/24 dev eth0
sudo ip link set eth0 up

# 3. Add the default gateway
sudo ip route add default via 192.168.1.1

# 4. Test
ping -c 3 192.168.1.1
ping -c 3 8.8.8.8
```

> Be careful when changing the IP of the interface you are connected through via SSH. You may lose your session.

## Example: Troubleshooting No Connectivity

```bash
ip -br link                     # 1. Is the interface UP?
ip -br addr                     # 2. Does it have an IP?
ip route show default           # 3. Is there a default gateway?
ping -c 2 192.168.1.1           # 4. Can I reach the gateway?
ping -c 2 8.8.8.8               # 5. Can I reach the internet?
ping -c 2 google.com            # 6. Does DNS work?
```

Working through these steps in order shows where the problem lies: link, address, gateway, internet or DNS.

## Common Errors

| Error | Cause | Fix |
|---|---|---|
| `RTNETLINK answers: File exists` | Address or route already set | Use `replace` or delete it first |
| `RTNETLINK answers: Operation not permitted` | Missing privileges | Use `sudo` |
| `Cannot find device "eth1"` | Wrong interface name | Check with `ip link` |
| `Network is unreachable` | No route or gateway | Add a route or default gateway |

## Practice

1. List all interfaces and their IP addresses using `ip -br addr`.
2. Find your default gateway and your MAC address.
3. Add a second IP address to an interface, verify it, then remove it.
4. Use `ip route get 8.8.8.8` to see which interface and gateway are used.
5. View your ARP table after pinging another machine on the network.
6. Use `ss -tulpn` to find which service listens on port 22.

## Notes

- Add your own output and observations here.
- Screenshot: `../screenshots/ip-commands.png`
- Related: [network-configuration](network-configuration.md)
