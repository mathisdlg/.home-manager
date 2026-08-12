{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.utils.disk_usage.filelight;
in
{
  options.services.utils.disk_usage.filelight.enable =
    mkEnableOption "Enable Filelight (KDE disk usage analyzer).";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kdePackages.filelight
    ];
  };
}
