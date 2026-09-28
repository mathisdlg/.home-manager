{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.notes.joplin;
in
{
  options.services.apps.notes.joplin.enable =
    mkEnableOption "Enable Joplin (open source).";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      joplin-desktop
    ];
  };
}
