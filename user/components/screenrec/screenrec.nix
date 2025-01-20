{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.component.screenrec; in {
	options.services.component.screenrec.enable = mkEnableOption "Enable wl-screenrec.";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			wl-screenrec
		];
	};
}