{ config, pkgs, ... }:

{
  # --- BOOT & KERNEL ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # CRITICAL: Allow the Broadcom Wi-Fi driver despite it being end-of-life
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.12.67"
  ];

  # --- NETWORKING ---
  networking.hostName = "trashcan"; 
  networking.networkmanager.enable = true;

  # Tailscale: Mesh VPN for remote access
  services.tailscale.enable = true;

  # SSH: Enable remote access
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true; 
    };
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  # --- THERMAL CONTROL ---
  # Mac Pro 6,1 specific fan daemon. 
  services.mbpfan.enable = true;
  services.mbpfan.settings = {
    general = {
      min_fan_speed = 1900; 
      max_fan_speed = 6000;
    };
  };

  # --- MAINTENANCE ---
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # --- USERS ---
  users.users.admin = {
    isNormalUser = true;
    description = "Admin";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # --- PACKAGES ---
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    btop
    pciutils
    lm_sensors
    fastfetch
  ];

  # --- LOCALIZATION ---
  time.timeZone = "Europe/Madrid";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };

  system.stateVersion = "24.11"; 
}