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
        bar.layouts = {
          "0" = {
            left = [ "dashboard" "workspaces" "windowtitle" ];
            middle = [ "media" ];
            right = [ "battery" "volume" "network" "bluetooth" "hypridle" "clock" "notifications" ];
          };
          "1" = {
            left = [ "dashboard" "workspaces" "windowtitle" ];
            middle = [ "media" ];
            right = [ "clock" "notifications" ];
          };
        };

        bar = {
          launcher = {
            autoDetectIcon = true;
          };
          workspaces = {
            show_icons = false;
            show_numbered = true;
          };
        };

        menus = {
          clock = {
            time = {
              military = true;
              hideSeconds = false;
            };

            weather = {
              unit = "metric";
            };
          };

          dashboard = {
            directories = {
              enable = true;
            };
            stats.enable_gpu = false;
          };
        };

        theme = {
          font = {
            name = "CaskaydiaCove NF";
            size = "16px";
          };
          bar = {
            transparent = true;
            buttons.dashboard = {
              icon = "#aae5a4";
            };
          };
        };
      };
    };
  };
}