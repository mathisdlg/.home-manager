{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.hyprpicker; in {
	options.services.hyprpicker.enable = mkEnableOption "Enable hyprland color picker.";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			hyprpicker
			wl-clipboard
		];
	};
}