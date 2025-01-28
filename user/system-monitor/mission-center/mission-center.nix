{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.system-monitor.mission-center; in {
	options.services.system-monitor.gnome-system-monitor.enable = mkEnableOption "Enable mission center (a systetm monitor).";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			mission-center
		];
	};
}