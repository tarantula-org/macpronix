{
  description = "Macpronix // The Trashcan Node";

  inputs = {
    # NixOS 24.11 (Stable)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # Hardware Quirks
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixos-hardware, ... }: {
    nixosConfigurations = {
      
      trashcan = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # FIX: Import the hardware module by direct path since the attribute is missing
          "${nixos-hardware}/apple/macpro/6-1"

          # Main Config
          ./hosts/trashcan/default.nix
          
          # Hardware Scan
          ./hosts/trashcan/hardware.nix
        ];
      };
      
    };
  };
}