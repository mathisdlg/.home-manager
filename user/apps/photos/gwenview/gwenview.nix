{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.photos.gwenview;
in
{
  options.services.apps.photos.gwenview.enable =
    mkEnableOption "Enable Gwenview (KDE image viewer).";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kdePackages.gwenview
    ];
  };
}
