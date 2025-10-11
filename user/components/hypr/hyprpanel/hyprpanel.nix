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

        bar = {
          launcher = {
            autoDetectIcon = true;
          };
          workspaces.show_icons = false;
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
            directories.enabled = false;
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
            buttons.dashboard.icon = "#aae5a4";
          };
        };
      };
    };
  };
}