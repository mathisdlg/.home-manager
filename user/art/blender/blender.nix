{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.art.blender; in {
	options.services.art.blender.enable = mkEnableOption "Enable blender.";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			blender-hip
		];
	};
}
