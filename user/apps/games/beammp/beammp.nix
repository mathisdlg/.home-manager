{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.games.beammp;
in
{
  options.services.apps.games.beammp.enable =
    mkEnableOption "Enable beammp launcher for BeamNG.drive";

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        beammp-launcher
      ];
    };
  };
}
