{ config, ... }: {
	imports = [
		../../components/hyprlock/hyprlock.nix
		../../components/hypridle/hypridle.nix
		../../components/hyprpicker/hyprpicker.nix
		
		../../components/waybar/waybar.nix
	];

	config = {
		home.file = {
			".config/hypr/hyprland.conf".source = ./hyprland.conf;
		};
	};
}