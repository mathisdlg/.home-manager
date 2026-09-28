{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.utils.disk_usage.baobab;
in
{
  options.services.utils.disk_usage.baobab.enable =
    mkEnableOption "Enable Baobab (GNOME disk usage analyzer).";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      baobab
    ];
  };
}
