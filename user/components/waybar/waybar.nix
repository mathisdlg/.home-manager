{ config, pkgs, ... }: {
	imports = [];

	config = {
		home.packages = with pkgs; [
			waybar
			jetbrains-mono
		];

		home.file = {
			".config/waybar/config".source = ./config/config;
			".config/waybar/style.css".source = ./config/style.css;
			".config/waybar/themes/theme.css".source = ./config/theme.css;
		};
	};
}
