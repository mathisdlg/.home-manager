{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.desktop.components.bar.waybar;
in
{
  options.services.desktop.components.bar.waybar.enable = mkEnableOption "Enable wayland status bar.";

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        waybar
        jetbrains-mono
      ];

      file = {
        ".config/waybar/config".source = ./config/config;
        ".config/waybar/style.css".source = ./config/style.css;

        # Initial default (matches the pre-day/night look); overwritten at
        # runtime by ../../../themes/day_night/day_night.nix's script, which
        # replaces the symlink with a real file — force=true so `switch` can
        # put the symlink back instead of refusing to touch it.
        ".config/waybar/colors.css" = {
          source = ./config/colors-night.css;
          force = true;
        };

        # Templated rather than a plain static copy: the cpu/memory/temperature
        # widgets' on-click handlers should launch whichever system monitor is
        # actually enabled (see ../../../../utils/system_monitor/system_monitor.nix),
        # instead of a hardcoded name that can drift out of sync with it.
        ".config/waybar/modules".text = builtins.replaceStrings
          [ "missioncenter" ]
          [ config.services.utils.system_monitor.command ]
          (builtins.readFile ./config/modules);
      };
    };
  };
}
