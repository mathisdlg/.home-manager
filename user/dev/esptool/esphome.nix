{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.dev.esptool;
in
{
  options.services.dev.esptool.enable = mkEnableOption "Enable esptool.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      esptool
    ];
  };
}
