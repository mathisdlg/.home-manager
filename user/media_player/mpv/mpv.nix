{ config, pkgs, ... }: {
	imports = [];

	config = {
		home.packages = with pkgs; [
			socat
		];

		programs.mpv = {
			enable = true;
			scripts = with pkgs.mpvScripts; [
				uosc
			];
		};
	};
}