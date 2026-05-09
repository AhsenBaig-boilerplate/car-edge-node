#!/usr/bin/env bash
#
# bootstrap.sh
# Car Edge Node Bootstrap Script
# Runs on every boot via bootstrap.service
# Idempotent - safe to re-run
#

set -euo pipefail

LOG_FILE="/var/log/car-edge-bootstrap.log"
STORAGE_PATH="/mnt/storage"
FIRST_BOOT_FLAG="/etc/car-edge-first-boot"
BOOTSTRAP_DIR="/opt/car-edge-node/bootstrap"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

error() {
    log "ERROR: $*"
    exit 1
}

log "========================================"
log "Car Edge Node Bootstrap Starting"
log "========================================"

# Check if this is first boot
if [ -f "$FIRST_BOOT_FLAG" ]; then
    FIRST_BOOT=true
    log "First boot detected"
else
    FIRST_BOOT=false
    log "Subsequent boot detected"
fi

# ============================================================================
# 1. Mount Storage Partition
# ============================================================================

log "Checking storage partition..."

if ! mountpoint -q "$STORAGE_PATH"; then
    log "Mounting storage partition..."
    mkdir -p "$STORAGE_PATH"
    
    if mount -a; then
        log "Storage mounted successfully"
    else
        error "Failed to mount storage partition"
    fi
else
    log "Storage already mounted"
fi

# ============================================================================
# 2. Create Storage Directory Structure
# ============================================================================

log "Setting up storage directory structure..."

mkdir -p "$STORAGE_PATH"/{media,games,minecraft,context,config,backups}
mkdir -p "$STORAGE_PATH/config"/{syncthing,wireguard,flatpak,steam}

log "Directory structure created"

# ============================================================================
# 2.5. Sync Repository to Storage for Offline Restore
# ============================================================================

log "Syncing car-edge-node repository to storage for offline restore..."

REPO_STORAGE_PATH="$STORAGE_PATH/car-edge-node-repo"
REPO_URL="https://github.com/ahsenbaig-boilerplate/car-edge-node.git"

if [ -d "$REPO_STORAGE_PATH/.git" ]; then
    log "Repository exists, pulling latest changes..."
    cd "$REPO_STORAGE_PATH"
    if git pull origin main &>/dev/null; then
        log "Repository updated successfully"
    else
        log "Warning: Could not update repository (offline or no changes)"
    fi
    cd - &>/dev/null
else
    log "Cloning repository for offline restore..."
    if git clone "$REPO_URL" "$REPO_STORAGE_PATH" &>/dev/null; then
        log "Repository cloned successfully"
    else
        log "Warning: Could not clone repository (offline?). Will retry on next boot."
    fi
fi

# ============================================================================
# 3. Install/Update Flatpaks
# ============================================================================

if [ "$FIRST_BOOT" = true ]; then
    log "Installing Flatpak applications..."
    
    # Add Flathub repo if not present
    if ! flatpak remote-list | grep -q flathub; then
        log "Adding Flathub repository..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi
    
    # Read apps from config file
    if [ -f "$BOOTSTRAP_DIR/../config/flatpak/apps.txt" ]; then
        while IFS= read -r app; do
            # Skip comments and empty lines
            [[ "$app" =~ ^#.*$ ]] && continue
            [[ -z "$app" ]] && continue
            
            log "Installing $app..."
            flatpak install -y flathub "$app" || log "Warning: Failed to install $app"
        done < "$BOOTSTRAP_DIR/../config/flatpak/apps.txt"
    fi
    
    # Apply Flatpak overrides
    if [ -f "$BOOTSTRAP_DIR/../config/flatpak/overrides.sh" ]; then
        log "Applying Flatpak overrides..."
        bash "$BOOTSTRAP_DIR/../config/flatpak/overrides.sh"
    fi
else
    log "Skipping Flatpak installation (not first boot)"
fi

# ============================================================================
# 4. Configure Syncthing
# ============================================================================

log "Configuring Syncthing..."

SYNCTHING_CONFIG_DIR="$HOME/.config/syncthing"
mkdir -p "$SYNCTHING_CONFIG_DIR"

if [ ! -f "$SYNCTHING_CONFIG_DIR/config.xml" ]; then
    if [ -f "$STORAGE_PATH/config/syncthing/config.xml" ]; then
        log "Restoring Syncthing config from storage..."
        cp "$STORAGE_PATH/config/syncthing/config.xml" "$SYNCTHING_CONFIG_DIR/"
    elif [ -f "$BOOTSTRAP_DIR/../config/syncthing/config-template.json" ]; then
        log "Using Syncthing template (manual configuration required)"
    fi
fi

# Enable Syncthing service for user
if ! systemctl --user is-enabled syncthing.service &>/dev/null; then
    log "Enabling Syncthing service..."
    systemctl --user enable syncthing.service
    systemctl --user start syncthing.service
else
    log "Syncthing service already enabled"
fi

# ============================================================================
# 5. Configure WireGuard
# ============================================================================

log "Configuring WireGuard..."

if [ -f "$STORAGE_PATH/config/wireguard/wg0.conf" ]; then
    log "Restoring WireGuard config from storage..."
    sudo cp "$STORAGE_PATH/config/wireguard/wg0.conf" /etc/wireguard/
    sudo chmod 600 /etc/wireguard/wg0.conf
    
    if ! systemctl is-enabled wg-quick@wg0.service &>/dev/null; then
        log "Enabling WireGuard service..."
        sudo systemctl enable wg-quick@wg0.service
        sudo systemctl start wg-quick@wg0.service
    fi
else
    log "WireGuard config not found (manual setup required)"
fi

# ============================================================================
# 6. Configure Steam Library Paths
# ============================================================================

log "Configuring Steam library paths..."

STEAM_LIBRARY_PATH="$STORAGE_PATH/games/steam"
mkdir -p "$STEAM_LIBRARY_PATH"

log "Steam library path ready: $STEAM_LIBRARY_PATH"
log "Add this path in Steam Settings > Storage"

# ============================================================================
# 7. Set Permissions
# ============================================================================

log "Setting permissions..."

chown -R "$USER:$USER" "$STORAGE_PATH"
chmod -R u+rwX,go+rX "$STORAGE_PATH"

log "Permissions set"

# ============================================================================
# 8. Mark First Boot Complete
# ============================================================================

if [ "$FIRST_BOOT" = true ]; then
    log "Marking first boot as complete..."
    sudo rm -f "$FIRST_BOOT_FLAG"
fi

# ============================================================================
# Done
# ============================================================================

log "========================================"
log "Car Edge Node Bootstrap Complete"
log "========================================"

exit 0
