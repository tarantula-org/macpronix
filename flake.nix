{
  description = "Macpronix // The Trashcan Fleet";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }: 
    let
      # The Builder Function
      mkMacPro = hostname: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          pkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
        modules = [
          ./hosts/trashcan/default.nix  # The shared config
          ./hosts/trashcan/hardware.nix # The shared hardware definition
          {
            networking.hostName = hostname;
          }
        ];
      };
    in {
      nixosConfigurations = {
        # Node 1 (The current one)
        trashcan = mkMacPro "trashcan";
        
        # Node 2 (Ready for expansion)
        # trashcan-02 = mkMacPro "trashcan-02";
      };
    };
}