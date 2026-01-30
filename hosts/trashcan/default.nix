{ config, pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./runner.nix
  ];

  # ==========================================
  # UNIVERSAL MAC PRO 6,1 CONFIGURATION
  # ==========================================
  # This file contains OS-level configs ONLY.
  # Hardware-specific boot configs are in hardware.nix.

  # 1. SYSTEM PERMISSIONS
  # --------------------------------------------------
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.12.67"
  ];

  # 2. THERMAL MANAGEMENT
  # --------------------------------------------------
  # mbpfan: MacBook Pro fan controller for thermal management
  services.mbpfan.enable = true;

  # 3. BOOT LOADER
  # --------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # 4. NETWORKING
  # --------------------------------------------------
  networking.hostName = "trashcan";
  
  # NETWORK STACK: IWD replaces wpa_supplicant for stability
  # The Broadcom BCM4360 has packet loss issues with wpa_supplicant
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
    wifi.powersave = false;  # Disable power saving to prevent disconnects
  };
  
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

  # MESH VPN: Tailscale for zero-config cluster networking
  services.tailscale.enable = true;
  
  # FIREWALL: Minimal attack surface
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedTCPPorts = [ 22 ];  # SSH only
  };

  # SSH: Remote management
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # 5. SYSTEM MAINTENANCE
  # --------------------------------------------------
  # Automatic garbage collection to prevent disk bloat
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Enable flakes and nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # 6. SYSTEM PACKAGES
  # --------------------------------------------------
  environment.systemPackages = with pkgs; [
    # CORE UTILITIES
    git htop btop pciutils lm_sensors fastfetch neovim
    gnumake  # Required for Makefile workflows
    
    # CUSTOM CLI TOOL
    (pkgs.writeShellScriptBin "macpronix" (builtins.readFile ../../bin/macpronix))
  ];

  # 7. EDITOR CONFIGURATION
  # --------------------------------------------------
  environment.variables.EDITOR = "nvim";
  environment.variables.VISUAL = "nvim";
  
  environment.shellAliases = {
    vim = "nvim";
    vi = "nvim";
  };

  # 8. USER IDENTITY
  # --------------------------------------------------
  users.users.admin = {
    isNormalUser = true;
    description = "Node Admin";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # 9. LOCALIZATION
  # --------------------------------------------------
  time.timeZone = "UTC"; 
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "24.11";
}
