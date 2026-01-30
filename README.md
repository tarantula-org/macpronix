<div align="center">
  <img src="logo.svg" alt="Macpronix Logo" width="160" />
  <h1>macProNix</h1>
  <p><b>Industrial Infrastructure for the Late 2013 Mac Pro</b></p>
  
  <p>
    <a href="https://nixos.org"><img src="https://img.shields.io/badge/OS-NixOS_24.11-5277c3?style=for-the-badge&logo=nixos&logoColor=white" /></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" /></a>
    <a href="https://tarantula.tech"><img src="https://img.shields.io/badge/Standard-ASC_1.3-firebrick?style=for-the-badge&logo=checkmarx&logoColor=white" /></a>
  </p>
</div>

## Overview

**Macpronix** transforms the "Trashcan" Mac Pro (6,1) into a dedicated, self-hosted GitHub Actions Worker. The system is declarative, immutable, and purpose-built for the **Tarantula** ecosystem.

## Architecture

| Component | Stack | Responsibility |
| :--- | :--- | :--- |
| **Kernel** | <img src="https://img.shields.io/badge/Broadcom-Drivers-red?style=flat&logo=broadcom&logoColor=white" height="20" /> | Proprietary 6,1 hardware support (`wl` drivers, thermals). |
| **Network** | <img src="https://img.shields.io/badge/NetworkManager-WPA_Supplicant-black?style=flat&logo=linux&logoColor=white" height="20" /> | Legacy backend support for stable BCM4360 connectivity. |
| **Cluster** | <img src="https://img.shields.io/badge/Tailscale-Mesh-white?style=flat&logo=tailscale&logoColor=black" height="20" /> | Zero-config mesh networking for headless management. |

## Interface

The node is managed via `macpronix`, a compiled CLI tool that abstracts NixOS rebuilds and enforces git state integrity.

```text
   __  __          _____ _____  _____   ____  _   _ _______   __
  |  \/  |   /\   / ____|  __ \|  __ \ / __ \| \ | |_   _\ \ / /
  | \  / |  /  \ | |    | |__) | |__) | |  | |  \| | | |  \ V / 
  | |\/| | / /\ \| |    |  ___/|  _  /| |  | | . ` | | |   > <  
  | |  | |/ ____ \ |____| |    | | \ \| |__| | |\  |_| |_ / . \ 
  |_|  |_/_/    \_\_____|_|    |_|  \_\\____/|_| \_|_____/_/ \_\

   :: CLUSTER CONTROLLER ::   v5.1.0
```

## Governance

**ASC-1.3 Tier-1 Physical Integrity.**

* **Local Execution:** CI pipelines run physically on the node.
* **Integrity Gate:** PRs require a successful hardware build to permit merging.

## Deployment

**1. Bootstrap**

```bash
git clone https://github.com/tarantula-org/macpronix ~/macpronix
cd ~/macpronix
make install
```

**2. Maintenance**

Update the configuration remotely, then sync the node:

```bash
macpronix sync
```