#!/usr/bin/env bash
set -e

# MACPRONIX INSTALLER
# Logic: "Use the Repo" + "Inject Local Hardware"

# 1. DEFINE PATHS
REPO_ROOT="$(pwd)"
HARDWARE_SRC="/etc/nixos/hardware-configuration.nix"
HARDWARE_DEST="./hosts/trashcan/hardware.nix"

echo ":: INITIALIZING TRASHCAN NODE ::"

# 2. CHECK CONTEXT
if [ ! -f "$REPO_ROOT/flake.nix" ]; then
    echo "!! Error: Script must be run from the root of the macpronix repository."
    exit 1
fi

# 3. INJECT HARDWARE IDENTITY
# We steal the UUIDs from the machine's current state and inject them into the flake.
if [ -f "$HARDWARE_SRC" ]; then
    echo "[*] cloning hardware fingerprint from $HARDWARE_SRC..."
    cp "$HARDWARE_SRC" "$HARDWARE_DEST"
    
    # CRITICAL: Flakes ignore files unless they are tracked by git.
    # We stage the hardware file so Nix can see it during the build.
    git add "$HARDWARE_DEST"
    echo "[*] hardware.nix staged for build."
else
    echo "!! Error: $HARDWARE_SRC not found."
    echo "   Please run 'nixos-generate-config' first."
    exit 1
fi

# 4. DEPLOY
echo "[*] Building System..."
# We use --impure if needed, but standard hardware.nix should be pure enough.
# Added connect-timeout to help with the Broadcom bootstrap issues.
sudo nixos-rebuild switch --flake .#trashcan --option connect-timeout 20

echo ""
echo ":: SYSTEM DEPLOYED ::"
echo "   reboot to finalize."