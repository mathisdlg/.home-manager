{ config, ... }: {
	imports = [];

	config = {
		home.file = {
			".config/waybar/config".source = ./config;
            ".config/waybar/style.css".source = ./style.css;
		};
	};
}