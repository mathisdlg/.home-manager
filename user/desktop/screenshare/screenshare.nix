{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.desktop.screenshare.screenshare;
in
{
  options.services.desktop.screenshare.screenshare.enable = mkEnableOption "Enable screensharing app.";

  config.services.desktop.screenshare = mkIf cfg.enable {
    grimblast.enable = true;
    screenrec.enable = true;
    slurp.enable = true;
  };
}
