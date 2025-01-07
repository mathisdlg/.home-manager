{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.programming.python; in {
	options.services.programming.python.enable = mkEnableOption "Enable python programming language.";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			python
		];
	};
}