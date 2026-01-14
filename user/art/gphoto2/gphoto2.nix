{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.art.gphoto2;
in
{
  options.services.art.gphoto2.enable = mkEnableOption "Enable gphoto2.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gphoto2
    ];
  };
}
