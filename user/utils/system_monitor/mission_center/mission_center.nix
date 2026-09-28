{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.utils.system_monitor.mission_center;
in
{
  options.services.utils.system_monitor.mission_center.enable =
    mkEnableOption "Enable mission center (a system monitor).";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      mission-center
    ];
  };
}
