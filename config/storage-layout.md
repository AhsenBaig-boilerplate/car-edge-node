# Storage Layout

## Overview

The `/mnt/storage` partition contains all stateful data that persists across OS reinstalls.

## Directory Structure

```
/mnt/storage/
├── media/                    # Media files (movies, TV, music)
│   ├── movies/
│   ├── tv/
│   └── music/
├── games/                    # Game installations and data
│   ├── steam/               # Steam library
│   │   ├── steamapps/
│   │   └── compatdata/
│   └── other/               # Non-Steam games
├── minecraft/               # Minecraft data
│   ├── instances/           # PrismLauncher instances
│   ├── saves/               # World saves (synced)
│   └── mods/                # Mod files
├── context/                 # Personal context and documents
│   ├── documents/
│   ├── notes/
│   └── projects/
├── config/                  # App configurations
│   ├── syncthing/          # Syncthing config backup
│   ├── wireguard/          # WireGuard config backup
│   ├── flatpak/            # Flatpak overrides backup
│   └── steam/              # Steam config backup
├── backups/                 # Miscellaneous backups
│   ├── screenshots/
│   └── saves/
└── car-edge-node-repo/      # Offline copy of bootstrap repo
    └── (git repository)     # For offline OS restore
```

## Ownership and Permissions

- Owner: `gamer:gamer` (or your user)
- Permissions: `rwxr-xr-x` (755) for directories
- Files: `rw-r--r--` (644)

## Size Recommendations

- **Minimum:** 100GB
- **Recommended:** 500GB - 1TB
- **Media-heavy:** 2TB+

## Offline Repository

The `/mnt/storage/car-edge-node-repo/` directory contains an offline copy of this repository. This enables:

- **Offline restore:** Reinstall OS without internet
- **Version control:** Track what configuration is deployed
- **Quick updates:** Pull latest changes and reinstall

The bootstrap script automatically maintains this copy.

## Sync Strategy

### Syncthing Folders
- `media/` - Receive-only from homelab
- `context/` - Bidirectional sync
- `minecraft/saves/` - Bidirectional sync
- `backups/` - Send-only to homelab

### Not Synced
- `games/steam/` - Too large, reinstall as needed
- `games/other/` - Reinstall as needed
- `config/` - Copied by bootstrap, not live-synced

## Backup Strategy

1. **Critical (daily sync):**
   - `minecraft/saves/`
   - `context/`
   
2. **Important (weekly sync):**
   - `config/`
   - `backups/`

3. **Archival (on-demand):**
   - `games/` (only save data, not full installations)
   - `media/` (source of truth is homelab)

## Disk Usage Monitoring

```bash
# Overall usage
df -h /mnt/storage

# Per-directory usage
du -sh /mnt/storage/*

# Find large files
find /mnt/storage -type f -size +1G -exec ls -lh {} \;
```
