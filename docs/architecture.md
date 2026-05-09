# Architecture

## Goals

- Fast boot, resilient to power loss
- Immutable OS (ChimeraOS / SteamOS-like)
- Persistent media, games, saves, and context
- Automatic restore after reinstall (online or offline)
- **Zero internet dependency** for core restore
- Child-friendly UI (Steam Big Picture + Kodi)

## Layers

1. **OS Layer (Disposable)**
   - ChimeraOS or similar immutable OS
   - Root filesystem read-only
   - Reinstallable in ~10 minutes

2. **Stateful Storage Layer**
   - Separate partition or drive mounted at `/mnt/storage`
   - Holds:
     - Media
     - Games
     - Minecraft
     - Context
     - Syncthing data
     - Flatpak data
     - Steam library
     - **Offline repository copy** (for zero-internet restore)

3. **Automation Layer**
   - `bootstrap.sh` + `bootstrap.service`
   - Idempotent, safe to re-run
   - Auto-mounts storage, installs apps, wires configs
   - Auto-syncs repository to storage for offline restore

4. **Sync Layer**
   - WireGuard for secure tunnel to homelab
   - Syncthing for media/context sync

5. **UI Layer**
   - Steam Big Picture as primary UI
   - Kodi for media
   - Minecraft launcher (PrismLauncher)
