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

## Quick Restore

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
