{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ 
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # ==========================================
  # MAC PRO 6,1 HARDWARE CONFIGURATION
  # ==========================================
  # This file contains ALL hardware-specific boot configs.
  # DO NOT duplicate these settings in default.nix.

  # --- [ STAGE 1: KERNEL PARAMETERS ] ---
  # CRITICAL: Blacklist ALL conflicting Broadcom drivers at kernel level
  # This prevents the open-source drivers from racing with the proprietary wl driver
  boot.kernelParams = [ 
    "modprobe.blacklist=b43,bcma,ssb,brcmsmac,b43legacy"
    "radeon.dpm=0"  # Disable Radeon power management to prevent GPU throttling
  ];
  
  # --- [ STAGE 1: INITRD ] ---
  # Load the proprietary Broadcom driver EARLY in initrd
  boot.initrd.kernelModules = [ "wl" ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  
  # --- [ KERNEL MODULES ] ---
  # Inject the Broadcom STA driver package
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  
  # Load required kernel modules
  # wl: Broadcom proprietary WiFi driver
  # applesmc: Apple System Management Controller (fans, sensors)
  # coretemp: Intel CPU temperature monitoring
  # kvm-intel: Intel virtualization support
  boot.kernelModules = [ "kvm-intel" "wl" "applesmc" "coretemp" ];

  # --- [ FILESYSTEM: UUID-PINNED ] ---
  # CRITICAL: Use UUIDs to prevent Stage 1 mount failures
  # These UUIDs are verified for the Trashcan fleet
  fileSystems."/" = { 
    device = "/dev/disk/by-uuid/c1aa063d-0726-4035-869f-3eee148ade07";
    fsType = "ext4";
  };

  # CRITICAL: Use automount for /boot to prevent rebuild hangs
  # The "noauto" + "x-systemd.automount" combo ensures the EFI partition
  # is mounted on-demand and won't block the boot process if busy
  fileSystems."/boot" = { 
    device = "/dev/disk/by-uuid/9AE4-F6D8";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" "noauto" "x-systemd.automount" ];
  };

  swapDevices = [ 
    { device = "/dev/disk/by-uuid/df519fab-823c-456b-ba11-a1a95282b514"; } 
  ];

  # --- [ SYSTEM PLATFORM ] ---
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  
  # --- [ FIRMWARE ] ---
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableAllFirmware = true;
}
