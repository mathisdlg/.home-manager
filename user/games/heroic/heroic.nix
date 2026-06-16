{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.games.heroic;
in
{
  options.services.games.heroic.enable = mkEnableOption "Enable heroic games (epic games).";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      heroic-unwrapped
    ];
  };
}
