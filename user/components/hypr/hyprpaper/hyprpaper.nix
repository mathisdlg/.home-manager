{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.component.hypr.hyprpaper;

  bash_bin     = "${pkgs.bash}/bin/bash";
  hyprctl_bin  = "${pkgs.hyprland}/bin/hyprctl";
  sunwait_bin  = "${pkgs.sunwait}/bin/sunwait";
  find_bin     = "${pkgs.findutils}/bin/find";
  shuf_bin     = "${pkgs.coreutils}/bin/shuf";

in {
  options.services.component.hypr.hyprpaper = {
    enable = mkEnableOption "Automatic hyprpaper wallpaper switching";

    latitude = mkOption {
      type = types.strMatching "[0-9]+(\.[0-9]+)?[NS]";
      example = "60.379N";
      description = "Latitude for sun detection, e.g. 60.379N or 48.123S";
    };

    longitude = mkOption {
      type = types.strMatching "[0-9]+(\.[0-9]+)?[EW]";
      example = "102.252W";
      description = "Longitude for sun detection, e.g. 102.252W or 13.405E";
    };

    wallpapersDir = {
      day = mkOption {
        type = types.str;
        example = "/home/user/.wallpapers/day";
        description = "Directory containing day-only wallpapers";
      };
      night = mkOption {
        type = types.str;
        example = "/home/user/.wallpapers/night";
        description = "Directory containing night-only wallpapers";
      };
      both = mkOption {
        type = types.str;
        example = "/home/user/.wallpapers/both";
        description = "Directory containing wallpapers suitable for day and night";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprpaper
      sunwait
    ];

    # Minimal stub config — the script manages preloading/setting at runtime.
    # hyprpaper needs a config file to start, but globs don't work here.
    home.file.".config/hypr/hyprpaper.conf".text = ''
      splash = true
      splash_offset = 50
      splash_opacity = 0.8
      
      ipc = on
    '';

    home.file.".config/hypr/scripts/wallpaper.sh" = {
      executable = true;
      text = ''
        #!${bash_bin}

        LAT="${cfg.latitude}"
        LON="${cfg.longitude}"
        WALL_DIR_BOTH="${cfg.wallpapersDir.both}"
        WALL_DIR_DAY="${cfg.wallpapersDir.day}"
        WALL_DIR_NIGHT="${cfg.wallpapersDir.night}"

        set_wallpaper() {
            local mode="$1"
            local wallpaper

            if [ "$mode" = "DAY" ]; then
                wallpaper=$(${find_bin} "$WALL_DIR_DAY" "$WALL_DIR_BOTH" -type f | ${shuf_bin} -n 1)
            else
                wallpaper=$(${find_bin} "$WALL_DIR_NIGHT" "$WALL_DIR_BOTH" -type f | ${shuf_bin} -n 1)
            fi

            if [ -z "$wallpaper" ]; then
                echo "wallpaper.sh: no wallpaper found for mode $mode" >&2
                return 1
            fi

            ${hyprctl_bin} hyprpaper unload all 2>/dev/null || true
            ${hyprctl_bin} hyprpaper preload "$wallpaper"
            ${hyprctl_bin} hyprpaper wallpaper ",$wallpaper"
        }

        # Wait for hyprpaper's IPC socket to be ready
        for i in $(seq 1 20); do
            ${hyprctl_bin} hyprpaper listloaded >/dev/null 2>&1 && break
            sleep 0.5
        done

        day_night=$(${sunwait_bin} poll civil "$LAT" "$LON")

        if [ "$day_night" = "DAY" ]; then
            next="set"
            set_wallpaper "DAY"
        else
            next="rise"
            set_wallpaper "NIGHT"
        fi

        while true; do
            ${sunwait_bin} wait civil "$next" "$LAT" "$LON"
            if [ "$next" = "rise" ]; then
                set_wallpaper "DAY"
                next="set"
            else
                set_wallpaper "NIGHT"
                next="rise"
            fi
        done
      '';
    };

    systemd.user.services.hyprpaper-day-night-wallpaper = {
      Unit = {
        Description = "Auto wallpaper switcher (sun-based)";
        After = [ "graphical-session.target" "hyprland-session.target" ];
        Wants = [ "hyprland-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${bash_bin} ${config.home.homeDirectory}/.config/hypr/scripts/wallpaper.sh";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}