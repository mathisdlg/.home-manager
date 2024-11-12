{ config, pkgs, ... }: {
	imports = [];

	config = {
		home.packages = with pkgs; [
			waybar
			jetbrains-mono
		];

		home.file = {
			".config/waybar".source = ./config;
		};
	};
}
