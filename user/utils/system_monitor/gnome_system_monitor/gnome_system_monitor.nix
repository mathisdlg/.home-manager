{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.utils.system_monitor.gnome_system_monitor;
in
{
  options.services.utils.system_monitor.gnome_system_monitor.enable =
    mkEnableOption "Enable gnome system monitor.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gnome-system-monitor
    ];
  };
}
