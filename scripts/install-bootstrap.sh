#!/usr/bin/env bash
#
# install-bootstrap.sh
# One-time installer for bootstrap system
# Run once after ChimeraOS install
#

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================"
echo "Car Edge Node Bootstrap Installer"
echo -e "========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root (use sudo)${NC}"
    exit 1
fi

INSTALL_DIR="/opt/car-edge-node"
BOOTSTRAP_DIR="$INSTALL_DIR/bootstrap"
CONFIG_DIR="$INSTALL_DIR/config"
SCRIPTS_DIR="$INSTALL_DIR/scripts"
FIRST_BOOT_FLAG="/etc/car-edge-first-boot"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Installing from: $REPO_ROOT"
echo "Installing to: $INSTALL_DIR"
echo ""

# ============================================================================
# 1. Copy Files
# ============================================================================

echo -e "${BLUE}Copying bootstrap files...${NC}"

mkdir -p "$INSTALL_DIR"
cp -r "$REPO_ROOT"/* "$INSTALL_DIR/"

echo -e "${GREEN}Files copied${NC}"

# ============================================================================
# 2. Set Permissions
# ============================================================================

echo -e "${BLUE}Setting permissions...${NC}"

chmod +x "$BOOTSTRAP_DIR/bootstrap.sh"
chmod +x "$BOOTSTRAP_DIR/post-bootstrap-check.sh"
chmod +x "$SCRIPTS_DIR"/*.sh
chmod +x "$CONFIG_DIR/flatpak/overrides.sh"

echo -e "${GREEN}Permissions set${NC}"

# ============================================================================
# 3. Install Systemd Service
# ============================================================================

echo -e "${BLUE}Installing systemd service...${NC}"

# Update User in service file if not 'gamer'
CURRENT_USER="${SUDO_USER:-$USER}"
if [ "$CURRENT_USER" != "gamer" ]; then
    sed -i "s/User=gamer/User=$CURRENT_USER/" "$BOOTSTRAP_DIR/bootstrap.service"
fi

cp "$BOOTSTRAP_DIR/bootstrap.service" /etc/systemd/system/
systemctl daemon-reload
systemctl enable bootstrap.service

echo -e "${GREEN}Systemd service installed and enabled${NC}"

# ============================================================================
# 4. Setup fstab for Storage Partition
# ============================================================================

echo -e "${BLUE}Checking /etc/fstab for storage partition...${NC}"

if ! grep -q "/mnt/storage" /etc/fstab; then
    echo ""
    echo -e "${BLUE}Storage partition not found in /etc/fstab${NC}"
    echo "Please add your storage partition to /etc/fstab manually:"
    echo ""
    echo "  LABEL=STORAGE  /mnt/storage  ext4  defaults,nofail  0  2"
    echo ""
    echo "Or identify your storage partition:"
    lsblk -f
    echo ""
    read -p "Press Enter to continue..."
else
    echo -e "${GREEN}Storage partition already configured${NC}"
fi

# ============================================================================
# 5. Create First Boot Flag
# ============================================================================

echo -e "${BLUE}Creating first boot flag...${NC}"

touch "$FIRST_BOOT_FLAG"

echo -e "${GREEN}First boot flag created${NC}"

# ============================================================================
# Done
# ============================================================================

echo ""
echo -e "${GREEN}========================================"
echo "Installation Complete!"
echo -e "========================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Ensure storage partition is mounted or in /etc/fstab"
echo "  2. Reboot: sudo reboot"
echo "  3. After reboot, verify: bash $SCRIPTS_DIR/post-bootstrap-check.sh"
echo ""
echo "To manually run bootstrap:"
echo "  sudo -u $CURRENT_USER $BOOTSTRAP_DIR/bootstrap.sh"
echo ""
