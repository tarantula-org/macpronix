{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ 
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # --- [ STAGE 1 & KERNEL ] ---
  # Standardized Stage 1 Blacklist to prevent Broadcom driver collisions
  boot.kernelParams = [ "modprobe.blacklist=b43,bcma,ssb,brcmsmac,b43legacy" ];
  
  # Load the proprietary driver into the initrd for early initialization
  boot.initrd.kernelModules = [ "wl" ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  
  # Inject the Broadcom STA driver into the kernel package
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.kernelModules = [ "kvm-intel" "wl" "applesmc" "coretemp" ];

  # --- [ STORAGE (VERIFIED UUIDs) ] ---
  # These match your hardware scan exactly
  fileSystems."/" = { 
    device = "/dev/disk/by-uuid/c1aa063d-0726-4035-869f-3eee148ade07";
    fsType = "ext4";
  };

  fileSystems."/boot" = { 
    device = "/dev/disk/by-uuid/9AE4-F6D8";
    fsType = "vfat";
    # Use automount to prevent boot hangs during macpronix sync
    options = [ "fmask=0022" "dmask=0022" "noauto" "x-systemd.automount" ];
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/df519fab-823c-456b-ba11-a1a95282b514"; } ];

  # --- [ SYSTEM CONFIG ] ---
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableAllFirmware = true;
}