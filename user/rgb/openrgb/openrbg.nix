{config, pkgs, lib, ...}:
with lib; let cfg = config.services.rgb.openrgb; in {
	options.services.rgb.openrgb.enable = mkEnableOption "Enable OpenRGB (RGB lighting control software).";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			openrgb-with-all-plugins
		];

		services.hardware.openrgb.enable = true;
	};
}