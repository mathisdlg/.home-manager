{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.osu; in {
	options.services.osu.enable = mkEnableOption "Enable my own osu downloader and updater for nixos.";

	config = mkIf cfg.enable {
		home = {
			packages = with pkgs; [
				appimage-run
			];

			file = {
				"Games/osu".source = ./osu.d;
			};
		};
	};
}
