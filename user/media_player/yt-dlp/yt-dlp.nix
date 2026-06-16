{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.media_player.yt-dlp;
in
{
  options.services.media_player.yt-dlp.enable = mkEnableOption "Enable yt-dlp (command-line utility to download videos from YouTube and other sites)";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ffmpeg
      yt-dlp
    ];
  };
}
