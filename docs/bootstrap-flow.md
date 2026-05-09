# Bootstrap Flow

**Prerequisites:** ChimeraOS installed with proper partitioning. See [os-installation.md](os-installation.md) for complete installation guide.

---

## Quick Overview

1. Install ChimeraOS on OS partition (see [OS Installation Guide](os-installation.md))
2. Create storage partition and mount at `/mnt/storage`
3. Run `scripts/install-bootstrap.sh` once
4. Reboot
5. Bootstrap service auto-configures everything
6. System ready!

---

## Detailed Flow

### Phase 1: OS Installation (Manual)

See [os-installation.md](os-installation.md) for step-by-step guide.

**Key points:**
- Partition correctly: OS separate from storage
- Create storage partition: `/dev/sda3` or `/dev/sdb1`
- Format storage: `ext4` with label `STORAGE`

### Phase 2: Bootstrap Installation (One-Time)

**Online method:**
```bash
curl -s https://raw.githubusercontent.com/ahsenbaig-boilerplate/car-edge-node/main/scripts/install-bootstrap.sh | sudo bash
sudo reboot
```

**Manual method:**
```bash
git clone https://github.com/ahsenbaig-boilerplate/car-edge-node.git
cd car-edge-node
sudo bash scripts/install-bootstrap.sh
sudo reboot
```

**What it does:**
- Copies bootstrap scripts to `/opt/car-edge-node/`
- Installs systemd service
- Configures `/etc/fstab` for storage mount
- Sets first-boot flag
- Enables auto-boot service

### Phase 3: First Boot (Automatic)

On next boot, `bootstrap.service` runs `bootstrap.sh`:

1. **Mount storage partition** at `/mnt/storage`
2. **Create directory structure:**
   - `media/` - Movies, TV, music
   - `games/` - Steam library
   - `minecraft/` - Worlds, mods, instances
   - `context/` - Documents, personal files
   - `config/` - Backup configs
   - `backups/` - Miscellaneous backups
   - `car-edge-node-repo/` - Offline restore copy

3. **Clone/update offline repository:**
   - Clones repo to `/mnt/storage/car-edge-node-repo/`
   - Enables offline restore (no internet needed)

4. **Install Flatpak apps:**
   - Reads from `config/flatpak/apps.txt`
   - Installs Kodi, Steam, etc.
   - Applies overrides from `config/flatpak/overrides.sh`

5. **Configure Syncthing:**
   - Creates config directory
   - Restores config from storage (if exists)
   - Enables systemd service

6. **Configure WireGuard:**
   - Restores config from storage (if exists)
   - Enables systemd service
   - Connects to homelab VPN

7. **Set up Steam library:**
   - Creates `/mnt/storage/games/steam`
   - Ready for Steam to add as library path

8. **Set permissions:**
   - Sets ownership to user
   - Ensures proper read/write access

9. **Mark first boot complete**

### Phase 4: Subsequent Boots (Automatic)

On every boot, `bootstrap.service` runs again (idempotent):

- ✅ Remounts storage
- ✅ Updates offline repo (if online)
- ⏭️ Skips Flatpak install (already done)
- ✅ Ensures services running
- ✅ Verifies permissions

---

## Timeline

| Phase | Duration | Activity |
|-------|----------|----------|
| OS Install | 10-15 min | ChimeraOS installation |
| Partition Setup | 2-5 min | Create storage partition |
| Bootstrap Install | 1 min | Run install script |
| First Reboot | 5-10 min | Auto-configuration |
| **Total** | **20-30 min** | **Fresh install to fully operational** |

---

## After Bootstrap Complete

Your system is ready with:

✅ Storage mounted and structured  
✅ Flatpak apps installed  
✅ Steam library path configured  
✅ Syncthing syncing (if configured)  
✅ WireGuard connected (if configured)  
✅ Offline restore capability  
✅ Zero-data-loss architecture  

### Manual Steps (Optional):

1. **Add Steam library path:**
   - Steam → Settings → Storage
   - Add `/mnt/storage/games/steam`

2. **Configure Syncthing folders:**
   - Browser → http://localhost:8384
   - Add homelab device
   - Share folders

3. **Copy media:**
   - Via Syncthing sync
   - Or manually to `/mnt/storage/media/`

---

## Verification

```bash
# Check storage mount
df -h | grep /mnt/storage

# Check bootstrap status
sudo systemctl status bootstrap.service

# Check bootstrap logs
sudo journalctl -u bootstrap.service -n 50

# Check directory structure
ls -la /mnt/storage

# Check offline repo
ls -la /mnt/storage/car-edge-node-repo

# Check Flatpak apps
flatpak list

# Check Syncthing
systemctl --user status syncthing.service

# Check WireGuard
sudo wg show
```

---

## What Makes This Resilient

1. **Idempotent:** Bootstrap runs on every boot, safe to re-run
2. **Offline-capable:** Repository cached on storage partition
3. **Zero data loss:** OS and storage are separate
4. **Fast restore:** 15-20 minutes from corrupted OS to operational
5. **Automatic:** No manual configuration after first install
6. **Persistent:** All state lives on storage partition

If OS gets corrupted → Reinstall OS → Run bootstrap → Everything back!
