<div align="center">
  <img src="logo.svg" alt="macProNix Logo" width="160" />
  <h1>macProNix</h1>
  <p><b>Transform your Mac Pro "Trashcan" into a self-hosted GitHub Actions runner.</b></p>

  <p>
    <p> <a href="https://nixos.org"><img src="https://img.shields.io/badge/OS-NixOS_24.11-5277c3?style=for-the-badge&logo=nixos&logoColor=white" /></a> <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" /></a> <a href="https://tarantula.tech"><img src="https://img.shields.io/badge/Standard-ASC_1.3-firebrick?style=for-the-badge&logo=checkmarx&logoColor=white" /></a> </p> </div>
  </p>
</div>

## Quick Start

```bash
git clone https://github.com/tarantula-org/macpronix ~/macpronix
cd ~/macpronix
make install  # Auto-detects hardware and deploys
```

## What This Does

- **Zero-Touch Deployment**: Automatically extracts hardware UUIDs and configures system
- **Self-Hosted CI/CD**: Dedicated GitHub Actions runner
- **Hardware Fixes**: Resolves Broadcom WiFi conflicts, GPU throttling, thermal management
- **Mesh Networking**: Tailscale VPN with automatic NAT traversal
- **Immutable Config**: Entire system defined in code, reproducible builds

## CLI Reference

```bash
macpronix status   # Show node telemetry
macpronix sync     # Pull latest config and rebuild
macpronix help     # Command reference
```

## Adding Nodes

The system auto-scales. To add a new Mac Pro 6,1:

```bash
# On the new machine:
git clone https://github.com/tarantula-org/macpronix ~/macpronix
cd ~/macpronix
make install  # UUIDs auto-injected, no manual editing
```

## System Requirements

- **Hardware**: Apple Mac Pro (Late 2013, model 6,1)
- **Network**: Active connection during install
- **Storage**: NixOS installed with systemd-boot
- **Secrets**: GitHub runner token at `/etc/secrets/github-runner-token`