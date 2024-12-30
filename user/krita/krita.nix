{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.krita; in {
	options.services.krita.enable = mkEnableOption "Enable krita.";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			krita
		];
	};
}