#!/usr/bin/env bash
#
# verify-storage.sh
# Verify storage partition layout and contents
#

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================"
echo "Storage Verification"
echo -e "========================================${NC}"
echo ""

STORAGE_PATH="/mnt/storage"

# ============================================================================
# Check if storage is mounted
# ============================================================================

echo -n "Storage partition mounted: "
if mountpoint -q "$STORAGE_PATH"; then
    echo -e "${GREEN}YES${NC}"
else
    echo -e "${RED}NO${NC}"
    echo ""
    echo "Storage partition is not mounted at $STORAGE_PATH"
    echo "Check /etc/fstab and run: sudo mount -a"
    exit 1
fi

# ============================================================================
# Display disk usage
# ============================================================================

echo ""
echo -e "${BLUE}Disk Usage:${NC}"
df -h "$STORAGE_PATH"

# ============================================================================
# Check directory structure
# ============================================================================

echo ""
echo -e "${BLUE}Directory Structure:${NC}"

REQUIRED_DIRS=(
    "media"
    "games"
    "games/steam"
    "minecraft"
    "context"
    "config"
    "config/syncthing"
    "config/wireguard"
    "config/flatpak"
    "config/steam"
    "backups"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    echo -n "  $dir: "
    if [ -d "$STORAGE_PATH/$dir" ]; then
        echo -e "${GREEN}EXISTS${NC}"
    else
        echo -e "${YELLOW}MISSING${NC}"
    fi
done

# ============================================================================
# Display storage breakdown
# ============================================================================

echo ""
echo -e "${BLUE}Storage Breakdown:${NC}"

if command -v du &> /dev/null; then
    du -sh "$STORAGE_PATH"/* 2>/dev/null | while read -r size path; do
        dirname=$(basename "$path")
        printf "  %-20s %s\n" "$dirname" "$size"
    done
else
    echo "  (du command not available)"
fi

# ============================================================================
# Check permissions
# ============================================================================

echo ""
echo -e "${BLUE}Permissions:${NC}"

stat_output=$(stat -c "Owner: %U:%G  Mode: %a" "$STORAGE_PATH" 2>/dev/null || stat -f "Owner: %Su:%Sg  Mode: %Lp" "$STORAGE_PATH" 2>/dev/null)
echo "  $stat_output"

# ============================================================================
# Summary
# ============================================================================

echo ""
echo -e "${GREEN}========================================"
echo "Verification Complete"
echo -e "========================================${NC}"
