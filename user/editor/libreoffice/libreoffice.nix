{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.editor.libreoffice; in {
	options.services.editor.libreoffice.enable = mkEnableOption "Enable libreoffice.";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			libreoffice-qt6
			hunspell
			hunspellDicts.fr-moderne
			hunspellDicts.en_US
		];
	};
}