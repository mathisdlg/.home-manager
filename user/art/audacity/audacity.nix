{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.art.audacity;
in
{
  options.services.art.audacity.enable = mkEnableOption "Enable audacity.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      audacity
    ];
  };
}