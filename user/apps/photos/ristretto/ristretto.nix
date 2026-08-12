{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.photos.ristretto;
in
{
  options.services.apps.photos.ristretto.enable =
    mkEnableOption "Enable Ristretto (XFCE image viewer).";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ristretto
    ];
  };
}
