{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.art.krita; in {
	options.services.art.krita.enable = mkEnableOption "Enable krita.";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			krita
		];
	};
}