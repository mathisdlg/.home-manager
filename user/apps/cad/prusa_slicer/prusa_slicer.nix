{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.cad.prusa_slicer;
in
{
  options.services.apps.cad.prusa_slicer.enable = mkEnableOption "Enable prusa slicer.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      prusa-slicer
    ];
  };
}
