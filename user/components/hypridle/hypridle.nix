{ config, pkgs, ... }: {
	imports = [];

	config = {
		home = {
			packages = with pkgs; [
				hypridle
			];

			file = {
				".config/hypr/hypridle.conf".source = ./hypridle.conf;
			};
		};
	};
}