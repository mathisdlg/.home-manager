{ config, pkgs, ... }: {
	imports = [
		../../components/hyprlock/hyprlock.nix
		../../components/hypridle/hypridle.nix
		../../components/hyprpicker/hyprpicker.nix
		
		../../components/waybar/waybar.nix
	];

	config = {
		home = {
			packages = with pkgs; [
				wl-clipboard
			];
			file = {
				".config/hypr/hyprland.conf".source = ./hyprland.conf;
			};
		};
	};
}
