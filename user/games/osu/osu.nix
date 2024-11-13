{ config, pkgs, ... }: {
	config = {
		home.packages = with pkgs; [
			appimage-run
		];

		home.file = {
			"Games/osu".source = ./osu.d;
		};
	};
}
