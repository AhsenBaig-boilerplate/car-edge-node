#!/usr/bin/env bash
#
# sync-repo-to-storage.sh
# Manually sync the car-edge-node repository to persistent storage
# for offline restore capability
#

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

STORAGE_PATH="/mnt/storage"
REPO_STORAGE_PATH="$STORAGE_PATH/car-edge-node-repo"
REPO_URL="https://github.com/ahsenbaig-boilerplate/car-edge-node.git"

echo -e "${BLUE}========================================"
echo "Sync Repository to Storage"
echo -e "========================================${NC}"
echo ""

# Check if storage is mounted
if ! mountpoint -q "$STORAGE_PATH"; then
    echo -e "${RED}Error: Storage partition not mounted at $STORAGE_PATH${NC}"
    echo "Mount it first:"
    echo "  sudo mkdir -p $STORAGE_PATH"
    echo "  sudo mount /dev/sdXN $STORAGE_PATH"
    exit 1
fi

echo -e "${BLUE}Storage: $STORAGE_PATH${NC}"
echo -e "${BLUE}Repo URL: $REPO_URL${NC}"
echo ""

# Check if repository exists
if [ -d "$REPO_STORAGE_PATH/.git" ]; then
    echo -e "${BLUE}Repository exists, pulling latest changes...${NC}"
    cd "$REPO_STORAGE_PATH"
    
    if git pull origin main; then
        echo ""
        echo -e "${GREEN}✓ Repository updated successfully${NC}"
        echo ""
        git log -1 --pretty=format:"Latest commit: %h - %s (%ar)%n"
    else
        echo ""
        echo -e "${RED}✗ Failed to update repository${NC}"
        echo "Check your internet connection or repository access."
        exit 1
    fi
else
    echo -e "${BLUE}Cloning repository for the first time...${NC}"
    
    if git clone "$REPO_URL" "$REPO_STORAGE_PATH"; then
        echo ""
        echo -e "${GREEN}✓ Repository cloned successfully${NC}"
        echo ""
        cd "$REPO_STORAGE_PATH"
        git log -1 --pretty=format:"Latest commit: %h - %s (%ar)%n"
    else
        echo ""
        echo -e "${RED}✗ Failed to clone repository${NC}"
        echo "Check your internet connection or repository access."
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}========================================"
echo "Sync Complete"
echo -e "========================================${NC}"
echo ""
echo "You can now restore offline using:"
echo "  sudo bash $REPO_STORAGE_PATH/scripts/install-bootstrap.sh"
echo ""
