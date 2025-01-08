{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.communication.thunderbird; in {
	options.services.communication.thunderbird.enable = mkEnableOption "Enable thunderbird mail client.";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			thunderbird
		];
	};
}