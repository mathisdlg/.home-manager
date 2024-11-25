{ config, pkgs, ... }: {
	imports = [];

	config = {
		home.packages = with pkgs; [
		];

		programs.mpv = {
			enable = true;
			scripts = with pkgs.mpvScripts; [
				uosc
			];
		};
	};
}