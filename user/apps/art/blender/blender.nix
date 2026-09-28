{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.art.blender;
in
{
  options.services.apps.art.blender.enable = mkEnableOption "Enable blender.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      blender-hip
    ];
  };
}
