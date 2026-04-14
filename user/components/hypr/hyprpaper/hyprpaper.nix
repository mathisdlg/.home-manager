{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.component.hypr.hyprpaper;

in {
  options.services.component.hypr.hyprpaper = {
    enable = mkEnableOption "Automatic hyprpaper wallpaper switching";

    latitude = mkOption {
      type = types.float;
      example = 45.75;
      description = "Latitude for sun detection";
    };

    longitude = mkOption {
      type = types.float;
      example = 4.85;
      description = "Longitude for sun detection";
    };

    wallpapersDir = mkOption {
      type = types.str;
      example = "${config.home.homeDirectory}/.wallpapers";
      description = "Base wallpapers directory";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprpaper
      sunwait
    ];

    home.file.".config/hypr/hyprpaper.conf".text = ''
      preload = ${cfg.wallpapersDir}/both/*
      wallpaper = ,${cfg.wallpapersDir}/both/*
    '';

    home.file.".config/hypr/scripts/wallpaper.sh" = {
      executable = true;
      text = ''
        #!/bin/bash

        LAT=${toString cfg.latitude}
        LON=${toString cfg.longitude}
        WALL_DIR="${cfg.wallpapersDir}"

        sleep 3

        set_wallpaper() {
            MODE=$1

            if [ "$MODE" = "day" ]; then
                WALLPAPER=$(find "$WALL_DIR/day" "$WALL_DIR/both" -type f | shuf -n 1)
            else
                WALLPAPER=$(find "$WALL_DIR/night" "$WALL_DIR/both" -type f | shuf -n 1)
            fi

            hyprctl hyprpaper unload all
            hyprctl hyprpaper preload "$WALLPAPER"
            hyprctl hyprpaper wallpaper ",$WALLPAPER"
        }

        if sunwait poll civil rise $LAT $LON; then
            set_wallpaper "night"
            sunwait poll civil rise $LAT $LON
            set_wallpaper "day"
        else
            set_wallpaper "day"
        fi

        while true; do
            sunwait poll civil set $LAT $LON
            set_wallpaper "night"

            sunwait poll civil rise $LAT $LON
            set_wallpaper "day"
        done
      '';
    };

    systemd.user.services.hyprpaper-day-night-wallpaper = {
      Unit = {
        Description = "Auto wallpaper switcher (sun-based)";
        After = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${config.home.homeDirectory}/.config/hypr/scripts/wallpaper.sh";
        Restart = "always";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}