{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.files.thunar;
in
{
  options.services.files.thunar.enable = mkEnableOption "Enable Thunar.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      thunar
    ];
  };
}
