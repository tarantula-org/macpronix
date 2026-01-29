{ config, pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./runner.nix
  ];

  # ==========================================
  # UNIVERSAL MAC PRO 6,1 CONFIGURATION
  # ==========================================

  # 1. HARDWARE QUIRKS
  # --------------------------------------------------
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
  
  # NETWORK REFACTOR: IWD
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
    wifi.powersave = false;
  };
  
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

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

  # 3. MAINTENANCE & PACKAGES
  # --------------------------------------------------
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    # CORE UTILITIES
    git htop btop pciutils lm_sensors fastfetch neovim
    gnumake  # <--- ADDED: Required for 'make' workflows
    
    # CUSTOM CLI TOOL
    (pkgs.writeShellScriptBin "macpronix" (builtins.readFile ../../bin/macpronix))
  ];

  # 4. EDITOR SUPREMACY
  # --------------------------------------------------
  environment.variables.EDITOR = "nvim";
  environment.variables.VISUAL = "nvim";
  
  environment.shellAliases = {
    vim = "nvim";
    vi = "nvim";
  };

  # 5. USER IDENTITY
  # --------------------------------------------------
  users.users.admin = {
    isNormalUser = true;
    description = "Node Admin";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # 6. LOCALIZATION
  # --------------------------------------------------
  time.timeZone = "UTC"; 
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "24.11";
}