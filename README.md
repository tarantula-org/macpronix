<div align="center">
  <img src="logo.svg" alt="Macpronix Logo" width="160" />
  <br />
  <br />
  <h1>MACPRONIX</h1>
  <p><b>Industrial Infrastructure for the Late 2013 Mac Pro</b></p>
  
  <p>
    <a href="https://nixos.org">
      <img src="https://img.shields.io/badge/OS-NixOS_24.11-5277c3?style=for-the-badge&logo=nixos&logoColor=white" />
    </a>
    <a href="LICENSE">
      <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" />
    </a>
    <a href="https://tarantula.tech">
      <img src="https://img.shields.io/badge/Standard-ASC_1.3-firebrick?style=for-the-badge&logo=checkmarx&logoColor=white" />
    </a>
  </p>
</div>

<br />

## <img src="https://cdn.simpleicons.org/blueprint/5a5d7c" width="24" style="vertical-align: bottom;" /> The Mission

**Macpronix** is an infrastructure initiative to reclaim the **Apple Mac Pro (Late 2013)** from obsolescence.

We treat the "Trashcan" architecture not as legacy hardware, but as a dense, high-core-count compute node. This project creates a **declarative, reproducible operating system** that transforms the machine into a dedicated, headless GitHub Actions worker for the **Tarantula** ecosystem.

It is **Immutable by Design**. The machine has no state; this repository is the single source of truth.

## <img src="https://cdn.simpleicons.org/polywork/5a5d7c" width="24" style="vertical-align: bottom;" /> Architecture

The system functions via three distinct, non-overlapping pillars:

| Component | Stack | Responsibility |
| :--- | :--- | :--- |
| **The Kernel** | <img src="https://img.shields.io/badge/Broadcom-Drivers-red?style=flat&logo=broadcom&logoColor=white" height="20" /> | Manages proprietary 6,1 hardware quirks (`wl` drivers, thermal sensors, `radeon` throttling). |
| **The Network** | <img src="https://img.shields.io/badge/IWD-Wireless_Daemon-black?style=flat&logo=linux&logoColor=white" height="20" /> | Replaces `wpa_supplicant` with **iwd** to eliminate packet loss on Broadcom chipsets. |
| **The Cluster** | <img src="https://img.shields.io/badge/Tailscale-Mesh_VPN-white?style=flat&logo=tailscale&logoColor=black" height="20" /> | Zero-config mesh networking and firewall hole-punching for headless management. |

## <img src="https://cdn.simpleicons.org/gnometerminal/5a5d7c" width="24" style="vertical-align: bottom;" /> The Interface

We reject loose shell scripts. The node is managed entirely through `macpronix`, a compiled CLI tool baked into the silicon. It abstracts complex NixOS rebuilds into simple, industrial commands.

```text
   :: TRASHCAN CLUSTER CONTROLLER ::   v2.1

┌──[ SYSTEM TELEMETRY ]─────────────────────────────────────┐
│ Runner Node: ● ONLINE
│ Target Org:  [https://github.com/tarantula-org](https://github.com/tarantula-org)
│
│ Tailscale:   ● ACTIVE (100.88.114.90)
│ Uplink:      ● CONNECTED (Studionet - 100% Signal)
└───────────────────────────────────────────────────────────┘

```

## <img src="https://cdn.simpleicons.org/nixos/5a5d7c" width="24" style="vertical-align: bottom;" /> Deployment

**1. Bootstrap**
Clone the repository to the target hardware.

```bash
git clone https://github.com/tarantula-org/macpronix ~/macpronix
cd ~/macpronix
```

**2. Injection**
Inject the hardware identity and build the system.

```bash
make install
```

**3. Operation**
Access the controller to manage state.

```bash
macpronix status
```