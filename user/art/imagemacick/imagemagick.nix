{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.art.imagemagick;
in
{
  options.services.art.imagemagick.enable = mkEnableOption "Enable imagemagick.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      imagemagick
    ];
  };
}
