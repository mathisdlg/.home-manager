{ config, pkgs, ... }: {
	config = {
		home.packages = with pkgs; [];

		programs.appimage-run.enable = true;

		home.file."Games/osu/".source = ./osu/;
	};
}
