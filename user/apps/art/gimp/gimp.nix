{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.art.gimp;
in
{
  options.services.apps.art.gimp.enable = mkEnableOption "Enable gimp.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gimp-with-plugins
    ];
  };
}
