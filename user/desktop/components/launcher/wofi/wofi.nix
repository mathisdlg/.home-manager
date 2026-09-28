{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.desktop.components.launcher.wofi;
in
{
  options.services.desktop.components.launcher.wofi.enable = mkEnableOption "Enable wofi (app launcher/menu).";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wofi
    ];

    home.file = {
      ".config/wofi/style-day.css".source = ./config/style-day.css;
      ".config/wofi/style-night.css".source = ./config/style-night.css;

      # Initial default; overwritten at runtime by
      # ../../../themes/day_night/day_night.nix's script, which replaces the
      # symlink with a real file — force=true so `switch` can put the
      # symlink back instead of refusing to touch it.
      ".config/wofi/style.css" = {
        source = ./config/style-night.css;
        force = true;
      };
    };
  };
}
