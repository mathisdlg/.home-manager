{config, pkgs, lib, ...}:
with lib; let cfg = config.services.rgb.openrgb; in {
	options.services.rgb.openrgb.enable = mkEnableOption "Enable OpenRGB (RGB lighting control software).";

	config = mkIf cfg.enable {
		services.hardware.openrgb.enable = true;

		environment.systemPackages = with pkgs; [
			openrgb-with-all-plugins
		];
	};
}