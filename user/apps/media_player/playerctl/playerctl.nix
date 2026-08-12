{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.media_player.playerctl;
in
{
  options.services.apps.media_player.playerctl.enable = mkEnableOption "Enable playerctl (command-line utility to control media players)";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      playerctl
    ];
  };
}
