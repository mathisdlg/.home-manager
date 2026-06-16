{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.cad.kicad;
in
{
  options.services.cad.kicad.enable = mkEnableOption "Enable kicad.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kicad
    ];
  };
}
