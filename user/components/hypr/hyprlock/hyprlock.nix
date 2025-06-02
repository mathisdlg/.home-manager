{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.component.hypr.hyprlock;
in
{
  options.services.component.hypr.hyprlock.enable = mkEnableOption "Enable hyprland lock manager.";

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        hyprlock
      ];

      file = {
        ".config/hypr/hyprlock.conf".source = ./hyprlock.conf;
      };
    };
  };
}
