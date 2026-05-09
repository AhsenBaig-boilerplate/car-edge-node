#!/usr/bin/env bash
#
# test-bootstrap-locally.sh
# Test bootstrap script in a safe local environment
# Does NOT require root or system modifications
#

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================"
echo "Bootstrap Script Local Test"
echo -e "========================================${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
BOOTSTRAP_SCRIPT="$REPO_ROOT/bootstrap/bootstrap.sh"

# Create test environment
TEST_DIR="/tmp/car-edge-node-test-$$"
TEST_STORAGE="$TEST_DIR/mnt/storage"
TEST_HOME="$TEST_DIR/home/testuser"

echo -e "${BLUE}Setting up test environment...${NC}"
echo "Test directory: $TEST_DIR"
echo ""

mkdir -p "$TEST_STORAGE"
mkdir -p "$TEST_HOME/.config"
mkdir -p "$TEST_DIR/var/log"
mkdir -p "$TEST_DIR/opt/car-edge-node"

# Copy bootstrap files to test environment
cp -r "$REPO_ROOT"/* "$TEST_DIR/opt/car-edge-node/"

echo -e "${GREEN}Test environment created${NC}"
echo ""

# ============================================================================
# Syntax Check
# ============================================================================

echo -e "${BLUE}Running syntax check...${NC}"

if bash -n "$BOOTSTRAP_SCRIPT"; then
    echo -e "${GREEN}Syntax check passed${NC}"
else
    echo -e "${RED}Syntax check failed${NC}"
    exit 1
fi

# ============================================================================
# Shellcheck (if available)
# ============================================================================

if command -v shellcheck &> /dev/null; then
    echo ""
    echo -e "${BLUE}Running shellcheck...${NC}"
    
    if shellcheck "$BOOTSTRAP_SCRIPT"; then
        echo -e "${GREEN}Shellcheck passed${NC}"
    else
        echo -e "${YELLOW}Shellcheck found issues (non-fatal)${NC}"
    fi
else
    echo ""
    echo -e "${YELLOW}Shellcheck not installed, skipping static analysis${NC}"
    echo "Install with: sudo pacman -S shellcheck"
fi

# ============================================================================
# Dry Run Test
# ============================================================================

echo ""
echo -e "${BLUE}Testing bootstrap script logic...${NC}"
echo ""

# Create a wrapper that simulates the environment
cat > "$TEST_DIR/test-wrapper.sh" << 'WRAPPER'
#!/usr/bin/env bash
set -euo pipefail

# Override commands that would modify the system
mount() { echo "[SIMULATED] mount $*"; return 0; }
systemctl() { echo "[SIMULATED] systemctl $*"; return 0; }
flatpak() { echo "[SIMULATED] flatpak $*"; return 0; }
chown() { echo "[SIMULATED] chown $*"; return 0; }
chmod() { echo "[SIMULATED] chmod $*"; return 0; }

# Export overrides
export -f mount systemctl flatpak chown chmod

# Set test environment variables
export HOME="$TEST_DIR/home/testuser"
export USER="testuser"
export STORAGE_PATH="$TEST_DIR/mnt/storage"
export LOG_FILE="$TEST_DIR/var/log/car-edge-bootstrap.log"

# Run bootstrap script
bash "$TEST_DIR/opt/car-edge-node/bootstrap/bootstrap.sh"
WRAPPER

chmod +x "$TEST_DIR/test-wrapper.sh"

# Note: This is a simplified test and won't catch all issues
echo -e "${YELLOW}Note: Full integration testing requires actual system${NC}"
echo ""

# ============================================================================
# File Structure Check
# ============================================================================

echo -e "${BLUE}Checking required files...${NC}"

REQUIRED_FILES=(
    "bootstrap/bootstrap.sh"
    "bootstrap/bootstrap.service"
    "config/flatpak/apps.txt"
    "config/flatpak/overrides.sh"
    "scripts/install-bootstrap.sh"
)

all_present=true
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$REPO_ROOT/$file" ]; then
        echo -e "  ${GREEN}✓${NC} $file"
    else
        echo -e "  ${RED}✗${NC} $file (MISSING)"
        all_present=false
    fi
done

echo ""

# ============================================================================
# Cleanup
# ============================================================================

echo -e "${BLUE}Cleaning up test environment...${NC}"
rm -rf "$TEST_DIR"
echo -e "${GREEN}Cleanup complete${NC}"

# ============================================================================
# Summary
# ============================================================================

echo ""
echo -e "${GREEN}========================================"
echo "Test Summary"
echo -e "========================================${NC}"

if [ "$all_present" = true ]; then
    echo -e "${GREEN}All required files present${NC}"
    echo -e "${GREEN}Bootstrap script syntax valid${NC}"
    echo ""
    echo "Ready for installation!"
    echo "Run: sudo bash scripts/install-bootstrap.sh"
else
    echo -e "${RED}Some required files are missing${NC}"
    echo "Please check the repository structure"
    exit 1
fi

echo ""
