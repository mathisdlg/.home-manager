{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.baobab; in {
	options.services.baobab.enable = mkEnableOption "Enable baobab disk usage analyzer.";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			baobab
		];
	};
}