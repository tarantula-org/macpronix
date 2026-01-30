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

  # 2. SYSTEM ARCHITECTURE
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  services.mbpfan.enable = true;

  # 3. NETWORKING (Broadcom Compatibility Mode)
  networking.hostName = "trashcan";
  
  networking.networkmanager = {
    enable = true;
    # CRITICAL: 'wl' driver requires wpa_supplicant. iwd is too modern for this card.
    wifi.backend = "wpa_supplicant"; 
    wifi.powersave = false; # Prevents packet loss on Broadcom chips
  };
  
  # Disable iwd to prevent race conditions for the card
  networking.wireless.iwd.enable = false;

  services.tailscale.enable = true;

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedTCPPorts = [ 22 ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # 4. MAINTENANCE
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

  users.users.admin = {
    isNormalUser = true;
    description = "Node Admin";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  time.timeZone = "UTC"; 
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "24.11";
}