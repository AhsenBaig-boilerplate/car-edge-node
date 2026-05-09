#!/usr/bin/env bash
#
# prepare-usb.sh
# Create a bootable USB with ChimeraOS + car-edge-node bootstrap
# Run this on your development/preparation machine (Linux/macOS)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================"
echo "Car Edge Node USB Preparation"
echo -e "========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Error: Do not run this script as root${NC}"
    echo "Run as normal user (sudo will be used when needed)"
    exit 1
fi

# Check for required tools
MISSING_TOOLS=()
for tool in curl lsblk parted mkfs.fat dd; do
    if ! command -v "$tool" &>/dev/null; then
        MISSING_TOOLS+=("$tool")
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo -e "${RED}Error: Missing required tools: ${MISSING_TOOLS[*]}${NC}"
    echo "Install them first (e.g., sudo apt install coreutils parted dosfstools)"
    exit 1
fi

# ============================================================================
# Step 1: Get ChimeraOS ISO
# ============================================================================

echo -e "${BLUE}Step 1: ChimeraOS ISO${NC}"
echo ""

ISO_URL="https://github.com/ChimeraOS/chimeraos/releases/latest/download/chimeraos-stable.iso"
ISO_FILE="$REPO_ROOT/chimeraos.iso"

if [ -f "$ISO_FILE" ]; then
    echo -e "${GREEN}ChimeraOS ISO already downloaded${NC}"
    echo "Location: $ISO_FILE"
    read -p "Use existing ISO? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Downloading fresh ISO..."
        curl -L "$ISO_URL" -o "$ISO_FILE"
    fi
else
    echo "Downloading ChimeraOS ISO..."
    echo "This may take a while (typically 2-4 GB)..."
    curl -L "$ISO_URL" -o "$ISO_FILE"
fi

echo ""
echo -e "${GREEN}✓ ChimeraOS ISO ready${NC}"
echo ""

# ============================================================================
# Step 2: Select USB Drive
# ============================================================================

echo -e "${BLUE}Step 2: Select USB Drive${NC}"
echo ""
echo -e "${YELLOW}WARNING: All data on the selected drive will be DESTROYED!${NC}"
echo ""

# List available drives
echo "Available drives:"
lsblk -d -o NAME,SIZE,MODEL,TRAN | grep -E "usb|NAME"
echo ""

read -p "Enter USB drive (e.g., sdb): " USB_DEVICE
USB_DEVICE=$(echo "$USB_DEVICE" | sed 's/^\/dev\///')  # Remove /dev/ if present
USB_PATH="/dev/$USB_DEVICE"

# Validate drive exists
if [ ! -b "$USB_PATH" ]; then
    echo -e "${RED}Error: Drive $USB_PATH does not exist${NC}"
    exit 1
fi

# Check if it's actually USB
if ! lsblk -no TRAN "$USB_PATH" | grep -q "usb"; then
    echo -e "${YELLOW}Warning: $USB_PATH does not appear to be a USB drive${NC}"
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Show drive info
echo ""
echo "Selected drive:"
lsblk "$USB_PATH" -o NAME,SIZE,MODEL,LABEL,MOUNTPOINT
echo ""

# Confirm
echo -e "${RED}⚠️  ALL DATA ON $USB_PATH WILL BE ERASED ⚠️${NC}"
read -p "Type 'YES' to continue: " CONFIRM
if [ "$CONFIRM" != "YES" ]; then
    echo "Aborted."
    exit 1
fi

# ============================================================================
# Step 3: Unmount any mounted partitions
# ============================================================================

echo ""
echo -e "${BLUE}Step 3: Unmounting partitions...${NC}"

for partition in "$USB_PATH"*; do
    if mountpoint -q "$partition" 2>/dev/null; then
        echo "Unmounting $partition..."
        sudo umount "$partition" || true
    fi
done

echo -e "${GREEN}✓ Partitions unmounted${NC}"

# ============================================================================
# Step 4: Write ChimeraOS ISO to USB
# ============================================================================

echo ""
echo -e "${BLUE}Step 4: Writing ChimeraOS ISO to USB...${NC}"
echo "This will take several minutes..."
echo ""

sudo dd if="$ISO_FILE" of="$USB_PATH" bs=4M status=progress oflag=sync

sync
sleep 2

echo ""
echo -e "${GREEN}✓ ChimeraOS ISO written${NC}"

# ============================================================================
# Step 5: Create data partition for bootstrap files
# ============================================================================

echo ""
echo -e "${BLUE}Step 5: Creating data partition for bootstrap files...${NC}"

# Get USB size and ISO size
USB_SIZE=$(sudo blockdev --getsize64 "$USB_PATH")
ISO_SIZE=$(stat -f%z "$ISO_FILE" 2>/dev/null || stat -c%s "$ISO_FILE")
ISO_SIZE_MB=$((ISO_SIZE / 1024 / 1024 + 100))  # Add 100MB buffer

echo "USB size: $((USB_SIZE / 1024 / 1024)) MB"
echo "ISO size: $ISO_SIZE_MB MB"

# Re-read partition table
sudo partprobe "$USB_PATH" 2>/dev/null || true
sleep 2

# Create new partition in remaining space
echo "Creating data partition..."
sudo parted -s "$USB_PATH" mkpart primary fat32 "${ISO_SIZE_MB}MiB" 100%
sudo parted -s "$USB_PATH" set 3 lba on

# Determine partition name (handles /dev/sdb3 vs /dev/mmcblk0p3)
if [[ "$USB_PATH" == *"mmcblk"* ]] || [[ "$USB_PATH" == *"nvme"* ]]; then
    DATA_PARTITION="${USB_PATH}p3"
else
    DATA_PARTITION="${USB_PATH}3"
fi

sleep 2
sudo partprobe "$USB_PATH" 2>/dev/null || true
sleep 2

# Format data partition
echo "Formatting data partition..."
sudo mkfs.fat -F 32 -n "CARNODE" "$DATA_PARTITION"

echo -e "${GREEN}✓ Data partition created${NC}"

# ============================================================================
# Step 6: Mount data partition and copy bootstrap files
# ============================================================================

echo ""
echo -e "${BLUE}Step 6: Copying car-edge-node bootstrap files...${NC}"

MOUNT_POINT=$(mktemp -d)
sudo mount "$DATA_PARTITION" "$MOUNT_POINT"

# Copy entire repository
echo "Copying repository..."
sudo cp -r "$REPO_ROOT" "$MOUNT_POINT/car-edge-node"
sudo chmod -R 755 "$MOUNT_POINT/car-edge-node"

# Create easy-to-run install script at root of partition
echo "Creating quick installer..."
cat << 'EOF' | sudo tee "$MOUNT_POINT/INSTALL.sh" > /dev/null
#!/usr/bin/env bash
#
# Quick installer for car-edge-node
# Run after ChimeraOS installation: sudo bash INSTALL.sh
#

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================"
echo "Car Edge Node Quick Installer"
echo -e "========================================${NC}"
echo ""

# Find the mount point of this script
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run the actual installer from car-edge-node directory
if [ -d "$SCRIPT_PATH/car-edge-node" ]; then
    echo "Running bootstrap installer..."
    bash "$SCRIPT_PATH/car-edge-node/scripts/install-bootstrap.sh"
else
    echo "Error: car-edge-node directory not found"
    exit 1
fi
EOF

sudo chmod +x "$MOUNT_POINT/INSTALL.sh"

# Create README
cat << 'EOF' | sudo tee "$MOUNT_POINT/README.txt" > /dev/null
CAR EDGE NODE INSTALLATION USB
================================

This USB contains ChimeraOS and car-edge-node bootstrap files.

INSTALLATION STEPS:
===================

1. Boot from this USB drive
2. Install ChimeraOS on OS partition (30GB recommended)
   ⚠️  DO NOT format the entire drive - only the OS partition!
3. After installation, boot into ChimeraOS
4. Switch to Desktop Mode (Steam Menu → Power → Switch to Desktop)
5. Open terminal (Konsole)
6. Mount this USB drive:
   
   sudo mkdir -p /mnt/usb
   sudo mount /dev/sdXN /mnt/usb  (replace X with your USB drive letter)
   
   (Usually: sudo mount /dev/sdb3 /mnt/usb)

7. Run the installer:
   
   sudo bash /mnt/usb/INSTALL.sh
   sudo reboot

8. Done! Bootstrap will auto-configure everything on next boot.

MANUAL INSTALLATION:
===================

If you prefer manual installation:

   sudo bash /mnt/usb/car-edge-node/scripts/install-bootstrap.sh
   sudo reboot

DOCUMENTATION:
=============

Full documentation is in: /mnt/usb/car-edge-node/docs/

Key documents:
- os-installation.md - Complete installation guide
- restore-flow.md - Restore procedures
- disaster-recovery.md - Troubleshooting

OFFLINE RESTORE:
===============

After first boot, the bootstrap system copies itself to your storage
partition (/mnt/storage/car-edge-node-repo/). This allows offline
restore without this USB drive.

For offline restore:
   sudo bash /mnt/storage/car-edge-node-repo/scripts/install-bootstrap.sh
   sudo reboot

SUPPORT:
=======

GitHub: https://github.com/ahsenbaig-boilerplate/car-edge-node
Issues: https://github.com/ahsenbaig-boilerplate/car-edge-node/issues
EOF

# Unmount
sync
sudo umount "$MOUNT_POINT"
rmdir "$MOUNT_POINT"

echo -e "${GREEN}✓ Bootstrap files copied${NC}"

# ============================================================================
# Done
# ============================================================================

echo ""
echo -e "${GREEN}========================================"
echo "USB Preparation Complete!"
echo -e "========================================${NC}"
echo ""
echo "Your USB drive ($USB_PATH) is now ready with:"
echo "  ✓ ChimeraOS bootable installer"
echo "  ✓ car-edge-node bootstrap files"
echo "  ✓ Easy-to-run INSTALL.sh script"
echo "  ✓ Complete documentation"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "  1. Boot from this USB on your car mini PC"
echo "  2. Install ChimeraOS (OS partition only!)"
echo "  3. After install, mount the USB data partition"
echo "  4. Run: sudo bash /mnt/usb/INSTALL.sh"
echo "  5. Reboot and enjoy!"
echo ""
echo "See README.txt on the USB for complete instructions."
echo ""
