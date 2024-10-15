{ config, pkgs, ... }: {
	imports = [];

	config = {
		home.packages = with pkgs; [
			gnome.gnome-mines
		];
	};
}