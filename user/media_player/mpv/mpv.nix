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
    home.packages = with pkgs; [
      socat
    ];

    programs.mpv = {
      enable = true;
      scripts = with pkgs.mpvScripts; [
        uosc
      ];
    };
  };
}
