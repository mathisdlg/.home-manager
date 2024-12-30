{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.hyprland; in {
	options.services.hyprland.enable = mkEnableOption "Enable hyprland.";

	imports = [
		../../components/.
	];

	config = mkIf cfg.enable{
		home = {
			packages = with pkgs; [
				wl-clipboard
			];

			file = {
				".config/hypr/hyprland.conf".source = ./hyprland.conf;
			};
		};

		services = {
			hyprlock.enable = true;
			hypridle.enable = true;
			hyprpicker.enable = true;
			wlogout.enable = true;
			waybar.enable = true;
			dunst.enable = true;
		};
	};
}
