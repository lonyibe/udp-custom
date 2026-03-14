# UDP Custom Manager — by LonyiDev

**Version:** `0.0.1` &nbsp;|&nbsp; **Author:** LonyiDev &nbsp;|&nbsp; **GitHub:** [github.com/lonyibe](https://github.com/lonyibe)

---

UDP Custom Manager is an advanced VPS tunnel manager for **HTTP Custom / UDP Custom** connections, featuring a modern terminal UI built by LonyiDev.

---

## Supported OS

| OS | Arch | Status |
|---|---|---|
| Ubuntu 20.04 | x86_64 | ✅ Recommended |
| Ubuntu 22.04 | x86_64 | ✅ Supported |
| Ubuntu 24.04 | x86_64 | ✅ Supported |
| ARM | any | ❌ Not supported |

---

## Install

```bash
sudo -s
```

```bash
git clone https://github.com/lonyibe/udp-custom && cd udp-custom && chmod +x install.sh && ./install.sh
```

Or one-liner:

```bash
wget -O install.sh https://raw.githubusercontent.com/lonyibe/udp-custom/main/install.sh && chmod +x install.sh && ./install.sh
```

---

## Features

| Feature | Description |
|---|---|
| 👤 User Management | Create, remove, renew, block/unblock SSH users |
| 🛡️ Multi-Login Limiter | Block users who exceed max connections |
| ⏱️ Expiry Limiter | Auto-lock expired accounts |
| 💬 Custom Messages | Set MOTD, SSH banner & UDP response |
| 🖥️ VPS Information | Full system dashboard (IP, ISP, CPU, RAM, disk) |
| 📡 Connection Monitor | Live view of active user connections |
| 🔌 Port Manager | View listening ports & service status |
| 📦 Backup & Restore | Backup and restore config files |
| ⚡ UDP Speed Tweaks | Kernel-level network optimisations |
| 🗑️ Uninstall | Clean removal of all components |

---

## Menu Command

After installation, type:

```bash
udp
```

---

## Config

Config file location: `/root/udp/config.json`

After editing, restart the service:

```bash
systemctl restart udp-custom
```

---

## Notes

- Firewall (UFW/firewalld) is disabled on install — all ports are open by default.
- Exclude UDP ports used by other tunnels (SlowDNS, WireGuard, OpenVPN) in the Port Manager.

---

> Made with ❤️ by **LonyiDev** — [github.com/lonyibe](https://github.com/lonyibe)
