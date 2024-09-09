{ config, pkgs, ... }: {
	imports = [
		../background/background.nix
	];

	config = {
		home.packages = with pkgs; [
			hyprlock
		];

		home.file = {
			".config/hypr/hyprlock.conf".source = ./hyprlock.conf;
		};
	};
}