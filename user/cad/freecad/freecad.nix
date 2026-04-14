{
  config,
  pkgs,
  unstablePkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.cad.freecad;
in
{
  options.services.cad.freecad.enable = mkEnableOption "Enable freecad.";

  config = mkIf cfg.enable {
    home.packages = with unstablePkgs; [
      freecad
    ];
  };
}
