{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ 
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # ==========================================
  # HARDWARE SPECIFICATION: MAC PRO 6,1
  # ==========================================

  # --- [ KERNEL & DRIVERS ] ---
  # Blacklist conflicting drivers to prevent Broadcom deadlock
  boot.kernelParams = [ 
    "modprobe.blacklist=b43,bcma,ssb,brcmsmac,b43legacy"
    "radeon.dpm=0" 
  ];

  # Early load proprietary WiFi driver
  boot.initrd.kernelModules = [ "wl" ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.kernelModules = [ "kvm-intel" "wl" "applesmc" "coretemp" ];

  # --- [ STORAGE ] ---
  # UUIDs are injected dynamically by the Makefile during deployment.
  
  fileSystems."/" = { 
    device = "/dev/disk/by-uuid/@ROOT_UUID@";
    fsType = "ext4";
  };

  fileSystems."/boot" = { 
    device = "/dev/disk/by-uuid/@BOOT_UUID@";
    fsType = "vfat";
    # Prevent boot hangs if EFI partition is busy
    options = [ "fmask=0022" "dmask=0022" "noauto" "x-systemd.automount" ];
  };

  # Swap configuration managed via injection
  swapDevices = [ 
    # @SWAP_CONFIG@
  ];

  # --- [ ARCHITECTURE ] ---
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableAllFirmware = true;
}