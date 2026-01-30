<div align="center"> <img src="logo.svg" alt="Macpronix Logo" width="160" /> <br /> <br /> <h1>macProNix</h1> <p><b>Transform your Mac Pro "Trashcan" into a self-hosted GitHub Actions runner with zero-touch deployment.</b></p>

<p> <a href="https://nixos.org"><img src="https://img.shields.io/badge/OS-NixOS_24.11-5277c3?style=for-the-badge&logo=nixos&logoColor=white" /></a> <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" /></a> <a href="https://tarantula.tech"><img src="https://img.shields.io/badge/Standard-ASC_1.3-firebrick?style=for-the-badge&logo=checkmarx&logoColor=white" /></a> </p> </div>

<br />

</div>

---

## Quick Start

```bash
git clone https://github.com/tarantula-org/macpronix ~/macpronix
cd ~/macpronix
make install  # Auto-detects hardware and deploys
```

## What This Does

- **Zero-Touch Deployment**: Automatically extracts hardware UUIDs and configures system
- **Self-Hosted CI/CD**: Dedicated GitHub Actions runner for Tarantula ecosystem
- **Hardware Fixes**: Resolves Broadcom WiFi conflicts, GPU throttling, thermal management
- **Mesh Networking**: Tailscale VPN with automatic NAT traversal
- **Immutable Config**: Entire system defined in code, reproducible builds

## Architecture

| Layer | Stack | Purpose |
|-------|-------|---------|
| **Hardware** | Mac Pro 6,1 | Late 2013 "Trashcan" (Xeon E5, Dual FirePro) |
| **Kernel** | NixOS 24.11 | Driver management (wl, radeon, applesmc) |
| **Network** | iwd + Tailscale | Stable WiFi + mesh VPN |
| **Compute** | GitHub Actions | Self-hosted runner node |

## CLI Reference

```bash
macpronix status   # Show node telemetry
macpronix sync     # Pull latest config and rebuild
macpronix help     # Command reference
```

## Adding Nodes to Fleet

The system auto-scales. To add a new Mac Pro 6,1:

```bash
# On the new machine:
git clone https://github.com/tarantula-org/macpronix ~/macpronix
cd ~/macpronix
make install  # UUIDs auto-injected, no manual editing
```

The `make install` workflow:
1. Detects hardware UUIDs from `/etc/nixos/hardware-configuration.nix`
2. Injects them into `hosts/trashcan/hardware.nix`
3. Validates flake integrity
4. Test-builds the system
5. Commits to bootloader only if successful

## System Requirements

- **Hardware**: Apple Mac Pro (Late 2013, model 6,1)
- **Network**: Active connection during install
- **Storage**: NixOS installed with systemd-boot
- **Secrets**: GitHub runner token at `/etc/secrets/github-runner-token`

## Emergency Recovery

If you hit emergency mode:

```bash
# Boot from USB, mount system
mount /dev/disk/by-uuid/YOUR-ROOT-UUID /mnt
mount /dev/disk/by-uuid/YOUR-BOOT-UUID /mnt/boot

# Fix UUIDs in config
nano /mnt/home/admin/macpronix/hosts/trashcan/hardware.nix

# Rebuild from recovery
nixos-install --root /mnt --flake /mnt/home/admin/macpronix#trashcan
```

## Governance (ASC-1.3)

This repository enforces:

- **Single Source of Truth**: Hardware configs in `hardware.nix` only, no duplication
- **Immutability**: System state is fully declarative
- **Zero-Touch**: No manual configuration file editing required
- **Physical CI**: All changes validated on actual hardware before merge

See [CONTRIBUTING.md](CONTRIBUTING.md) for full Canon.

## License

MIT - See [LICENSE](LICENSE)

## Support

- **Issues**: Use the System Anomaly template
- **Security**: Email `tarantula.tech@atomicmail.io` with `[SEC]` prefix
- **Docs**: See [SUPPORT.md](.github/SUPPORT.md)