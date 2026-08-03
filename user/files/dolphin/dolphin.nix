{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.files.dolphin;
in
{
  options.services.files.dolphin.enable = mkEnableOption "Enable Dolphin.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kdePackages.dolphin
    ];
  };
}
