# Automated USB Installation

This guide shows how to create a **single USB drive** containing both ChimeraOS installer and car-edge-node bootstrap files, eliminating the need to type CLI commands during installation.

---

## Overview

**Traditional Method:**
1. Install ChimeraOS from USB
2. Type: `curl -s https://raw.githubusercontent.com/...` 
3. Manual bootstrap installation

**Automated USB Method:**
1. Prepare USB once (contains everything)
2. Install ChimeraOS from USB
3. Run: `sudo bash /mnt/usb/INSTALL.sh`
4. Done!

**Benefits:**
- ✅ No internet needed during installation
- ✅ No typing GitHub URLs
- ✅ No copying long commands
- ✅ Single USB drive contains everything
- ✅ Includes full documentation offline
- ✅ Can install in remote locations with no connectivity

---

## Part 1: Prepare USB Drive (One Time)

Run this on your **development machine** (laptop/desktop with Linux or macOS).

### Requirements:

- USB drive (8GB+ recommended, 16GB+ ideal)
- Linux or macOS computer
- Internet connection (to download ChimeraOS ISO)
- This repository cloned locally

### Steps:

1. **Clone repository** (if not already):
   ```bash
   git clone https://github.com/ahsenbaig-boilerplate/car-edge-node.git
   cd car-edge-node
   ```

2. **Run USB preparation script**:
   ```bash
   bash scripts/prepare-usb.sh
   ```

3. **Follow prompts**:
   - Script downloads ChimeraOS ISO (~2-4 GB)
   - Select your USB drive (e.g., `sdb`)
   - Confirm (all USB data will be erased)
   - Wait for USB creation (~10-15 minutes)

4. **USB is ready!**
   - ChimeraOS bootable installer
   - car-edge-node bootstrap files
   - Easy INSTALL.sh script
   - Complete offline documentation

### What the Script Does:

```
1. Downloads ChimeraOS ISO (if not cached)
2. Writes bootable ISO to USB
3. Creates data partition in remaining space
4. Copies car-edge-node repository to USB
5. Creates quick INSTALL.sh script
6. Adds README.txt with instructions
```

---

## Part 2: Install on Car Mini PC

### Phase 1: Install ChimeraOS

1. **Boot from USB**:
   - Insert USB into car mini PC
   - Press boot menu key (F12, F2, Del, or Esc)
   - Select USB drive
   - Boot into ChimeraOS installer

2. **Install ChimeraOS**:
   - Follow installer prompts
   - **Select OS partition/drive only** (see partitioning section)
   - ⚠️ **DO NOT format entire drive** - only OS partition
   - Create user (recommended: `gamer`)
   - Wait for installation (~5-10 minutes)

3. **Reboot**:
   - Remove USB (or leave it in)
   - Boot into fresh ChimeraOS

### Phase 2: Run Bootstrap Installer

1. **Switch to Desktop Mode**:
   - Steam Menu → Power → Switch to Desktop
   - Or press Ctrl+Alt+F2 for terminal

2. **Open Terminal** (Konsole)

3. **Mount USB data partition**:
   ```bash
   # Create mount point
   sudo mkdir -p /mnt/usb
   
   # Find USB partition (usually sdb3 or sdc3)
   lsblk
   
   # Mount USB data partition (CARNODE label)
   sudo mount /dev/sdb3 /mnt/usb  # Adjust device name if needed
   
   # Or mount by label
   sudo mount LABEL=CARNODE /mnt/usb
   ```

4. **Run quick installer**:
   ```bash
   sudo bash /mnt/usb/INSTALL.sh
   ```
   
   Or full path:
   ```bash
   sudo bash /mnt/usb/car-edge-node/scripts/install-bootstrap.sh
   ```

5. **Reboot**:
   ```bash
   sudo reboot
   ```

6. **Done!**
   - Bootstrap auto-configures on next boot
   - USB drive can be safely removed
   - System has offline repository copy for future restores

---

## Partitioning During Installation

### Scenario A: Single Drive Setup

**During ChimeraOS installer:**

1. Select your drive (e.g., 500GB SSD)
2. Choose partitioning:
   - **Automatic**: Installer uses ~30GB, leaves rest unpartitioned
   - **Manual**: Create 512MB EFI + 30GB OS + Rest storage

3. After OS install, create storage partition:
   ```bash
   sudo parted /dev/sda mkpart primary ext4 30.5GB 100%
   sudo mkfs.ext4 -L STORAGE /dev/sda3
   ```

### Scenario B: Dual Drive Setup (Recommended)

**Drive 1 (OS):** NVMe/SSD for ChimeraOS  
**Drive 2 (Storage):** HDD/SSD for persistent data

**During ChimeraOS installer:**
- Select OS drive only (e.g., /dev/nvme0n1)
- Let installer partition automatically

**After OS install:**
```bash
sudo parted /dev/sdb mklabel gpt
sudo parted /dev/sdb mkpart primary ext4 0% 100%
sudo mkfs.ext4 -L STORAGE /dev/sdb1
```

See [os-installation.md](os-installation.md) for detailed partitioning guide.

---

## What Gets Installed

When you run `INSTALL.sh` from the USB:

1. ✅ Bootstrap scripts → `/opt/car-edge-node/`
2. ✅ Systemd service enabled
3. ✅ Storage mount configured in `/etc/fstab`
4. ✅ First-boot flag set

On next boot, bootstrap automatically:

- 🔄 Mounts storage partition
- 🔄 Creates directory structure
- 🔄 Clones repository to storage (offline copy)
- 🔄 Installs Flatpak apps
- 🔄 Configures Syncthing & WireGuard
- 🔄 Sets up Steam library paths

---

## USB Data Partition Contents

After USB preparation, the data partition (labeled `CARNODE`) contains:

```
/mnt/usb/
├── INSTALL.sh              # Quick installer script
├── README.txt              # Installation instructions
└── car-edge-node/          # Complete repository
    ├── bootstrap/
    ├── config/
    ├── docs/
    │   ├── os-installation.md
    │   ├── disaster-recovery.md
    │   └── ...
    ├── scripts/
    └── ...
```

**Access documentation offline:**
```bash
sudo mount /dev/sdb3 /mnt/usb
cat /mnt/usb/README.txt
cat /mnt/usb/car-edge-node/docs/os-installation.md
```

---

## Troubleshooting

### Can't Find USB Partition

```bash
# List all drives and partitions
lsblk

# Look for partition labeled "CARNODE"
lsblk -o NAME,SIZE,LABEL,MOUNTPOINT

# Mount by label instead
sudo mount LABEL=CARNODE /mnt/usb
```

### USB Preparation Failed

**On Linux:** Run script with `bash -x` for debugging:
```bash
bash -x scripts/prepare-usb.sh
```

**On macOS:** Some commands may need homebrew packages:
```bash
brew install coreutils parted
```

**On Windows:** Use WSL2 or a Linux VM:
```bash
wsl --install
# Then run prepare-usb.sh inside WSL
```

### Alternative: Manual USB Preparation

If script doesn't work, manually create USB:

1. Use Etcher/Rufus to burn ChimeraOS ISO
2. After burning, USB has unallocated space
3. Create FAT32 partition in remaining space
4. Copy car-edge-node repository to new partition
5. Create INSTALL.sh script (see prepare-usb.sh for template)

---

## Comparison: Installation Methods

| Feature | Automated USB | Online Install | Offline Restore |
|---------|---------------|----------------|-----------------|
| Internet needed | No | Yes | No |
| Commands to type | 2 | 1 (long) | 1 |
| USB required | Yes (once) | No | No |
| GitHub access | No | Yes | No |
| Setup time | 15 min prep | 0 | 0 |
| Install time | 5 min | 5 min | 5 min |
| Best for | New installs | Quick restore | Repeat restores |

---

## Advanced: Updating USB

To update bootstrap files on existing USB:

1. **Mount USB data partition**:
   ```bash
   sudo mount /dev/sdb3 /mnt/usb
   ```

2. **Update repository**:
   ```bash
   cd /mnt/usb/car-edge-node
   sudo git pull origin main
   ```

3. **Unmount**:
   ```bash
   sudo umount /mnt/usb
   ```

---

## FAQ

**Q: Can I use this USB for multiple installations?**  
A: Yes! The USB is reusable for any number of car mini PCs.

**Q: Do I need to keep the USB after installation?**  
A: No. After first boot, bootstrap copies itself to storage partition for future offline restores.

**Q: Can I add custom configurations to the USB?**  
A: Yes! Mount the data partition and edit files in `car-edge-node/config/`.

**Q: What if I don't have Linux/macOS to prepare USB?**  
A: Use Windows WSL2, or manually create USB (see troubleshooting section).

**Q: How do I update ChimeraOS on the USB?**  
A: Re-run `prepare-usb.sh` to download latest ChimeraOS ISO and recreate USB.

---

## Summary

**Automated USB = Zero Typing Installation**

1. **Prepare once:** Run `prepare-usb.sh` on dev machine
2. **Install anywhere:** Boot USB → Install OS → Run `INSTALL.sh`
3. **No internet needed:** Everything on USB
4. **No typing commands:** Simple bash script
5. **Includes docs:** Offline documentation included

Perfect for:
- 🚗 Car installations with no WiFi
- 🏔️ Remote locations
- 👨‍👩‍👧‍👦 Non-technical users
- 🔁 Multiple installations
- 📦 Production deployments

---

## Next Steps

- **Create USB:** Run [scripts/prepare-usb.sh](../scripts/prepare-usb.sh)
- **Install:** Follow Phase 1 & 2 above
- **Verify:** Check [os-installation.md](os-installation.md) Part 10
- **Configure:** Set up Syncthing, WireGuard, media
- **Enjoy:** Zero-worry car edge node!
