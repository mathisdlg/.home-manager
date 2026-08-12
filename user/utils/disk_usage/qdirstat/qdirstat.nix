{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.utils.disk_usage.qdirstat;
in
{
  options.services.utils.disk_usage.qdirstat.enable =
    mkEnableOption "Enable QDirStat (Qt disk usage analyzer with a treemap view, no desktop-environment dependency).";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      qdirstat
    ];
  };
}
