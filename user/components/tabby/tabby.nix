{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.tabby; in {
	options.services.tabby.enable = mkEnableOption "Enable TabbyML (Self-hosted AI coding assistant).";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			tabby
		];
	};
}
