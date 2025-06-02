{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.games.puzzles;
in
{
  options.services.games.puzzles.enable =
    mkEnableOption "Enable puzzles games (https://www.chiark.greenend.org.uk/~sgtatham/puzzles/).";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      sgt-puzzles
    ];
  };
}
