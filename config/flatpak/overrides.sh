#!/usr/bin/env bash
#
# Flatpak Overrides
# Grant additional permissions to Flatpak apps
#

# Allow Kodi to access media storage
flatpak override --user tv.kodi.Kodi \
    --filesystem=/mnt/storage/media:ro

# Allow PrismLauncher (Minecraft) to access game storage
flatpak override --user org.prismlauncher.PrismLauncher \
    --filesystem=/mnt/storage/minecraft:rw \
    --socket=pulseaudio \
    --device=dri

# Allow Steam to access game storage
flatpak override --user com.valvesoftware.Steam \
    --filesystem=/mnt/storage/games/steam:rw

echo "Flatpak overrides applied successfully"
