{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.keepassxc; in {
	options.services.keepassxc.enable = mkEnableOption "Enable keypassXC.";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			keepassxc
		];
	};
}