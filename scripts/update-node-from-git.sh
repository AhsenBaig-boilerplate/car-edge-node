#!/usr/bin/env bash
#
# update-node-from-git.sh
# Pull latest changes from Git and reinstall bootstrap
#

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================"
echo "Car Edge Node Update from Git"
echo -e "========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root (use sudo)${NC}"
    exit 1
fi

INSTALL_DIR="/opt/car-edge-node"
REPO_URL="${REPO_URL:-https://github.com/ahsenbaig-boilerplate/car-edge-node.git}"
TEMP_DIR="/tmp/car-edge-node-update"

# ============================================================================
# 1. Clone Latest Version
# ============================================================================

echo -e "${BLUE}Fetching latest version from Git...${NC}"

rm -rf "$TEMP_DIR"
git clone "$REPO_URL" "$TEMP_DIR"

if [ ! -d "$TEMP_DIR" ]; then
    echo -e "${RED}Failed to clone repository${NC}"
    exit 1
fi

echo -e "${GREEN}Repository cloned${NC}"

# ============================================================================
# 2. Backup Current Installation
# ============================================================================

echo -e "${BLUE}Backing up current installation...${NC}"

BACKUP_DIR="/tmp/car-edge-node-backup-$(date +%Y%m%d-%H%M%S)"
cp -r "$INSTALL_DIR" "$BACKUP_DIR"

echo -e "${GREEN}Backup created at $BACKUP_DIR${NC}"

# ============================================================================
# 3. Update Files
# ============================================================================

echo -e "${BLUE}Updating files...${NC}"

# Remove old installation (preserve logs)
mv "$INSTALL_DIR" "$INSTALL_DIR.old"

# Copy new version
cp -r "$TEMP_DIR" "$INSTALL_DIR"

# Restore any preserved files if needed
# (Add logic here to restore specific configs if necessary)

echo -e "${GREEN}Files updated${NC}"

# ============================================================================
# 4. Set Permissions
# ============================================================================

echo -e "${BLUE}Setting permissions...${NC}"

chmod +x "$INSTALL_DIR/bootstrap/bootstrap.sh"
chmod +x "$INSTALL_DIR/bootstrap/post-bootstrap-check.sh"
chmod +x "$INSTALL_DIR/scripts"/*.sh
chmod +x "$INSTALL_DIR/config/flatpak/overrides.sh"

echo -e "${GREEN}Permissions set${NC}"

# ============================================================================
# 5. Reload Systemd Service
# ============================================================================

echo -e "${BLUE}Reloading systemd service...${NC}"

# Update User in service file if needed
CURRENT_USER="${SUDO_USER:-$USER}"
if [ "$CURRENT_USER" != "gamer" ]; then
    sed -i "s/User=gamer/User=$CURRENT_USER/" "$INSTALL_DIR/bootstrap/bootstrap.service"
fi

cp "$INSTALL_DIR/bootstrap/bootstrap.service" /etc/systemd/system/
systemctl daemon-reload

echo -e "${GREEN}Systemd service reloaded${NC}"

# ============================================================================
# 6. Cleanup
# ============================================================================

echo -e "${BLUE}Cleaning up...${NC}"

rm -rf "$TEMP_DIR"
rm -rf "$INSTALL_DIR.old"

echo -e "${GREEN}Cleanup complete${NC}"

# ============================================================================
# Done
# ============================================================================

echo ""
echo -e "${GREEN}========================================"
echo "Update Complete!"
echo -e "========================================${NC}"
echo ""
echo "Changes will take effect on next boot."
echo "To apply changes immediately, run:"
echo "  sudo systemctl restart bootstrap.service"
echo ""
echo "Or manually run:"
echo "  sudo -u $CURRENT_USER $INSTALL_DIR/bootstrap/bootstrap.sh"
echo ""
