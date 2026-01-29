{
  description = "Macpronix // The Trashcan Node";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations = {
      
      trashcan = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # The Universal Logic
          ./hosts/trashcan/default.nix
          
          # The Specific Disk UUIDs (Must exist on the machine)
          ./hosts/trashcan/hardware.nix
        ];
      };
      
    };
  };
}