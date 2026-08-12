{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.photos.loupe;
in
{
  options.services.apps.photos.loupe.enable =
    mkEnableOption "Enable Loupe (GNOME image viewer).";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      loupe
    ];
  };
}
