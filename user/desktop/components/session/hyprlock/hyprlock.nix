{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.desktop.components.session.hyprlock;
in
{
  options.services.desktop.components.session.hyprlock.enable = mkEnableOption "Enable hyprland lock manager.";

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
