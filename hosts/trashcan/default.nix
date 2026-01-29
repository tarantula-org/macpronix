{ config, pkgs, ... }:

{
  # ==========================================
  # UNIVERSAL MAC PRO 6,1 CONFIGURATION
  # ==========================================

  # 1. HARDWARE QUIRKS (Model Specific, Unit Agnostic)
  # --------------------------------------------------
  # Fix Broadcom Wi-Fi (The "Catch-22" bypass)
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.12.67"
  ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.kernelModules = [ "wl" ];
  boot.blacklistedKernelModules = [ "b43" "bcma" ];

  # Fix Thermal Core (The Trashcan Fan Curve)
  services.mbpfan.enable = true;
  services.mbpfan.settings = {
    general = {
      min_fan_speed = 2000; # Keep it breathing
      max_fan_speed = 6000;
      low_temp = 60;
      high_temp = 85;
    };
  };

  # 2. SYSTEM ARCHITECTURE
  # --------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  networking.hostName = "trashcan"; 
  networking.networkmanager.enable = true;
  services.tailscale.enable = true; # Remote Access

  # Headless Access (SSH)
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true; 
    };
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  # 3. MAINTENANCE & PACKAGES
  # --------------------------------------------------
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    vim git htop btop pciutils lm_sensors fastfetch
  ];

  # 4. USER IDENTITY
  # --------------------------------------------------
  users.users.admin = {
    isNormalUser = true;
    description = "Node Admin";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # 5. LOCALIZATION
  # --------------------------------------------------
  time.timeZone = "Europe/Madrid";
  i18n.defaultLocale = "en_US.UTF-8";
  
  system.stateVersion = "24.11"; 
}