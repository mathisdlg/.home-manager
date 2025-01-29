{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.system-monitor.gnome-system-monitor; in {
	options.services.system-monitor.gnome-system-monitor.enable = mkEnableOption "Enable gnome system monitor.";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			gnome-system-monitor
		];
	};
}