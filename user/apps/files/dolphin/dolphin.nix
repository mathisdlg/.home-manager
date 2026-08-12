{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.files.dolphin;
in
{
  options.services.apps.files.dolphin.enable = mkEnableOption "Enable Dolphin.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kdePackages.dolphin
    ];
  };
}
