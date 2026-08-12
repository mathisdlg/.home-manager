# Generalizes the sun-based day/night detection already used for wallpaper
# (see ../../components/wallpaper/hyprpaper/hyprpaper.nix) to also drive
# every other theme-able app: GTK apps, Qt apps, the bar, wofi/wlogout,
# dunst, and hyprland's own border colors.
#
# Two ways this fires:
# - Automatically, via a systemd user service polling sunwait, exactly like
#   the wallpaper switcher.
# - Manually, via a keybind (see ../../wm/hyprland/config/binding.nix) that
#   toggles immediately and isn't undone until the next real sunrise/sunset.
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.desktop.themes.day_night;

  bash_bin = "${pkgs.bash}/bin/bash";
  dconf_bin = "${pkgs.dconf}/bin/dconf";
  hyprctl_bin = "${pkgs.hyprland}/bin/hyprctl";
  sunwait_bin = "${pkgs.sunwait}/bin/sunwait";
  systemctl_bin = "${pkgs.systemd}/bin/systemctl";
  cp_bin = "${pkgs.coreutils}/bin/cp";
  mkdir_bin = "${pkgs.coreutils}/bin/mkdir";
  cat_bin = "${pkgs.coreutils}/bin/cat";

  home = config.home.homeDirectory;

  waybar_enabled = config.services.desktop.components.bar.waybar.enable or false;
  hyprpanel_enabled = config.services.desktop.components.bar.hyprpanel.enable or false;
  wofi_enabled = config.services.desktop.components.launcher.wofi.enable or false;
  wlogout_enabled = config.services.desktop.components.session.wlogout.enable or false;
  dunst_enabled = config.services.desktop.components.notifications.dunst.enable or false;
  themes_enabled = config.services.desktop.themes.themes.enable or false;
in
{
  options.services.desktop.themes.day_night = {
    enable = mkEnableOption "Automatic + manual day/night theme switching";

    latitude = mkOption {
      type = types.strMatching "[0-9]+(\\.[0-9]+)?[NS]";
      example = "60.379N";
      description = "Latitude for sun detection — keep in sync with hyprpaper's, unless you want theme/wallpaper transitions to happen at different points.";
    };

    longitude = mkOption {
      type = types.strMatching "[0-9]+(\\.[0-9]+)?[EW]";
      example = "102.252W";
      description = "Longitude for sun detection.";
    };

    toggle_command = mkOption {
      type = types.str;
      readOnly = true;
      default = "${bash_bin} ${home}/.config/hypr/scripts/theme-mode/toggle-mode.sh";
      description = "Command a keybind can call to manually flip day/night immediately.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      sunwait
    ];

    home.file = {
      # --- GTK (Nautilus/Thunar) ------------------------------------------
      # Handled inline below via dconf — no separate file needed, dconf IS
      # the runtime-mutable store. See themes.nix for the build-time default
      # (adw-gtk3/adw-gtk3-dark) and the packages this depends on.

      # --- Waybar / wlogout: colour partials swapped by the script --------
      ".config/waybar/colors-day.css".source = ../../components/bar/waybar/config/colors-day.css;
      ".config/waybar/colors-night.css".source = ../../components/bar/waybar/config/colors-night.css;

      ".config/wlogout/colors-day.css".source = ../../components/session/wlogout/config/colors-day.css;
      ".config/wlogout/colors-night.css".source = ../../components/session/wlogout/config/colors-night.css;

      # --- wofi: full day/night stylesheets (none existed before) --------
      ".config/wofi/style-day.css".source = ../../components/launcher/wofi/config/style-day.css;
      ".config/wofi/style-night.css".source = ../../components/launcher/wofi/config/style-night.css;

      # --- dunst: full dunstrc variants, swapped + service restarted -----
      # (generated below via home.file.text, not .source, since these need
      # config.services.apps.browser.notify_command interpolated in)

      # --- Qt (Dolphin): qt6ct colour schemes + config template ----------
      ".config/qt6ct/colors/day.conf".source = ../qt/colors/day.conf;
      ".config/qt6ct/colors/night.conf".source = ../qt/colors/night.conf;
    };

    home.file.".config/dunst/variants/night.conf".text = ''
      [global]
      rounded = yes
      origin = top-right
      monitor = 0
      alignment = left
      vertical_alignment = center
      width = 400
      height = 400
      notification_limit = 5
      scale = 0
      gap_size = 0
      progress_bar = true
      transparency = 0
      text_icon_padding = 0
      separator_color = frame
      sort = yes
      idle_threshold = 120
      line_height = 0
      markup = full
      show_age_threshold = 60
      ellipsize = middle
      ignore_newline = no
      stack_duplicates = true
      sticky_history = yes
      history_length = 20
      always_run_script = true
      corner_radius = 10
      follow = mouse
      font = Source Sans Pro 10
      format = "<b>%s</b>\n%b"
      frame_color = "#232323"
      frame_width = 1
      offset = 15x15
      horizontal_padding = 10
      icon_position = left
      icon_theme = "Papirus-Dark"
      indicate_hidden = yes
      min_icon_size = 0
      max_icon_size = 64
      mouse_left_click = do_action, close_current
      mouse_middle_click = close_current
      mouse_right_click = close_all
      padding = 10
      plain_text = no
      separator_height = 2
      show_indicators = yes
      shrink = no
      word_wrap = yes
      browser = "${config.services.apps.browser.notify_command}"

      [fullscreen_delay_everything]
      fullscreen = delay

      [urgency_critical]
      background = "#d64e4e"
      foreground = "#f0e0e0"

      [urgency_low]
      background = "#232323"
      foreground = "#2596be"

      [urgency_normal]
      background = "#1e1e2a"
      foreground = "#2596be"
    '';

    home.file.".config/dunst/variants/day.conf".text = ''
      [global]
      rounded = yes
      origin = top-right
      monitor = 0
      alignment = left
      vertical_alignment = center
      width = 400
      height = 400
      notification_limit = 5
      scale = 0
      gap_size = 0
      progress_bar = true
      transparency = 0
      text_icon_padding = 0
      separator_color = frame
      sort = yes
      idle_threshold = 120
      line_height = 0
      markup = full
      show_age_threshold = 60
      ellipsize = middle
      ignore_newline = no
      stack_duplicates = true
      sticky_history = yes
      history_length = 20
      always_run_script = true
      corner_radius = 10
      follow = mouse
      font = Source Sans Pro 10
      format = "<b>%s</b>\n%b"
      frame_color = "#d0d0d0"
      frame_width = 1
      offset = 15x15
      horizontal_padding = 10
      icon_position = left
      icon_theme = "Papirus"
      indicate_hidden = yes
      min_icon_size = 0
      max_icon_size = 64
      mouse_left_click = do_action, close_current
      mouse_middle_click = close_current
      mouse_right_click = close_all
      padding = 10
      plain_text = no
      separator_height = 2
      show_indicators = yes
      shrink = no
      word_wrap = yes
      browser = "${config.services.apps.browser.notify_command}"

      [fullscreen_delay_everything]
      fullscreen = delay

      [urgency_critical]
      background = "#e57373"
      foreground = "#3a0a0a"

      [urgency_low]
      background = "#f0f0f0"
      foreground = "#1a6f96"

      [urgency_normal]
      background = "#fafafa"
      foreground = "#1a6f96"
    '';

    home.file.".config/hypr/scripts/theme-mode/apply-mode.sh" = {
      executable = true;
      text = ''
        #!${bash_bin}
        # Usage: apply-mode.sh DAY|NIGHT
        set -u
        MODE="''${1:-}"
        if [ "$MODE" != "DAY" ] && [ "$MODE" != "NIGHT" ]; then
          echo "apply-mode.sh: usage: apply-mode.sh DAY|NIGHT" >&2
          exit 1
        fi
        LOWER=$([ "$MODE" = "DAY" ] && echo "day" || echo "night")

        echo "$LOWER" > "${home}/.cache/theme-mode"

        ${optionalString themes_enabled ''
          # GTK — GTK4/libadwaita apps (Nautilus) follow color-scheme alone;
          # GTK3 apps (Thunar) need the adw-gtk3(-dark) theme name too.
          if [ "$MODE" = "DAY" ]; then
            ${dconf_bin} write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
            ${dconf_bin} write /org/gnome/desktop/interface/gtk-theme "'adw-gtk3'"
          else
            ${dconf_bin} write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
            ${dconf_bin} write /org/gnome/desktop/interface/gtk-theme "'adw-gtk3-dark'"
          fi
        ''}

        # Hyprland borders — live, no restart needed.
        if [ "$MODE" = "DAY" ]; then
          ${hyprctl_bin} keyword general:col.active_border "rgba(2a9df4ee) rgba(6db56aff) 45deg"
          ${hyprctl_bin} keyword general:col.inactive_border "rgba(c9c9c9aa)"
        else
          ${hyprctl_bin} keyword general:col.active_border "rgba(33ccffee) rgba(aae5a4ff) 45deg"
          ${hyprctl_bin} keyword general:col.inactive_border "rgba(595959aa)"
        fi

        ${optionalString waybar_enabled ''
          ${cp_bin} -f "${home}/.config/waybar/colors-$LOWER.css" "${home}/.config/waybar/colors.css"
          ${systemctl_bin} --user try-restart waybar.service 2>/dev/null || true
        ''}

        ${optionalString hyprpanel_enabled ''
          # Best-effort: hyprpanel's own accent/colours are baked in at build
          # time by home-manager, so this doesn't repaint it — it rides along
          # on the GTK color-scheme change above, which covers it partially
          # since it's GTK-based under the hood. Flagging this as the one
          # weak link in the chain; a proper fix needs hyprpanel's own
          # runtime theme-reload mechanism, which wasn't confirmed.
          true
        ''}

        ${optionalString wofi_enabled ''
          ${cp_bin} -f "${home}/.config/wofi/style-$LOWER.css" "${home}/.config/wofi/style.css"
        ''}

        ${optionalString wlogout_enabled ''
          ${cp_bin} -f "${home}/.config/wlogout/colors-$LOWER.css" "${home}/.config/wlogout/colors.css"
        ''}

        ${optionalString dunst_enabled ''
          ${cp_bin} -f "${home}/.config/dunst/variants/$LOWER.conf" "${home}/.config/dunst/dunstrc"
          ${systemctl_bin} --user try-restart dunst.service 2>/dev/null || true
        ''}

        # Qt (Dolphin, etc.) — takes effect next launch, no restart needed.
        ${mkdir_bin} -p "${home}/.config/qt6ct"
        {
          echo "[Appearance]"
          echo "color_scheme_path=${home}/.config/qt6ct/colors/$LOWER.conf"
          echo "custom_palette=true"
          echo "style=Fusion"
        } > "${home}/.config/qt6ct/qt6ct.conf"
      '';
    };

    home.file.".config/hypr/scripts/theme-mode/toggle-mode.sh" = {
      executable = true;
      text = ''
        #!${bash_bin}
        # Manually flips the current mode. Not undone until the next real
        # sunrise/sunset, since the automatic loop only wakes then.
        set -u
        APPLY="${home}/.config/hypr/scripts/theme-mode/apply-mode.sh"
        CURRENT=$(${cat_bin} "${home}/.cache/theme-mode" 2>/dev/null || echo "night")
        if [ "$CURRENT" = "day" ]; then
          "$APPLY" NIGHT
        else
          "$APPLY" DAY
        fi
      '';
    };

    home.file.".config/hypr/scripts/theme-mode/day-night-loop.sh" = {
      executable = true;
      text = ''
        #!${bash_bin}
        # Same structure as hyprpaper's wallpaper.sh loop — sets the current
        # mode immediately, then blocks until each real sunrise/sunset.
        LAT="${cfg.latitude}"
        LON="${cfg.longitude}"
        APPLY="${home}/.config/hypr/scripts/theme-mode/apply-mode.sh"

        day_night=$(${sunwait_bin} poll civil "$LAT" "$LON")

        if [ "$day_night" = "DAY" ]; then
          next="set"
          "$APPLY" DAY
        else
          next="rise"
          "$APPLY" NIGHT
        fi

        while true; do
          ${sunwait_bin} wait civil "$next" "$LAT" "$LON"
          if [ "$next" = "rise" ]; then
            "$APPLY" DAY
            next="set"
          else
            "$APPLY" NIGHT
            next="rise"
          fi
        done
      '';
    };

    systemd.user.services.theme-day-night = {
      Unit = {
        Description = "Auto theme switcher (sun-based) for GTK/Qt/bar/dunst/hyprland";
        After = [ "graphical-session.target" "hyprland-session.target" ];
        Wants = [ "hyprland-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${bash_bin} ${home}/.config/hypr/scripts/theme-mode/day-night-loop.sh";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
