{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.hypridle; in {
	options.services.hypridle.enable = mkEnableOption "Enable hyprland idle manager.";

	config = mkIf cfg.enable {
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