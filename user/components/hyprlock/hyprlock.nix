{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.hyprlock; in {
	options.services.hyprlock.enable = mkEnableOption "Enable hyprland lock manager.";

	config = mkIf cfg.enable {
		home = {
			packages = with pkgs; [
				hyprlock
			];

			file = {
				".config/hypr/hyprlock.conf".source = ./hyprlock.conf;
			};
		};
	};
}