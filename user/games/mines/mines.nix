{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.games.mines;
in
{
  options.services.games.mines.enable = mkEnableOption "Enable gnome minesweeper.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gnome-mines
    ];
  };
}
