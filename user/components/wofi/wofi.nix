{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.wofi-custom; in {
	options.services.wofi-custom.enable = mkEnableOption "Enable thunderbird mail client.";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			wofi
		];
	};
}