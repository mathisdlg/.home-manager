{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.art.gimp;
in
{
  options.services.art.gimp.enable = mkEnableOption "Enable gimp.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gimp3
    ];
  };
}
