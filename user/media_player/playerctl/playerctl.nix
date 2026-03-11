{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.playerctl;
in
{
  options.services.playerctl.enable = mkEnableOption "Enable playerctl (command-line utility to control media players)";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      playerctl
    ];
  };
}
