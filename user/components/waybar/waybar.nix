{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.component.waybar;
in
{
  options.services.component.waybar.enable = mkEnableOption "Enable wayland status bar.";

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
        # runtime by ../../../themes/day-night/day-night.nix's script.
        ".config/waybar/colors.css".source = ./config/colors-night.css;

        # Templated rather than a plain static copy: the cpu/memory/temperature
        # widgets' on-click handlers should launch whichever system monitor is
        # actually enabled (see ../../system-monitor/system-monitor.nix),
        # instead of a hardcoded name that can drift out of sync with it.
        ".config/waybar/modules".text = builtins.replaceStrings
          [ "missioncenter" ]
          [ config.services.system-monitor.command ]
          (builtins.readFile ./config/modules);
      };
    };
  };
}
