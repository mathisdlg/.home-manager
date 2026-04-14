{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.games.osu;
in
{
  options.services.games.osu.enable =
    mkEnableOption "Enable osu! game client";

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        osu-lazer-bin
      ];
    };
  };
}
