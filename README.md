# car-edge-node

Car-mounted mini PC running ChimeraOS/SteamOS-style immutable OS, acting as a **mobile edge node** for:

- Offline media (Kodi)
- Offline context (Syncthing + homelab)
- Minecraft + Steam games
- Fast reimage with automatic restore
- **Offline restore capability** (no internet required)
- Child-friendly, console-like UI

This repo contains:

- Bootstrap scripts
- Systemd units
- Config templates
- Docs for reinstall and restore flows
- **Offline restore support** (repo auto-synced to storage)

See `docs/architecture.md` and `docs/bootstrap-flow.md` for details.

## Key Features

- **Zero Data Loss on OS Reinstall:** Separate OS and storage partitions
- **Offline Restore:** No internet needed, restore from `/mnt/storage`
- **Fast Recovery:** 15-20 minutes from corrupted OS to fully operational
- **Resilient to Power Loss:** Immutable OS, all state on persistent storage

## Quick Restore

**Automated USB (No typing required):**
```bash
# Prepare USB once on dev machine:
bash scripts/prepare-usb.sh

# On car mini PC after OS install:
sudo mount /dev/sdb3 /mnt/usb
sudo bash /mnt/usb/INSTALL.sh
sudo reboot
```
See [automated-usb-installation.md](docs/automated-usb-installation.md)

**Online (with internet):**
```bash
curl -s https://raw.githubusercontent.com/ahsenbaig-boilerplate/car-edge-node/main/scripts/install-bootstrap.sh | sudo bash
sudo reboot
```

**Offline (no internet):**
```bash
sudo mount /dev/sdXN /mnt/storage  # Your storage partition
sudo bash /mnt/storage/car-edge-node-repo/scripts/install-bootstrap.sh
sudo reboot
```

See [docs/restore-flow.md](docs/restore-flow.md) for complete instructions.

## Documentation

### Getting Started
- **[Automated USB Installation](docs/automated-usb-installation.md)** - 🚀 **EASIEST** - Zero typing, single USB
- **[OS Installation Guide](docs/os-installation.md)** - Complete manual installation walkthrough
- **[Bootstrap Flow](docs/bootstrap-flow.md)** - How automatic setup works
- **[Architecture](docs/architecture.md)** - System design and layers

### Configuration & Storage
- **[Storage Layout](config/storage-layout.md)** - Data organization on persistent storage
- **[Partition Layout](os/partition-layout.md)** - Disk partitioning strategy
- **[Car Power Notes](docs/car-power-notes.md)** - Power management considerations

### Recovery & Troubleshooting
- **[Restore Flow](docs/restore-flow.md)** - Online and offline restore procedures
- **[Disaster Recovery](docs/disaster-recovery.md)** - Troubleshooting and recovery scenarios
