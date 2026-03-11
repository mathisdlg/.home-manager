{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.mpv;
in
{
  options.services.mpv.enable = mkEnableOption "Enable mpv (hackable media player)";

  config = mkIf cfg.enable {
    programs.mpv = {
      enable = true;
      scripts = with pkgs.mpvScripts; [
        uosc
        mpris # mpris script to control mpv with playerctl, see user/media_player/playerctl/playerctl.nix
      ];
    };
  };
}
