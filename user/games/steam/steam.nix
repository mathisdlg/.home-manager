{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.games.steam;
in
{
  options.services.games.steam.enable = mkEnableOption "Enable steam.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      steam
    ];
  };
}
