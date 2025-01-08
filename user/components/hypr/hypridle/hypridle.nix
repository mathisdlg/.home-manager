{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.component.hypr.hypridle; in {
	options.services.component.hypr.hypridle.enable = mkEnableOption "Enable hyprland idle manager.";

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