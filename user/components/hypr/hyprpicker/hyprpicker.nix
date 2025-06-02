{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.component.hypr.hyprpicker;
in
{
  options.services.component.hypr.hyprpicker.enable = mkEnableOption "Enable hyprland color picker.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprpicker
      wl-clipboard
    ];
  };
}
