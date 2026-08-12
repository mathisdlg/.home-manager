{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.games.mines;
in
{
  options.services.apps.games.mines.enable = mkEnableOption "Enable gnome minesweeper.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gnome-mines
    ];
  };
}
