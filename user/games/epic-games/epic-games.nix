{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.games.epic-games; in {
	options.services.games.epic-games.enable = mkEnableOption "Enable gnome epic games store.";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			heroic-unwrapped
		];
	};
}