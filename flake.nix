{
  description = "Home manager flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      ...
    }:
    let
      nixLib = nixpkgs.lib;
      homeCfg = home-manager.lib.homeManagerConfiguration;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      unstablePkgs = nixpkgs-unstable.legacyPackages.${system};
      globals = import ./globals.nix;
    in
    {
      nixosConfigurations = {
        ${globals.hostName} = nixLib.nixosSystem {
          inherit system;
          specialArgs = { inherit globals; };
          modules = [
            ./system/configuration.nix
          ];
        };
      };

      homeConfigurations = {
        ${globals.username} = homeCfg {
          inherit pkgs;
          modules = [ 
            ./user/base/home.nix 
          ];
          extraSpecialArgs = { inherit unstablePkgs globals; };
        };
      };
    };
}
