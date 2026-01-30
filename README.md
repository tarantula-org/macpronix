<div align="center">

# macProNix

**Immutable NixOS Infrastructure for the Late 2013 Mac Pro**

[![NixOS 24.11](https://img.shields.io/badge/NixOS-24.11-5277c3?style=flat-square&logo=nixos&logoColor=white)](https://nixos.org)
[![MIT License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

</div>

Transform your Mac Pro "Trashcan" into a self-hosted GitHub Actions runner with declarative, reproducible configuration.

## Quick Start

```bash
# Clone and deploy
git clone https://github.com/tarantula-org/macpronix ~/macpronix
cd ~/macpronix
make install

# Update system
macpronix sync
```

## What This Does

- **Declarative OS**: Entire system defined in code, no manual configuration
- **GitHub Actions Runner**: Self-hosted CI/CD for the Tarantula ecosystem
- **Hardware Optimization**: Fixes Broadcom WiFi issues, manages thermal/GPU quirks
- **Zero-Touch Networking**: Tailscale mesh with automatic firewall traversal
- **CLI Management**: `macpronix` tool for system operations

## Architecture

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Kernel** | NixOS 24.11 | Hardware driver management (WiFi, GPU, thermal) |
| **Network** | iwd + Tailscale | Stable WiFi (replaces wpa_supplicant) + mesh VPN |
| **Compute** | GitHub Actions | Self-hosted runner node |

## CLI Commands

```bash
macpronix sync     # Pull latest config and rebuild system
macpronix status   # Show node telemetry
macpronix help     # Full command reference
```

## System Requirements

- Apple Mac Pro (Late 2013, 6,1 model)
- Network connectivity during installation
- GitHub organization access tokens (for runner setup)

## CI/CD Integration

All changes are validated on the physical hardware before merge. Pull requests must pass on-device builds to ensure configuration integrity.

## License

MIT - See [LICENSE](LICENSE) for details.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.