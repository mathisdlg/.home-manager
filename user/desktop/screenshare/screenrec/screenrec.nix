{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.desktop.screenshare.screenrec;
in
{
  options.services.desktop.screenshare.screenrec.enable = mkEnableOption "Enable wl-screenrec.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-screenrec
    ];
  };
}
