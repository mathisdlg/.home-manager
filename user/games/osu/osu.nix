{ config, pkgs, ... }: {
	config = {
		home = {
			packages = with pkgs; [
				appimage-run
			];

			file = {
				"Games/osu".source = ./osu.d;
			};
		};
	};
}
