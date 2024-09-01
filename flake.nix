{
	description = "Home manager flake";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		home-manager = {
			url = "github:nix-community/home-manager/master";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};
	
	outputs = {self, nixpkgs, home-manager, ...}: 
	let
		nixLib = nixpkgs.lib;
		homeMgrLib = home-manager.lib;
		system = "x86_64-linux";
		pkgs = nixpkgs.legacyPackages.${system};
		homeCfg = homeMgrLib.homeManagerConfiguration;

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