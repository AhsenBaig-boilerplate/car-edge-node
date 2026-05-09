# Post-Install Notes

> **Note:** For complete installation instructions including partitioning, see [docs/os-installation.md](../docs/os-installation.md)

This document covers additional configuration and troubleshooting after the bootstrap system is installed.

---

## Quick Setup (After OS Installation)

If you've already installed ChimeraOS and created the storage partition, run:

```bash
curl -s https://raw.githubusercontent.com/ahsenbaig-boilerplate/car-edge-node/main/scripts/install-bootstrap.sh | sudo bash
sudo reboot
```

See [OS Installation Guide](../docs/os-installation.md) for complete step-by-step instructions.

---

## After ChimeraOS Install

### 1. Boot into Desktop Mode
- Switch to Desktop mode from Steam UI
- Open terminal (Konsole)

### 2. Set Root Password (if needed)
```bash
sudo passwd
```

### 3. Enable SSH (optional)
```bash
sudo systemctl enable sshd
sudo systemctl start sshd
```

### 4. Install Git (if not present)
```bash
sudo pacman -S git
```

### 5. Clone This Repo
```bash
cd ~
git clone https://github.com/ahsenbaig-boilerplate/car-edge-node.git
cd car-edge-node
```

### 6. Run Bootstrap Installer
```bash
sudo bash scripts/install-bootstrap.sh
sudo reboot
```

## Immutable OS Considerations

- ChimeraOS uses an immutable root filesystem
- System updates are atomic
- User data and configs go in:
  - `/home/gamer/`
  - `/mnt/storage/`
- Flatpaks for user applications
- Avoid installing packages via pacman (they'll be lost on update)

## Troubleshooting

### Bootstrap service not running
```bash
sudo systemctl status bootstrap.service
sudo journalctl -u bootstrap.service
```

### Storage not mounted
```bash
sudo mount -a
df -h
```

### Flatpaks not installing
```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak update
```
