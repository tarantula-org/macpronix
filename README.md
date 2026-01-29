<div align="center">
  <img src="./logo.svg" alt="Macpronix Logo" width="150" />
  <br />
  <h1>Macpronix</h1>
  **The Trashcan Build Node**
  <br />
  <br />
  <img src="https://img.shields.io/badge/License-MIT-brightgreen?style=for-the-badge&logo=opensourceinitiative&logoColor=white" alt="License" />
  <img src="https://img.shields.io/badge/OS-NixOS_24.11-5277c3?style=for-the-badge&logo=nixos&logoColor=white" alt="NixOS" />
  <img src="https://img.shields.io/badge/Hardware-Intel_Xeon_E5-0071C5?style=for-the-badge&logo=intel&logoColor=white" alt="Hardware" />
</div>

<br />

## <img src="https://cdn.simpleicons.org/blueprint/5a5d7c" width="24" style="vertical-align: bottom;" /> Overview

**Macpronix** is a declarative NixOS flake designed to repurpose the **Apple Mac Pro (Late 2013)** into a headless CI/CD build node. 

It specifically targets the proprietary hardware quirks of the "Trashcan" architecture (Broadcom Wi-Fi, Thermal Sensors, Dual FirePro GPUs) while enforcing a strict, reproducible immutable system state.

## <img src="https://cdn.simpleicons.org/polywork/5a5d7c" width="24" style="vertical-align: bottom;" /> Infrastructure

The node functions via three core configuration modules:

| Component | Stack | Responsibility |
| :--- | :--- | :--- |
| **Kernel** | <img src="https://img.shields.io/badge/Broadcom-Drivers-red?style=flat&logo=broadcom&logoColor=white" height="20" /> | Handles `wl` module injection and Fan Control (`mbpfan`) for the 6,1 thermal core. |
| **Network** | <img src="https://img.shields.io/badge/Tailscale-Mesh_VPN-black?style=flat&logo=tailscale&logoColor=white" height="20" /> | Secure, zero-config tunneling to expose services without port forwarding. |
| **Automation** | <img src="https://img.shields.io/badge/GitHub_Actions-Runner-2088ff?style=flat&logo=githubactions&logoColor=white" height="20" /> | Self-hosted runner for compiling Rust/C artifacts on bare metal. |

## <img src="https://cdn.simpleicons.org/nixos/5a5d7c" width="24" style="vertical-align: bottom;" /> Deploy

**On the Trashcan:**

```bash
# 1. Clone the flake
git clone https://github.com/tarantula-tech/macpronix ~/macpronix

# 2. Rebuild the system
sudo nixos-rebuild switch --flake ~/macpronix#trashcan
```<div align="center">

  <img src="./logo.svg" alt="Macpronix Logo" width="120" />

  <br />

  <h1>Macpronix</h1>
   
  **The Trashcan Build Node**

  <br />
  <br />

  <img src="https://img.shields.io/badge/License-MIT-brightgreen?style=for-the-badge&logo=opensourceinitiative&logoColor=white" alt="License" />
  <img src="https://img.shields.io/badge/OS-NixOS_24.05-5277c3?style=for-the-badge&logo=nixos&logoColor=white" alt="NixOS" />
  <img src="https://img.shields.io/badge/Hardware-Mac_Pro_6,1-black?style=for-the-badge&logo=apple&logoColor=white" alt="Hardware" />

</div>

<br />

## <img src="https://cdn.simpleicons.org/blueprint/5a5d7c" width="24" style="vertical-align: bottom;" /> Overview

**Macpronix** is a declarative NixOS flake designed to repurpose the **Apple Mac Pro (Late 2013)** into a headless CI/CD build node and self-hosted cloud. 

It specifically targets the proprietary hardware quirks of the "Trashcan" architecture (Broadcom Wi-Fi, Thermal Sensors, Thunderbolt 2) to ensure a stable, bare-metal server environment without macOS overhead.

## <img src="https://cdn.simpleicons.org/polywork/5a5d7c" width="24" style="vertical-align: bottom;" /> Architecture

The system is composed of three non-overlapping modules:

| Component | Stack | Responsibility |
| :--- | :--- | :--- |
| **Kernel** | <img src="https://img.shields.io/badge/Apple_Silicon-Hardware-333333?style=flat&logo=apple&logoColor=white" height="20" /> | Hardware support for `macpro6,1` (Broadcom STA drivers, CPU Microcode). |
| **Network** | <img src="https://img.shields.io/badge/Tailscale-Mesh_VPN-black?style=flat&logo=tailscale&logoColor=white" height="20" /> | Secure, zero-config tunneling (Funnel) to expose services without port forwarding. |
| **Automation** | <img src="https://img.shields.io/badge/GitHub_Actions-Runner-2088ff?style=flat&logo=githubactions&logoColor=white" height="20" /> | Self-hosted runner for compiling Rust/C artifacts on bare metal. |

## <img src="https://cdn.simpleicons.org/filezilla/5a5d7c" width="24" style="vertical-align: bottom;" /> Repository Structure

```text
macpronix/
├── flake.nix             # Entry point & Inputs (NixOS 24.05)
├── flake.lock            # Dependency pinning
├── README.md             # Documentation
└── hosts/
    └── trashcan/         # Host: Mac Pro 6,1
        ├── default.nix   # System Configuration & Services
        └── hardware.nix  # Generated Hardware Scan (Filesystems/Boot)

```

## <img src="https://cdn.simpleicons.org/nixos/5a5d7c" width="24" style="vertical-align: bottom;" /> Deploy

**Prerequisite:** A fresh NixOS minimal install.

```bash
# 1. Clone the flake to /etc/nixos
git clone https://github.com/tarantula-org/macpronix /etc/nixos

# 2. Rebuild the system using the 'trashcan' output
sudo nixos-rebuild switch --flake .#trashcan
```
