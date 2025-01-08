{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.component.waybar; in {
	options.services.component.waybar.enable = mkEnableOption "Enable wayland status bar.";

	config = mkIf cfg.enable {
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
