{ config, pkgs, ... }: {
	imports = [];

	config = {
		home.packages = with pkgs; [
			font-awesome
		];

		home.file = {
			".config/waybar/config".source = ./config;
            ".config/waybar/style.css".source = ./style.css;
		};
	};
}
