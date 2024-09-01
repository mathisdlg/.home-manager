{ config, pkgs, lib, ... }: {
	imports = [];

	config = {
		home.packages = with pkgs; [
			nordzy-cursor-theme
		];

		home.pointerCursor = {
			gtk.enable = lib.mkForce true;
			x11.enable = lib.mkForce true;
			name = lib.mkForce "Nordzy-cursors";
			size = lib.mkForce 24;

			package = pkgs.nordzy-cursor-theme;
		};

		fonts.fontconfig.enable = true;
	};
}