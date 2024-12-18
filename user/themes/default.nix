{ config, pkgs, lib, ... }: {
	imports = [
		./background/background.nix
	];

	config = {
		home = {
			packages = with pkgs; [
				nordzy-cursor-theme
			];

			pointerCursor = {
				gtk.enable = lib.mkForce true;
				x11.enable = lib.mkForce true;
				name = lib.mkForce "Nordzy-cursors";
				size = lib.mkForce 24;

				package = pkgs.nordzy-cursor-theme;
			};
		};

		fonts.fontconfig.enable = true;
	};
}