# Bootstrap Flow

1. Install ChimeraOS on OS partition.
2. Create storage partition and mount at `/mnt/storage`.
3. Run `scripts/install-bootstrap.sh` once.
4. Reboot.
5. On next boot:
   - `bootstrap.service` runs `bootstrap.sh`
   - Storage is mounted
   - Flatpaks installed
   - Syncthing + WireGuard configured
   - Steam library path prepared
6. Syncthing connects to homelab and syncs media/context.
