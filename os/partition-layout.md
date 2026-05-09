# Partition Layout

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
