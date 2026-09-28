{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.games.heroic;
in
{
  options.services.apps.games.heroic.enable = mkEnableOption "Enable heroic games (epic games).";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      heroic-unwrapped
    ];
  };
}
