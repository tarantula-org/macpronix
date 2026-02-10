{ config, pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./runner.nix
  ];

  # ==========================================
  # UNIVERSAL MAC PRO 6,1 OS LAYER
  # ==========================================

  # 1. PERMISSIONS
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.12.67"
  ];

  # 2. VIRTUALISATION [NEW]
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  # 3. SYSTEM ARCHITECTURE
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  services.mbpfan.enable = true;

  # 4. NETWORKING (Broadcom Compatibility Mode)
  networking.hostName = "trashcan";
  networking.networkmanager = {
    enable = true;
    # CRITICAL: 'wl' driver requires wpa_supplicant.
    wifi.backend = "wpa_supplicant"; 
    wifi.powersave = false;
  };
  
  # Disable iwd to prevent race conditions for the card
  networking.wireless.iwd.enable = false;
  services.tailscale.enable = true;

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" "docker0" ]; # [SEC] Trust Cluster + Containers
    allowedTCPPorts = [ 22 ];
  };

  # [SEC] Hardened SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # 5. MAINTENANCE
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    git htop btop pciutils lm_sensors fastfetch neovim gnumake
    (pkgs.writeShellScriptBin "macpronix" (builtins.readFile ../../bin/macpronix))
  ];

  environment.variables.EDITOR = "nvim";
  environment.variables.VISUAL = "nvim";
  environment.shellAliases = { vim = "nvim"; vi = "nvim"; };

  # 6. IDENTITY
  users.users.admin = {
    isNormalUser = true;
    description = "Node Admin";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    # [MODULAR] Keys are loaded from 'admin.keys' in the same directory.
    # This allows users to inject keys without altering system logic.
    openssh.authorizedKeys.keyFiles = [ ./admin.keys ];
  };

  time.timeZone = "UTC"; 
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "24.11";
}