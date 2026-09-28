{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.cad.kicad;
in
{
  options.services.apps.cad.kicad.enable = mkEnableOption "Enable kicad.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kicad
    ];
  };
}
