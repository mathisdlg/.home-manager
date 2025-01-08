{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.component.wofi; in {
	options.services.component.wofi.enable = mkEnableOption "Enable thunderbird mail client.";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			wofi
		];
	};
}