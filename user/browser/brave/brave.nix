{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.brave; in {
	options.services.brave.enable = mkEnableOption "Enable brave browser.";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			brave
		];
	};
}