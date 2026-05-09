# Restore / Reimage Flow

1. Reinstall ChimeraOS (OS partition only).
2. Boot and log in as default user (e.g., `gamer`).
3. Run:

   ```bash
   curl -s https://raw.githubusercontent.com/ahsenbaig-boilerplate/car-edge-node/main/scripts/install-bootstrap.sh | sudo bash
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

## Why This Works

- All stateful data lives on `/mnt/storage`
- OS is disposable and fast to reinstall
- Bootstrap script is idempotent
- Syncthing handles data sync automatically
- No manual configuration needed
