# Car Power Notes

## Power Management Considerations

### Ignition Detection
- Monitor car ignition state via USB power or dedicated GPIO
- Graceful shutdown when ignition turns off
- Configurable delay before shutdown (e.g., 5 minutes)

### Battery Protection
- Never drain car battery below safe threshold
- Use capacitor or UPS for clean shutdown
- Consider voltage monitoring via USB-C PD or dedicated circuit

### Boot Behavior
- Fast boot when ignition turns on
- Resume from suspend vs. cold boot trade-offs
- Autologin for immediate availability

### Filesystem Safety
- Immutable OS reduces corruption risk
- **Separate OS and storage partitions protect data**
- Storage partition with journaling (ext4/btrfs)
- Regular sync-to-disk to prevent data loss
- Even if OS corrupts from power loss, **storage remains intact**

### Data Preservation Strategy
- **OS corruption** from sudden power loss → **No data loss**
  - Reinstall OS partition (15 minutes)
  - Storage partition untouched
  - All media/games/saves preserved
- **Storage corruption** from sudden power loss → **Extremely rare**
  - Journaling filesystem (ext4) protects metadata
  - At worst: minor file corruption, not partition loss
  - Regular Syncthing sync to homelab provides backup

### Power Loss Testing
- Simulate sudden power loss during:
  - Boot sequence
  - App installation
  - Data sync
  - Game save writes

## Implementation Options

1. **Simple: Ignore ignition**
   - Manual power button control
   - User responsible for shutdown

2. **GPIO-based:**
   - Monitor ignition via GPIO pin
   - systemd service for shutdown script

3. **USB Power Detection:**
   - Monitor USB power state
   - Trigger shutdown on power loss

4. **UPS/Capacitor:**
   - Small UPS or supercapacitor
   - 30-60 seconds for clean shutdown
