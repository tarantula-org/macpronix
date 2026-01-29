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
  boot.kernelModules = [ "wl" "applesmc" "coretemp" ];
  boot.blacklistedKernelModules = [ "b43" "bcma" ];
  boot.kernelParams = [ "radeon.dpm=0" ];
  services.mbpfan.enable = true;

  # 2. SYSTEM ARCHITECTURE
  # --------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "trashcan";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

  # Remote Access (Tailscale) & Firewall Safety
  services.tailscale.enable = true;
  
  networking.firewall = {
    enable = true;
    # TRUST TAILSCALE: This prevents "Connection Timed Out" on reboot
    trustedInterfaces = [ "tailscale0" ];
    allowedTCPPorts = [ 22 ];
  };

  # Headless Access (SSH)
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

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

  # 4. USER IDENTITY (Default Admin)
  # --------------------------------------------------
  users.users.admin = {
    isNormalUser = true;
    description = "Node Admin";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # 5. LOCALIZATION (Server Standard)
  # --------------------------------------------------
  # UTC is recommended for servers to keep logs consistent.
  # Change to "Europe/Madrid" if you prefer local time.
  time.timeZone = "UTC"; 
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "24.11";

  # 6. GITHUB RUNNER (Tarantula Org)
  # --------------------------------------------------
  services.github-runners = {
    trashcan-worker = {
      enable = true;
      # Points to the Organization root
      url = "https://github.com/tarantula-org"; 
      tokenFile = "/etc/secrets/github-runner-token";
      replace = true;
      extraPackages = with pkgs; [ git docker nodejs ];
    };
  };
}