{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.art.freecad;
in
{
  options.services.art.freecad.enable = mkEnableOption "Enable freecad.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      freecad
    ];
  };
}
