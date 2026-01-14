{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.games.beammp;
in
{
  options.services.games.beammp.enable =
    mkEnableOption "Enable beammp launcher for BeamNG.drive";

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        beammp-launcher
      ];
    };
  };
}
