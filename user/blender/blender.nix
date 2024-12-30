{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.blender; in {
	options.services.blender.enable = mkEnableOption "Enable blender.";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			blender
		];
	};
}
