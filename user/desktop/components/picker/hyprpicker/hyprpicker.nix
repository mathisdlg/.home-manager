{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.desktop.components.picker.hyprpicker;
in
{
  options.services.desktop.components.picker.hyprpicker.enable = mkEnableOption "Enable hyprland color picker.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprpicker
      wl-clipboard
    ];
  };
}
