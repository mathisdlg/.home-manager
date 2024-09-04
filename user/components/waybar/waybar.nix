{ config, pkgs, ... }: {
	imports = [];

	config = {
		home.packages = with pkgs; [
			jetbrains-mono
		];

		home.file = {
			".config/waybar/config".source = ./config;
            ".config/waybar/style.css".source = ./style.css;
		};
	};
}