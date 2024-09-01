{ config, pkgs, ... }: {
	imports = [];

	config = {
		home.packages = with pkgs; [
			hypridle
		];

		home.file = {
			".config/hypr/hypridle.conf".source = ./hypridle.conf;
		};
	};
}