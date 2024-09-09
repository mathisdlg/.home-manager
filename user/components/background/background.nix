{ config, ... }: {
	imports = [];

	config = {
		home.file = {
			".background/hyprlock.jpg".source = ./images/hyprlock.jpg;
		};
	};
}