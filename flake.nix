{
  description = "Macpronix // The Trashcan Node";

  inputs = {
    # Stable NixOS 24.11 (The current reliable standard)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # Community Hardware Library
    # Critical for Mac Pro 6,1: Handles Broadcom Wi-Fi & Fan Sensors automatically
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixos-hardware, ... }: {
    nixosConfigurations = {
      
      # Hostname: "trashcan"
      trashcan = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # 1. Hardware Quirks (The "Magic" Fix)
          nixos-hardware.nixosModules.apple-macpro-6-1
          
          # 2. Main Configuration
          ./hosts/trashcan/default.nix

          # 3. Hardware Scan (Your disk UUIDs)
          ./hosts/trashcan/hardware.nix
        ];
      };
      
    };
  };
}
