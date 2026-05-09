# Disaster Recovery Guide

## When Things Go Wrong

This guide covers common disaster scenarios and how to recover without losing data.

---

## Scenario 1: OS Won't Boot / System Corrupted

**Problem:** ChimeraOS is corrupted, won't boot, or system is unstable.

**Solution:** Reinstall OS without losing any data.

### Quick Recovery Steps:

1. **Boot from ChimeraOS USB installer**
2. **\u26a0\ufe0f CRITICAL: Select ONLY the OS partition** (usually 30GB partition)
   - Do NOT select the storage partition
   - If dual-drive: only select the OS drive
3. **Install ChimeraOS** (takes ~10 minutes)
4. **Boot into fresh OS**
5. **Run restore command:**
   
   **If you have internet:**
   ```bash
   curl -s https://raw.githubusercontent.com/ahsenbaig-boilerplate/car-edge-node/main/scripts/install-bootstrap.sh | sudo bash
   sudo reboot
   ```
   
   **If offline (no internet):**
   ```bash
   sudo mount /dev/sdb1 /mnt/storage  # Use your storage partition
   sudo bash /mnt/storage/car-edge-node-repo/scripts/install-bootstrap.sh
   sudo reboot
   ```

6. **Wait for bootstrap** (~5-10 minutes)
7. **Done!** All your media, games, and saves are back.

### What You Get Back:

✅ All movies, TV shows, music  
✅ All Steam games (no re-download)  
✅ All game saves and progress  
✅ All Minecraft worlds and mods  
✅ All documents and context  
✅ All Syncthing sync state  
✅ All configurations  

### What Gets Reinstalled:

🔄 ChimeraOS system files  
🔄 Flatpak apps (Kodi, Steam UI, etc.)  
🔄 WireGuard and Syncthing (configs restored)  

**Total downtime:** ~15-20 minutes  
**Data lost:** None (if you didn't format storage)

---

## Scenario 2: Storage Drive Failure

**Problem:** The storage drive (`/mnt/storage`) has failed or is corrupted.

**Solution:** This is the ONLY scenario where data loss can occur.

### Recovery Steps:

1. **Replace the failed storage drive**
2. **Create new storage partition:**
   ```bash
   sudo parted /dev/sdb mklabel gpt
   sudo parted /dev/sdb mkpart primary ext4 0% 100%
   sudo mkfs.ext4 -L STORAGE /dev/sdb1
   ```
3. **Mount it:**
   ```bash
   sudo mkdir -p /mnt/storage
   sudo mount /dev/sdb1 /mnt/storage
   ```
4. **Run bootstrap to set up structure:**
   ```bash
   sudo systemctl start bootstrap.service
   ```
5. **Let Syncthing re-sync from homelab** (if configured)

### What You Lose:

❌ All local media (unless synced to homelab)  
❌ All Steam games (need to re-download)  
❌ Game saves (unless cloud-saved or synced)  
❌ Minecraft worlds (unless synced)  

**Prevention:** 
- Use Syncthing to sync critical data to homelab
- Regular backups of Minecraft worlds
- Cloud saves for games (Steam Cloud)

---

## Scenario 3: Accidentally Wiped Storage

**Problem:** You formatted the storage partition during OS reinstall.

**Solution:** Data is lost. Restore from backups.

### Recovery Steps:

1. **Recreate storage partition** (see Scenario 2)
2. **Run bootstrap**
3. **Restore from backups:**
   - Syncthing will re-sync from homelab (if configured)
   - Re-download games from Steam
   - Restore Minecraft worlds from backup (if any)

**Lesson:** Always triple-check which partition you're formatting!

---

## Scenario 4: Lost Internet, Can't Restore

**Problem:** OS is corrupted and you have no internet connectivity.

**Solution:** Use offline restore from storage partition.

### Recovery Steps:

1. **Reinstall ChimeraOS** (OS partition only)
2. **Boot into fresh OS**
3. **Mount storage:**
   ```bash
   sudo mkdir -p /mnt/storage
   sudo mount /dev/sdb1 /mnt/storage
   ```
4. **Run offline installer:**
   ```bash
   sudo bash /mnt/storage/car-edge-node-repo/scripts/install-bootstrap.sh
   sudo reboot
   ```

**Why this works:** The bootstrap repository is automatically synced to storage on every boot, so you always have an offline copy ready.

---

## Scenario 5: Both OS and Storage Drives Fail

**Problem:** Total hardware failure.

**Solution:** Replace hardware and restore from backups.

### Recovery Steps:

1. **Replace failed drives**
2. **Install ChimeraOS on new OS drive**
3. **Create storage partition on new storage drive**
4. **Run online bootstrap:**
   ```bash
   curl -s https://raw.githubusercontent.com/ahsenbaig-boilerplate/car-edge-node/main/scripts/install-bootstrap.sh | sudo bash
   sudo reboot
   ```
5. **Let Syncthing restore from homelab** (if configured)

---

## Prevention Checklist

### Before Any OS Reinstall:

- [ ] Confirm storage partition is `/dev/sdb1` (or your partition)
- [ ] Confirm OS partition is `/dev/sda2` (or your partition)
- [ ] Run `lsblk` to see partition layout
- [ ] Triple-check you're formatting the RIGHT partition
- [ ] When in doubt, don't format anything with data

### Regular Maintenance:

- [ ] Verify storage is mounted: `df -h | grep storage`
- [ ] Check Syncthing sync status (if configured)
- [ ] Verify offline repo exists: `ls /mnt/storage/car-edge-node-repo`
- [ ] Test backup/restore procedure in safe environment

### Backup Strategy:

- [ ] Use Syncthing to sync critical data to homelab
- [ ] Enable Steam Cloud for game saves
- [ ] Regular Minecraft world backups
- [ ] Keep important documents synced to homelab

---

## Quick Reference

### Check Partition Layout:
```bash
lsblk
```

### Check What's Mounted:
```bash
df -h
mount | grep /mnt/storage
```

### Identify Your Partitions:
```bash
sudo blkid
sudo parted -l
```

### Manual Storage Mount:
```bash
sudo mkdir -p /mnt/storage
sudo mount /dev/sdb1 /mnt/storage
```

### Check Bootstrap Status:
```bash
sudo systemctl status bootstrap.service
sudo journalctl -u bootstrap.service -f
```

### Verify Offline Repo:
```bash
ls -la /mnt/storage/car-edge-node-repo
cd /mnt/storage/car-edge-node-repo && git log -1
```

---

## Emergency Contacts

- **Repository:** https://github.com/ahsenbaig-boilerplate/car-edge-node
- **Issues:** https://github.com/ahsenbaig-boilerplate/car-edge-node/issues
- **ChimeraOS Docs:** https://chimeraos.org/docs

---

## Summary

The car-edge-node architecture is designed for **resilient, zero-worry operation**:

- **OS corrupted?** → Reinstall in 15 minutes, no data loss
- **No internet?** → Offline restore from storage partition  
- **Storage fails?** → Only scenario with data loss (use backups)
- **Everything fails?** → Restore from homelab via Syncthing

**Key principle:** OS is disposable, storage is sacred. Protect the storage partition at all costs.
