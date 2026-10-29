{
  description = "Sanitized inventory-driven Nix infrastructure example";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { nixpkgs, nix-darwin, home-manager, ... }:
    let
      inventory = import ./hosts.nix;
      mkLinux = name: host: nixpkgs.lib.nixosSystem {
        system = host.system;
        specialArgs = { inherit host; };
        modules = [
          ./modules/nixos/common.nix
          ./modules/nixos/roles.nix
          ./modules/nixos/remote-builder.nix
          ./hosts/${name}/configuration.nix
          home-manager.nixosModules.home-manager
          { home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.operator = import ./modules/home-manager/operator.nix;
          }
        ];
      };
      mkDarwin = name: host: nix-darwin.lib.darwinSystem {
        specialArgs = { inherit host; };
        modules = [
          ./modules/darwin/common.nix
          ./hosts/${name}/configuration.nix
          home-manager.darwinModules.home-manager
          { nixpkgs.hostPlatform = host.system;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.operator = import ./modules/home-manager/operator.nix;
          }
        ];
      };
    in {
      nixosConfigurations = nixpkgs.lib.mapAttrs mkLinux inventory.nixos;
      darwinConfigurations = nixpkgs.lib.mapAttrs mkDarwin inventory.darwin;
    };
}
