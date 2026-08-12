{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.desktop.screenshare.grimblast;
in
{
  options.services.desktop.screenshare.grimblast.enable = mkEnableOption "Enable grimblast.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      grimblast
    ];
  };
}
