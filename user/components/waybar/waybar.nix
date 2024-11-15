{ config, pkgs, ... }: {
	imports = [];

	config = {
		home = {
			packages = with pkgs; [
				waybar
				jetbrains-mono
			];

			file = {
				".config/waybar".source = ./config;
			};
		};
	};
}
