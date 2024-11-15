{ config, pkgs, ... }: {
	imports = [];

	config = {
		home = {
			packages = with pkgs; [
				hyprlock
			];

			file = {
				".config/hypr/hyprlock.conf".source = ./hyprlock.conf;
			};
		};
	};
}