#!/usr/bin/env bash
#
# post-bootstrap-check.sh
# Verify that bootstrap completed successfully
#

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "Car Edge Node Bootstrap Verification"
echo "========================================"
echo ""

checks_passed=0
checks_failed=0

check() {
    local name="$1"
    local command="$2"
    
    echo -n "Checking $name... "
    if eval "$command" &>/dev/null; then
        echo -e "${GREEN}PASS${NC}"
        ((checks_passed++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        ((checks_failed++))
        return 1
    fi
}

# Storage checks
check "Storage mounted" "mountpoint -q /mnt/storage"
check "Media directory exists" "[ -d /mnt/storage/media ]"
check "Games directory exists" "[ -d /mnt/storage/games ]"
check "Context directory exists" "[ -d /mnt/storage/context ]"

# Flatpak checks
check "Flathub repository added" "flatpak remote-list | grep -q flathub"
check "Flatpak apps installed" "flatpak list | wc -l | grep -qv '^0$'"

# Syncthing checks
check "Syncthing config exists" "[ -d ~/.config/syncthing ]"
check "Syncthing service enabled" "systemctl --user is-enabled syncthing.service"

# WireGuard checks (optional)
if [ -f /etc/wireguard/wg0.conf ]; then
    check "WireGuard config exists" "[ -f /etc/wireguard/wg0.conf ]"
    check "WireGuard service enabled" "systemctl is-enabled wg-quick@wg0.service"
else
    echo -e "WireGuard: ${YELLOW}NOT CONFIGURED${NC} (optional)"
fi

# Steam library checks
check "Steam library path exists" "[ -d /mnt/storage/games/steam ]"

# Bootstrap service checks
check "Bootstrap service exists" "systemctl list-unit-files | grep -q bootstrap.service"
check "Bootstrap log exists" "[ -f /var/log/car-edge-bootstrap.log ]"

echo ""
echo "========================================"
echo -e "Results: ${GREEN}$checks_passed passed${NC}, ${RED}$checks_failed failed${NC}"
echo "========================================"
echo ""

if [ $checks_failed -eq 0 ]; then
    echo -e "${GREEN}Bootstrap completed successfully!${NC}"
    exit 0
else
    echo -e "${RED}Some checks failed. Review logs:${NC}"
    echo "  sudo journalctl -u bootstrap.service"
    echo "  cat /var/log/car-edge-bootstrap.log"
    exit 1
fi
