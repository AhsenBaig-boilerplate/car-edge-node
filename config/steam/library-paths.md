# Steam Library Paths

## Primary Storage
Location: `/mnt/storage/games/steam`

## Configuration

1. Launch Steam
2. Go to Settings > Storage
3. Click "Add Drive"
4. Select `/mnt/storage/games/steam`
5. Set as default for new installations

## Directory Structure

```
/mnt/storage/games/steam/
├── steamapps/
│   ├── common/          # Game installations
│   ├── compatdata/      # Proton prefixes
│   └── shadercache/     # Shader caches
└── config/              # Steam config backups
```

## Tips

- Games install to this path automatically once configured
- Proton compatibility data stored per-game in compatdata/
- Shader cache persists across OS reinstalls
- Backup this entire directory for full game preservation

## Verification

Check current library paths:
```bash
cat ~/.steam/steam/steamapps/libraryfolders.vdf
```

## Recovery

After OS reinstall:
1. Bootstrap script creates `/mnt/storage/games/steam`
2. Open Steam Settings > Storage
3. Steam should auto-detect the existing library
4. If not, manually add the path
