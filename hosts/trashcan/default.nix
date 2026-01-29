{ config, pkgs, ... }:

{
  # --- BOOT & KERNEL ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Allow proprietary software (Required for Broadcom Wi-Fi firmware)
  nixpkgs.config.allowUnfree = true;

  # --- NETWORKING ---
  networking.hostName = "trashcan"; 
  networking.networkmanager.enable = true;

  # Tailscale: The mesh VPN for remote access
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

  # --- THERMAL CONTROL (Crucial for 6,1) ---
  # The "Trashcan" has a single fan cooling both GPUs and CPU. 
  # We tune it to be aggressive to prevent thermal throttling during compilation.
  services.mbpfan.enable = true;
  services.mbpfan.settings = {
    general = {
      min_fan_speed = 2000; # Slightly higher baseline for server longevity
      max_fan_speed = 6000;
    };
  };

  # --- SYSTEM MAINTENANCE ---
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # --- USERS ---
  # Keeping the generic 'admin' user
  users.users.admin = {
    isNormalUser = true;
    description = "Node Administrator";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # --- PACKAGES ---
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    btop       # Better resource monitor
    pciutils   # lspci
    lm_sensors # Check temps
    fastfetch  # System info
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
