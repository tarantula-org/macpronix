{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ 
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # ==========================================
  # MAC PRO 6,1 HARDWARE CONFIGURATION
  # ==========================================

  # --- [ STAGE 1: KERNEL PARAMETERS ] ---
  # CRITICAL: Blacklist ALL conflicting Broadcom drivers to prevent deadlock
  boot.kernelParams = [ 
    "modprobe.blacklist=b43,bcma,ssb,brcmsmac,b43legacy"
    "radeon.dpm=0" 
  ];

  # --- [ STAGE 1: INITRD ] ---
  # Load proprietary driver EARLY
  boot.initrd.kernelModules = [ "wl" ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  
  # --- [ KERNEL MODULES ] ---
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.kernelModules = [ "kvm-intel" "wl" "applesmc" "coretemp" ];

  # --- [ FILESYSTEM: AUTO-INJECTED ] ---
  # The Makefile replaces these tags with the Silicon Truth from the active system.
  
  fileSystems."/" = { 
    device = "/dev/disk/by-uuid/@ROOT_UUID@";
    fsType = "ext4";
  };

  fileSystems."/boot" = { 
    device = "/dev/disk/by-uuid/@BOOT_UUID@";
    fsType = "vfat";
    # Dead Man's Switch: Prevent boot hang if EFI is busy
    options = [ "fmask=0022" "dmask=0022" "noauto" "x-systemd.automount" ];
  };

  swapDevices = [ 
    { device = "/dev/disk/by-uuid/@SWAP_UUID@"; } 
  ];

  # --- [ PLATFORM ] ---
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableAllFirmware = true;
}