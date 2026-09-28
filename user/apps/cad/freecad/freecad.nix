{
  config,
  pkgs,
  unstable_pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.cad.freecad;
in
{
  options.services.apps.cad.freecad.enable = mkEnableOption "Enable freecad.";

  config = mkIf cfg.enable {
    home.packages = with unstable_pkgs; [
      freecad
    ];
  };
}
