{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.editor.kicad;
in
{
  options.services.editor.kicad.enable = mkEnableOption "Enable kicad.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kicad
    ];
  };
}
