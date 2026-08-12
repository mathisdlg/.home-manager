{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.art.krita;
in
{
  options.services.apps.art.krita.enable = mkEnableOption "Enable krita.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      krita
    ];
  };
}
