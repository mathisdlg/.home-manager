{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.mines; in {
	options.services.mines.enable = mkEnableOption "Enable gnome minesweeper.";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			gnome-mines
		];
	};
}