{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.hypridle-custom; in {
	options.services.hypridle-custom.enable = mkEnableOption "Enable hyprland idle manager.";

	config = mkIf cfg.enable {
		home = {
			file = {
				".config/hypr/hypridle.conf".source = ./hypridle.conf;
			};

			packages = with pkgs; [
				hypridle
			];
		};

		services.hypridle.enable = true;
	};
}