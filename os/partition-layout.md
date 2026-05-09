# Partition Layout

## ⚠️ Critical Concept: OS vs Storage Separation

This system uses **partition separation** to protect your data:

- **OS Partition**: Disposable, can be wiped and reinstalled anytime
- **Storage Partition**: Persistent, contains ALL your valuable data

**When the OS gets corrupted:**
- Wipe and reinstall OS partition → **No data loss**
- Storage partition remains untouched → **All media/games/saves preserved**

This is the foundation of the zero-worry restore strategy.

---

## Recommended Layout

### Option 1: Single Drive

```
/dev/sda1  512MB   EFI System Partition (ESP)
/dev/sda2  30GB    OS Partition (immutable, reinstallable)
/dev/sda3  <rest>  Storage Partition (/mnt/storage)
```

### Option 2: Dual Drive (Recommended)

```
Drive 1 (NVMe/SSD):
/dev/nvme0n1p1  512MB   EFI System Partition
/dev/nvme0n1p2  30GB    OS Partition

Drive 2 (HDD/SSD):
/dev/sdb1       <all>   Storage Partition (/mnt/storage)
```

## ⚠️ Installation Warning

**When installing ChimeraOS:**
- Only select the OS partition for installation
- If using dual-drive setup, only select the OS drive
- **DO NOT** select or format the storage partition/drive
- The ChimeraOS installer should NOT touch your storage

If you accidentally select the wrong partition, **ALL DATA WILL BE LOST**.

---

## Partitioning Commands

### Create OS Partition (ChimeraOS installer handles this)

ChimeraOS installer will automatically partition the target drive.

### Create Storage Partition (Manual)

```bash
# For a separate drive:
sudo parted /dev/sdb mklabel gpt
sudo parted /dev/sdb mkpart primary ext4 0% 100%
sudo mkfs.ext4 -L STORAGE /dev/sdb1

# For same drive (after OS install):
sudo parted /dev/sda mkpart primary ext4 30GB 100%
sudo mkfs.ext4 -L STORAGE /dev/sda3
```

## Mounting

Add to `/etc/fstab` (bootstrap script handles this):

```
LABEL=STORAGE  /mnt/storage  ext4  defaults,nofail  0  2
```

## Verification

```bash
lsblk
df -h
sudo blkid
```
