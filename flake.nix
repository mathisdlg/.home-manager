{
	description = "Home manager flake";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
		home-manager = {
			url = "github:nix-community/home-manager/release-24.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = {self, nixpkgs, home-manager, ...}:
	let
		nixLib = nixpkgs.lib;
		homeCfg = home-manager.lib.homeManagerConfiguration;
		system = "x86_64-linux";
		pkgs = nixpkgs.legacyPackages.${system};

	in {
		nixosConfigurations = {
			nixosMathis = nixLib.nixosSystem {
				inherit system;
				modules = [ ./system/configuration.nix ];
			};
		};
		homeConfigurations = {
			mathisdlg = homeCfg {
				inherit pkgs;
				modules = [ ./user/base/home.nix ];
			};
		};
	};
}