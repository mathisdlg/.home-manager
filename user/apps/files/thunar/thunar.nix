{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.files.thunar;
in
{
  options.services.apps.files.thunar.enable = mkEnableOption "Enable Thunar.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      thunar
    ];
  };
}
