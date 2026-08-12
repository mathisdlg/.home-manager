{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.media_player.yt_dlp;
in
{
  options.services.apps.media_player.yt_dlp.enable = mkEnableOption "Enable yt-dlp (command-line utility to download videos from YouTube and other sites)";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ffmpeg
      yt-dlp
    ];
  };
}
