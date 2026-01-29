{
  description = "Macpronix // The Trashcan Node";

  inputs = {
    # Stable for the core system (Safe)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    
    # Unstable for the GitHub Runner (Bleeding Edge)
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }: {
    nixosConfigurations = {
      trashcan = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        
        # This passes the unstable package set into your modules
        specialArgs = {
          pkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };

        modules = [
          ./hosts/trashcan/default.nix
          ./hosts/trashcan/hardware.nix
        ];
      };
    };
  };
}