{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.component.hypr.hyprpanel;
in
{
  options.services.component.hypr.hyprpanel.enable = mkEnableOption "Enable hyprland panel manager.";

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        hyprpanel
        nerd-fonts.inconsolata
      ];

      file = {
        ".face.icon".source = ./.face.icon;
      };
    };


    programs.hyprpanel = {
      enable = true;

      systemd.enable = true;

      settings = {
        layout = {
          bar.layouts = {
            "0" = {
              left = [ "dashboard" "workspaces" ];
              middle = [ "media" ];
              right = [ "volume" "notifications" ];
            };
          };
        };

        bar.launcher.autoDetectIcon = true;
        bar.workspaces.show_icons = false;

        menus.clock = {
          time = {
            military = true;
            hideSeconds = false;
          };
          weather.unit = "metric";
        };

        menus.dashboard.directories.enabled = false;
        menus.dashboard.stats.enable_gpu = false;

        theme.bar.transparent = true;

        theme.font = {
          name = "CaskaydiaCove NF";
          size = "16px";
        };
      };
    };
  };
}