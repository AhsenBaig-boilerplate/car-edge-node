# Restore / Reimage Flow

## Method 1: Online Restore (Internet Available)

1. Reinstall ChimeraOS (OS partition only).
2. Boot and log in as default user (e.g., `gamer`).
3. Run:

   ```bash
   curl -s https://raw.githubusercontent.com/ahsenbaig-boilerplate/car-edge-node/main/scripts/install-bootstrap.sh | sudo bash
   sudo reboot
   ```

## Method 2: Offline Restore (No Internet Required)

1. Reinstall ChimeraOS (OS partition only).
2. Boot and log in as default user (e.g., `gamer`).
3. Mount the storage partition (if not auto-mounted):

   ```bash
   sudo mkdir -p /mnt/storage
   sudo mount /dev/sdXN /mnt/storage  # Replace with your storage partition
   ```

4. Run the offline installer:

   ```bash
   sudo bash /mnt/storage/car-edge-node-repo/scripts/install-bootstrap.sh
   sudo reboot
   ```

4. After reboot:
   - Bootstrap service auto-runs
   - Storage partition is remounted
   - Flatpaks are reinstalled
   - Syncthing reconnects and syncs data from homelab
   - Steam library paths are restored
   - WireGuard tunnel re-establishes

5. Within minutes, the node is fully operational with:
   - All media back
   - All games accessible
   - All saves synced
   - All context restored

## Post-Restore (Both Methods)

4. After reboot:
   - Bootstrap service auto-runs
   - Storage partition is remounted
   - Flatpaks are reinstalled
   - Syncthing reconnects and syncs data from homelab
   - Steam library paths are restored
   - WireGuard tunnel re-establishes

5. Within minutes, the node is fully operational with:
   - All media back
   - All games accessible
   - All saves synced
   - All context restored

## Why This Works

- All stateful data lives on `/mnt/storage`
- **Offline repository copy** eliminates internet dependency
- OS is disposable and fast to reinstall
- Bootstrap script is idempotent
- Syncthing handles data sync automatically
- No manual configuration needed

## Keeping Offline Copy Updated

The bootstrap script automatically updates the offline repository copy on each boot. You can also manually sync:

```bash
cd /mnt/storage/car-edge-node-repo
git pull origin main
```

Or use the sync script:

```bash
bash /opt/car-edge-node/scripts/sync-repo-to-storage.sh
```
