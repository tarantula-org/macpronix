# Deployment Workflows
**Standard Operating Procedures for Macpronix Fleet**

## Workflow 1: Bootstrap New Node

**Objective**: Add a new Mac Pro 6,1 to the fleet with zero manual configuration.

### Prerequisites
- Mac Pro 6,1 with NixOS installed
- Network connectivity
- GitHub access configured
- Root access to the machine

### Procedure
```bash
# 1. Clone repository
git clone https://github.com/tarantula-org/macpronix ~/macpronix
cd ~/macpronix

# 2. Run bootstrap
make install

# What happens:
# - Extracts UUIDs from /etc/nixos/hardware-configuration.nix
# - Injects them into hosts/trashcan/hardware.nix
# - Validates flake integrity
# - Test-builds configuration
# - Commits to bootloader on success

# 3. Reboot
sudo reboot
```

### Verification
```bash
# After reboot:
macpronix status        # Check all systems online
macpronix check         # Run health diagnostics
journalctl -b | grep emergency  # Should be empty
```

### Rollback
If bootstrap fails, system stays on NixOS installer config. Fix errors and retry `make install`.

---

## Workflow 2: Update Existing Node

**Objective**: Pull latest configuration from GitHub and apply it.

### Procedure
```bash
# On the target node:
macpronix sync

# What happens:
# - Stashes local changes (if any)
# - Pulls latest from GitHub
# - Sanitizes line endings (CRLF → LF)
# - Test-builds new config
# - Commits to bootloader only if successful
# - Prompts for reboot

# Reboot to apply
sudo reboot
```

### Safety Net
If `macpronix sync` fails during test build, the system remains on the current working configuration. No changes are committed to the bootloader.

---

## Workflow 3: Upgrade NixOS Packages

**Objective**: Update flake.lock to pull latest nixpkgs.

### Procedure
```bash
# 1. Update flake inputs
macpronix upgrade

# What happens:
# - Runs 'nix flake update'
# - Shows diff of flake.lock
# - Test-builds upgraded config
# - Aborts if build fails

# 2. Commit the upgrade
git add flake.lock
git commit -m "chore: upgrade nixpkgs to latest"
git push

# 3. Apply across fleet
# (On each node or via SSH):
macpronix sync
```

### Best Practice
Test upgrades on a single node before pushing to production fleet.

---

## Workflow 4: Emergency Recovery

**Objective**: Recover from emergency mode boot failure.

### Scenario: Wrong UUIDs
```bash
# 1. Boot from NixOS USB installer

# 2. Mount the system
sudo blkid  # Find correct UUIDs
sudo mount /dev/disk/by-uuid/YOUR-ROOT-UUID /mnt
sudo mount /dev/disk/by-uuid/YOUR-BOOT-UUID /mnt/boot

# 3. Fix hardware.nix
nano /mnt/home/admin/macpronix/hosts/trashcan/hardware.nix
# Update the 3 UUIDs (root, boot, swap)

# 4. Reinstall from mounted system
nixos-install --root /mnt --flake /mnt/home/admin/macpronix#trashcan

# 5. Reboot
reboot
```

### Scenario: Bad Config Deployed
```bash
# 1. Reboot and access GRUB/systemd-boot menu

# 2. Select previous generation
# Use arrow keys to select "NixOS - Configuration X (previous)"

# 3. System boots with old working config

# 4. Fix the issue
cd ~/macpronix
git revert HEAD  # Or fix manually
macpronix sync
```

---

## Workflow 5: Health Check

**Objective**: Verify system is functioning correctly.

### Procedure
```bash
macpronix check

# Checks performed:
# - Flake integrity (nix flake check)
# - Broadcom driver status (lsmod | grep wl)
# - Conflicting drivers (should be none)
# - Filesystem mounts (root and boot)
```

### Expected Output
```
[INFO] Running System Health Checks...
[INFO] Checking flake integrity...
[OK]   Flake validation passed
[INFO] Checking Broadcom driver...
[OK]   wl driver loaded
[OK]   No conflicting drivers
[INFO] Checking filesystems...
[OK]   Root and boot filesystems mounted
[OK]   All checks passed
```

---

## Workflow 6: Configuration Development

**Objective**: Test changes to configuration before deploying fleet-wide.

### Procedure
```bash
# 1. Make changes locally
cd ~/macpronix
nano hosts/trashcan/default.nix

# 2. Test immediately (doesn't commit to bootloader)
sudo nixos-rebuild test --flake .#trashcan --impure

# 3. If test passes, make permanent
sudo nixos-rebuild switch --flake .#trashcan --impure

# 4. Verify system
macpronix status

# 5. If good, commit and push
git add hosts/trashcan/default.nix
git commit -m "feat: add new package to environment"
git push

# 6. Deploy to other nodes
# (via SSH or manually):
macpronix sync
```

### Testing Workflow
```
Local Edit → Test Build → Switch → Verify → Commit → Push → Fleet Sync
```

---

## Workflow 7: Adding GitHub Runner Secrets

**Objective**: Configure GitHub Actions runner token.

### Procedure
```bash
# 1. Generate token on GitHub
# Settings → Actions → Runners → New self-hosted runner
# Copy the token

# 2. Create secret file on node
sudo mkdir -p /etc/secrets
sudo nano /etc/secrets/github-runner-token
# Paste token, save

# 3. Restart runner service
sudo systemctl restart github-runner-trashcan-worker

# 4. Verify
macpronix status  # Should show "CI Runner: ● ONLINE"
```

---

## Workflow 8: Tailscale Setup

**Objective**: Connect node to mesh VPN.

### Procedure
```bash
# 1. Authenticate Tailscale
sudo tailscale up

# Follow the URL it provides to authenticate

# 2. Verify connection
tailscale status
macpronix status  # Should show Tailscale IP

# 3. Test mesh connectivity
ping <other-node-tailscale-ip>
```

---

## Workflow 9: WiFi Configuration

**Objective**: Connect to WiFi network using iwd.

### Procedure
```bash
# 1. Enter iwd interactive shell
sudo iwctl

# 2. Scan and connect
[iwd]# station wlan0 scan
[iwd]# station wlan0 get-networks
[iwd]# station wlan0 connect "YourSSID"
# Enter passphrase when prompted

# 3. Verify
[iwd]# exit
macpronix status  # Should show WiFi: ● YourSSID
```

### Persistent Configuration
iwd stores network credentials in `/var/lib/iwd/`. They persist across reboots.

---

## Workflow 10: Troubleshooting Build Failures

**Objective**: Diagnose and fix NixOS build errors.

### Common Issues

#### Issue: "error: attribute 'X' missing"
**Cause**: Typo in configuration file  
**Fix**: Check syntax in .nix files, run `nix flake check`

#### Issue: "builder for '/nix/store/...' failed"
**Cause**: Compilation error or download failure  
**Fix**: Check build logs, retry with `--show-trace`

#### Issue: "infinite recursion encountered"
**Cause**: Circular dependency in imports  
**Fix**: Review `imports = [ ]` sections, remove cycles

#### Issue: CRLF line endings
**Cause**: Windows edited files  
**Fix**: Run `make fix-windows` before any build

### Debug Commands
```bash
# Validate flake structure
nix flake check --show-trace

# Test build with verbose output
sudo nixos-rebuild test --flake .#trashcan --impure --show-trace

# Check for syntax errors
nix-instantiate --parse hosts/trashcan/default.nix
```

---

## Best Practices

### 1. Always Test Before Committing
```bash
sudo nixos-rebuild test --flake .#trashcan --impure
# If this passes, then commit
```

### 2. Use Descriptive Commit Messages
```bash
# Good:
git commit -m "fix: resolve Broadcom driver conflict in hardware.nix"

# Bad:
git commit -m "fix stuff"
```

### 3. One Logical Change Per Commit
Don't mix driver fixes with package additions.

### 4. Sanitize Before Every Operation
```bash
make fix-windows  # Always run this first
```

### 5. Reboot After Hardware Changes
Kernel module changes (drivers, boot params) require reboot to take effect.

---

## Governance Compliance

All workflows follow ASC-1.3:
- ✅ Single Source of Truth (no manual edits outside git)
- ✅ Machine-Led Verification (test before commit)
- ✅ Deterministic (reproducible builds)
- ✅ Documentation as Code (this file)

---

**Document Version**: 1.0  
**Maintainer**: @tarantula-org/core  
**Last Updated**: 2026-01-30  
**Status**: ACTIVE