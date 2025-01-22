{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.screenshare.screenrec; in {
	options.services.screenshare.screenrec.enable = mkEnableOption "Enable wl-screenrec.";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			wl-screenrec
		];
	};
}