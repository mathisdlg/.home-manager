{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.dev.esphome;
in
{
  options.services.dev.esphome.enable = mkEnableOption "Enable esphome.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      esphome
    ];
  };
}
