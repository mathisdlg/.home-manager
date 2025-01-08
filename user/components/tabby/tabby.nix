{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.component.tabby; in {
	options.services.component.tabby.enable = mkEnableOption "Enable TabbyML (Self-hosted AI coding assistant).";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			tabby
		];
	};
}
