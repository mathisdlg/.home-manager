{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.firefox-dev; in {
	options.services.firefox-dev.enable = mkEnableOption "Enable firefox developer edition browser.";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			firefox-devedition-bin
		];
	};
}