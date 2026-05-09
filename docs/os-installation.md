# OS Installation Guide

Complete guide for installing ChimeraOS with proper partition layout for the car-edge-node.

---

## Prerequisites

- [ ] ChimeraOS USB installer (download from [chimeraos.org](https://chimeraos.org))
- [ ] Car mini PC hardware
- [ ] USB keyboard/mouse (for initial setup)
- [ ] Monitor or display
- [ ] Understanding of your drive layout (see below)

---

## Part 1: Understand Your Hardware

Before installing, identify your drives:

### Single Drive Setup (Simple)
- One SSD/NVMe (e.g., 500GB+)
- Will be split: 30GB for OS, rest for storage
- **Example:** 500GB drive → 30GB OS + 470GB storage

### Dual Drive Setup (Recommended)
- Drive 1: Small SSD/NVMe for OS (e.g., 64GB+)
- Drive 2: Large HDD/SSD for storage (e.g., 500GB+)
- **Better:** OS and storage physically separated
- **Benefit:** Easier to manage, safer reinstalls

---

## Part 2: Boot ChimeraOS Installer

1. **Create bootable USB** (from another computer):
   - Download ChimeraOS ISO
   - Use Rufus (Windows), Etcher (Mac/Linux), or `dd`
   - Write ISO to USB drive

2. **Boot from USB:**
   - Insert USB into car mini PC
   - Press boot menu key (usually F12, F2, Del, or Esc)
   - Select USB drive
   - Boot into ChimeraOS installer

3. **Installer starts:**
   - Select language
   - Proceed to disk selection

---

## Part 3: Partitioning (CRITICAL STEP)

### ⚠️ WARNING: This Step Determines Data Safety

The partitioning strategy is **the foundation** of zero-data-loss recovery.

---

### Option A: Automatic Partitioning (Single Drive - Simple)

**Use Case:** You have one drive and want simple setup.

1. **In ChimeraOS installer, select your drive**
   - Example: `/dev/sda` (500GB SSD)
   
2. **Choose "Automatic Partitioning"**
   - Installer creates:
     - `/dev/sda1` - 512MB EFI
     - `/dev/sda2` - ~30GB OS
     - **Leaves remaining space unpartitioned**

3. **⚠️ IMPORTANT:** Installer only uses ~30GB
   - Remaining space stays unallocated
   - We'll create storage partition AFTER OS install

4. **Proceed with installation** → OS installs on `/dev/sda2`

---

### Option B: Manual Partitioning (Single Drive - Recommended)

**Use Case:** You want precise control over partition sizes.

1. **In installer, choose "Manual Partitioning"**

2. **Create partitions manually:**

   **Partition 1 - EFI System:**
   - Size: 512MB
   - Type: EFI System Partition
   - Mount: `/boot/efi`
   - Format: FAT32

   **Partition 2 - OS:**
   - Size: 30GB
   - Type: Linux filesystem
   - Mount: `/`
   - Format: ext4 or btrfs

   **Partition 3 - Storage:**
   - Size: Rest of drive
   - Type: Linux filesystem
   - Mount: **(Leave unmounted during install)**
   - Format: ext4
   - Label: `STORAGE`

3. **⚠️ KEY POINT:** Set mount point for OS partition only
   - Do NOT mount storage partition during install
   - We'll mount it at `/mnt/storage` later

4. **Proceed with installation** → OS installs on partition 2

---

### Option C: Dual Drive Setup (Best for Safety)

**Use Case:** You have two drives (OS drive + storage drive).

1. **In installer, select OS drive ONLY**
   - Example: `/dev/nvme0n1` (64GB NVMe)
   - **DO NOT select storage drive yet**

2. **Choose automatic or manual partitioning:**
   - EFI: 512MB
   - OS: Rest of drive (~63GB)

3. **Storage drive:**
   - **During OS install:** Ignore it completely
   - **After OS install:** We'll partition it separately

4. **Proceed with installation** → OS installs on NVMe

**Why this is best:**
- OS and storage are physically separate
- Impossible to accidentally wipe storage during OS reinstall
- Can replace either drive independently
- Clearer recovery procedures

---

## Part 4: Complete OS Installation

1. **Set username** (recommended: `gamer`)
   - This matches the default in bootstrap scripts
   - If you use different username, you'll need to update scripts

2. **Set password**
   - Store securely
   - Needed for sudo access

3. **Wait for installation**
   - Usually 5-10 minutes
   - Installer will copy OS, install bootloader

4. **Installation complete:**
   - Remove USB drive
   - Reboot into fresh ChimeraOS

---

## Part 5: First Boot Setup

### A. Boot into ChimeraOS

1. System boots into Steam Big Picture mode
2. **Switch to Desktop mode:**
   - Steam Menu → Power → Switch to Desktop
   - Or press Ctrl+Alt+F2 for terminal

### B. Open Terminal

- Desktop mode → Open Konsole (terminal)
- Or use Ctrl+Alt+F2 for TTY

---

## Part 6: Create Storage Partition (If Not Done During Install)

### For Single Drive (Automatic Install):

The installer left space unpartitioned. Create storage partition now:

```bash
# Check current partition layout
lsblk

# You should see something like:
# sda      500GB
# ├─sda1   512M  /boot/efi
# ├─sda2   30G   /
# └─       470G  (unallocated)

# Create storage partition
sudo parted /dev/sda mkpart primary ext4 30.5GB 100%

# Format it
sudo mkfs.ext4 -L STORAGE /dev/sda3

# Verify
lsblk
```

### For Dual Drive Setup:

Create partition on storage drive:

```bash
# Check drives
lsblk

# Identify storage drive (e.g., /dev/sdb)
# Create partition table and partition
sudo parted /dev/sdb mklabel gpt
sudo parted /dev/sdb mkpart primary ext4 0% 100%

# Format with label
sudo mkfs.ext4 -L STORAGE /dev/sdb1

# Verify
lsblk
```

### Mount Storage Temporarily:

```bash
sudo mkdir -p /mnt/storage
sudo mount /dev/sdb1 /mnt/storage  # Or /dev/sda3 for single drive
df -h | grep storage
```

---

## Part 7: Install Bootstrap System

### Option A: Online Install (Internet Available)

```bash
curl -s https://raw.githubusercontent.com/ahsenbaig-boilerplate/car-edge-node/main/scripts/install-bootstrap.sh | sudo bash
```

### Option B: Manual Install (For Testing/Development)

```bash
# Install git if needed
sudo pacman -S git

# Clone repository
cd ~
git clone https://github.com/ahsenbaig-boilerplate/car-edge-node.git
cd car-edge-node

# Run installer
sudo bash scripts/install-bootstrap.sh
```

### What the Installer Does:

- ✅ Copies bootstrap scripts to `/opt/car-edge-node/`
- ✅ Installs systemd service for auto-boot
- ✅ Configures `/etc/fstab` for storage partition
- ✅ Sets up first-boot flag
- ✅ Enables bootstrap service

---

## Part 8: Reboot and Let Bootstrap Run

```bash
sudo reboot
```

### What Happens on Next Boot:

1. **Bootstrap service starts automatically**
2. **Storage partition mounts** at `/mnt/storage`
3. **Directory structure created** (media, games, minecraft, etc.)
4. **Repository synced** to `/mnt/storage/car-edge-node-repo/` (for offline restore)
5. **Flatpak apps installed** (Kodi, etc.)
6. **Syncthing configured** (if config exists)
7. **WireGuard configured** (if config exists)
8. **Steam library prepared** at `/mnt/storage/games/steam`
9. **System ready!**

Check status:
```bash
sudo systemctl status bootstrap.service
sudo journalctl -u bootstrap.service -f
```

---

## Part 9: Post-Installation Configuration

### 1. Verify Storage Mount

```bash
df -h | grep /mnt/storage
ls -la /mnt/storage
```

You should see:
```
/mnt/storage/
├── media/
├── games/
├── minecraft/
├── context/
├── config/
├── backups/
└── car-edge-node-repo/
```

### 2. Configure Steam Library

1. Open Steam
2. Settings → Storage
3. Add Library Folder → Browse to `/mnt/storage/games/steam`
4. Confirm

### 3. Install Flatpak Apps

Bootstrap installs these automatically (check `config/flatpak/apps.txt`):
- Kodi (media player)
- Additional apps as configured

Verify:
```bash
flatpak list
```

### 4. Configure Syncthing (Optional)

If syncing to homelab:

1. Open browser → http://localhost:8384
2. Add remote device (your homelab)
3. Configure folders to sync:
   - `/mnt/storage/media` → Homelab media
   - `/mnt/storage/minecraft/saves` → Minecraft backups
   - `/mnt/storage/context` → Personal files

### 5. Configure WireGuard (Optional)

If connecting to homelab VPN:

1. Copy WireGuard config to storage:
   ```bash
   sudo cp ~/wg0.conf /mnt/storage/config/wireguard/wg0.conf
   sudo chmod 600 /mnt/storage/config/wireguard/wg0.conf
   ```

2. Reboot (bootstrap will configure it):
   ```bash
   sudo reboot
   ```

3. Verify connection:
   ```bash
   sudo wg show
   ```

---

## Part 10: Verification Checklist

After installation and first reboot:

- [ ] Storage mounted at `/mnt/storage`
- [ ] Bootstrap service enabled and ran successfully
- [ ] Directory structure created in storage
- [ ] Offline repo at `/mnt/storage/car-edge-node-repo/`
- [ ] Flatpak apps installed (Kodi, etc.)
- [ ] Steam recognizes storage library path
- [ ] Syncthing running (if configured)
- [ ] WireGuard connected (if configured)
- [ ] System boots to Steam Big Picture UI

---

## Troubleshooting

### Storage Not Mounting

```bash
# Check fstab
cat /etc/fstab | grep storage

# Should see:
# LABEL=STORAGE  /mnt/storage  ext4  defaults,nofail  0  2

# Mount manually
sudo mount -a

# Check dmesg for errors
sudo dmesg | grep -i storage
```

### Bootstrap Service Failed

```bash
# Check status
sudo systemctl status bootstrap.service

# View logs
sudo journalctl -u bootstrap.service -n 100

# Run manually for debugging
sudo bash /opt/car-edge-node/bootstrap/bootstrap.sh
```

### Wrong Drive Selected During Install

If you accidentally installed OS on storage drive:

1. **Don't panic**
2. **Re-run installer**
3. **Carefully select correct drive**
4. **Storage data is lost** (restore from backups)

**Prevention:** Always verify drive selection in installer!

---

## Summary

**Installation flow:**

1. ✅ Boot ChimeraOS installer
2. ✅ Partition: 512MB EFI + 30GB OS + Rest storage
3. ✅ Install ChimeraOS on OS partition only
4. ✅ Boot into fresh OS
5. ✅ Create/format storage partition (if not done)
6. ✅ Mount storage at `/mnt/storage`
7. ✅ Run bootstrap installer
8. ✅ Reboot
9. ✅ Bootstrap auto-configures everything
10. ✅ System ready with zero-data-loss architecture

**Result:**
- OS is disposable and reinstallable
- Storage is persistent and protected
- Offline restore capability built-in
- All media/games/saves preserved across OS reinstalls

---

## Next Steps

- **Read:** [docs/bootstrap-flow.md](bootstrap-flow.md) - Understand auto-configuration
- **Read:** [docs/restore-flow.md](restore-flow.md) - Learn offline restore
- **Read:** [docs/disaster-recovery.md](disaster-recovery.md) - Handle failures
- **Configure:** Add your WireGuard and Syncthing configs
- **Enjoy:** Your resilient car edge node!
