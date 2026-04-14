{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.component.hypr.hyprpaper;

in {
  options.services.component.hypr.hyprpaper = {
    enable = mkEnableOption "Automatic hyprpaper wallpaper switching";

    latitude = mkOption {
      type = types.str;
      example = "60.379N";
      description = "Latitude for sun detection";
    };

    longitude = mkOption {
      type = types.str;
      example = "102.252W";
      description = "Longitude for sun detection";
    };

    wallpapersDir = {
      day = mkOption {
        type = types.str;
        example = "/home/user/.wallpapers/day";
        description = "Directory containing day wallpapers";
      };
      night = mkOption {
        type = types.str;
        example = "/home/user/.wallpapers/night";
        description = "Directory containing night wallpapers";
      };
      both = mkOption {
        type = types.str;
        example = "/home/user/.wallpapers/both";
        description = "Directory containing wallpapers for both day and night";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprpaper
      sunwait
    ];

    home.file.".config/hypr/hyprpaper.conf".text = ''
      preload = ${cfg.wallpapersDir.both}/*
      wallpaper = ,${cfg.wallpapersDir.both}/*
    '';

    home.file.".config/hypr/scripts/wallpaper.sh" = {
      executable = true;
      text = ''
        #!/bin/bash

        LAT=${toString cfg.latitude}
        LON=${toString cfg.longitude}
        WALL_DIR_BOTH="${cfg.wallpapersDir.both}"
        WALL_DIR_DAY="${cfg.wallpapersDir.day}"
        WALL_DIR_NIGHT="${cfg.wallpapersDir.night}"

        sleep 3

        set_wallpaper() {
            MODE=$1

            if [ "$MODE" = "day" ]; then
                WALLPAPER=$(find "$WALL_DIR_DAY" "$WALL_DIR_BOTH" -type f | shuf -n 1)
            else
                WALLPAPER=$(find "$WALL_DIR_NIGHT" "$WALL_DIR_BOTH" -type f | shuf -n 1)
            fi

            hyprctl hyprpaper unload all
            hyprctl hyprpaper preload "$WALLPAPER"
            hyprctl hyprpaper wallpaper ",$WALLPAPER"
        }

        day_night=$(sunwait poll civil $LAT $LON)
        if [ "$day_night" = "DAY" ]; then
            set_wallpaper "day"
        else
            set_wallpaper "night"
            sunwait wait civil rise $LAT $LON
            set_wallpaper "day"
        fi

        while true; do
            sunwait wait civil set $LAT $LON
            set_wallpaper "night"

            sunwait wait civil rise $LAT $LON
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