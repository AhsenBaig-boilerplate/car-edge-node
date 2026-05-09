# Restore / Reimage Flow

## ⚠️ CRITICAL: Before You Reinstall

**DO NOT FORMAT THE STORAGE PARTITION!**

- Only reinstall ChimeraOS on the **OS partition** (`/dev/sda2` or `/dev/nvme0n1p2`)
- **NEVER** touch the **storage partition** (`/dev/sda3` or `/dev/sdb1`)
- Your media, games, saves, and Minecraft worlds live on the storage partition
- Formatting storage = **permanent data loss**

## What Gets Preserved

Because the storage partition (`/mnt/storage`) is separate from the OS:

✅ **Preserved (No data loss):**
- All media (movies, TV, music)
- All game installations (Steam library)
- All game saves and progress
- All Minecraft worlds and mods
- All personal documents and context
- Syncthing sync state
- Config backups
- Offline repository copy

❌ **Lost (reinstalled automatically):**
- OS system files (ChimeraOS)
- Flatpak apps (reinstalled by bootstrap)
- System configurations (restored from storage)

---

## Restore Methods

Choose the method that fits your situation:

| Method | Internet? | USB? | Commands | Best For |
|--------|-----------|------|----------|----------|
| **Automated USB** | No | Yes | 2 | Easiest, no typing |
| **Online** | Yes | No | 1 | Quick with internet |
| **Offline** | No | No | 1 | Repeat restores |

---

## Method 1: Automated USB (Easiest)

**Requirements:**
- Pre-prepared USB with ChimeraOS + bootstrap (see [automated-usb-installation.md](automated-usb-installation.md))

**Steps:**

1. **Reinstall ChimeraOS from USB** (OS partition only)
   - Boot from prepared USB
   - Install on OS partition only
   - ⚠️ **DO NOT select storage partition**

2. **Boot into fresh OS**

3. **Mount USB data partition:**
   ```bash
   sudo mkdir -p /mnt/usb
   sudo mount /dev/sdb3 /mnt/usb  # Or: sudo mount LABEL=CARNODE /mnt/usb
   ```

4. **Run installer from USB:**
   ```bash
   sudo bash /mnt/usb/INSTALL.sh
   sudo reboot
   ```

5. **Done!** Bootstrap auto-configures everything.

See [automated-usb-installation.md](automated-usb-installation.md) for USB preparation.

---

## Method 2: Online Restore (Internet Available)

1. **Reinstall ChimeraOS on OS partition ONLY**
   - Select the OS partition (`/dev/sda2` or `/dev/nvme0n1p2`)
   - ⚠️ **DO NOT select the storage partition**

2. Boot and log in as default user (e.g., `gamer`).

3. Run:

   ```bash
   curl -s https://raw.githubusercontent.com/ahsenbaig-boilerplate/car-edge-node/main/scripts/install-bootstrap.sh | sudo bash
   sudo reboot
   ```

## Method 3: Offline Restore (No Internet Required)

1. **Reinstall ChimeraOS on OS partition ONLY**
   - Select the OS partition (`/dev/sda2` or `/dev/nvme0n1p2`)
   - ⚠️ **DO NOT select the storage partition**

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

## Post-Restore (All Methods)

1. After reboot:
   - Bootstrap service auto-runs
   - Storage partition is remounted at `/mnt/storage`
   - Flatpaks are reinstalled (Kodi, Steam, etc.)
   - Syncthing reconnects and syncs data from homelab
   - Steam library paths are restored
   - WireGuard tunnel re-establishes

2. Within minutes, the node is fully operational:
   - ✅ **All media instantly accessible** (movies, TV, music)
   - ✅ **All games ready to play** (Steam library intact)
   - ✅ **All saves preserved** (game progress, Minecraft worlds)
   - ✅ **All context restored** (documents, settings)
   - ✅ **Syncthing resumes sync** (no re-download needed)

**Result:** Your car edge node is back exactly as it was before the OS issue!

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
