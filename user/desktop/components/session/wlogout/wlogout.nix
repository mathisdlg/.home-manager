{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.desktop.components.session.wlogout;
in
{
  options.services.desktop.components.session.wlogout.enable = mkEnableOption "Enable wayland logout menu.";

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        wlogout
        fira-code
      ];

      file = {
        ".config/wlogout/layout".source = ./config/layout;
        ".config/wlogout/icons".source = ./config/icons;
        ".config/wlogout/style.css".source = ./config/style.css;

        # Initial default; overwritten at runtime by
        # ../../../themes/day_night/day_night.nix's script, which replaces the
        # symlink with a real file — force=true so `switch` can put the
        # symlink back instead of refusing to touch it.
        ".config/wlogout/colors.css" = {
          source = ./config/colors-night.css;
          force = true;
        };
      };
    };
  };
}
