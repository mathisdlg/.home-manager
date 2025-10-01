{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.component.hypr.hyprpaper;
in
{
  options.services.component.hypr.hyprpaper.enable = mkEnableOption "Enable hyprland wallpaper manager.";

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        hyprpaper
      ];

      file = {
        ".config/hypr/hyprpaper.conf".source = ./hyprpaper.conf;
      };
    };
  };
}
