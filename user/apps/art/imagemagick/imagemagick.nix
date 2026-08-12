{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.art.imagemagick;
in
{
  options.services.apps.art.imagemagick.enable = mkEnableOption "Enable imagemagick.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      imagemagick
    ];
  };
}
