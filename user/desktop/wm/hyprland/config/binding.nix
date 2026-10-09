{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let
  # Prefer a package's declared main program over its attribute name — e.g.
  # vscodium's package exposes "codium", not "code". Metadata-only (no build
  # triggered), so this doesn't force-install a package whose module is off.
  binOf = pkg: pkg.meta.mainProgram or pkg.pname;
in
{
  config = {
    wayland.windowManager.hyprland = {
      settings = {
        "$mainMod" = "SUPER";
        "$shiftMod" = "SUPER_SHIFT";

        # Applications — commands are derived from each app's own module
        # (package choice, or which of several alternatives is enabled)
        # instead of being retyped here, so they can't silently drift out of
        # sync with it (this file has had to be hand-fixed after browser and
        # code-editor package changes before — see git history).
        "$terminal" = binOf pkgs.kitty;
        "$fileManager" = config.services.apps.files.command;
        "$menu" = "${binOf pkgs.wofi} --show drun";
        "$browser" = config.services.apps.browser.command;
        "$musicPlayer" = "${binOf pkgs.mpv} --shuffle --loop-playlist --no-video --input-ipc-server=/tmp/mpvsocket ${globals.musicDir}";
        "$lock" = binOf pkgs.wlogout;
        "$colorPicker" = "${binOf pkgs.hyprpicker} -a -r -n";
        "$codeEditor" = binOf config.services.apps.editor.vscodium.package;
        "$discord" = "${binOf pkgs.discord} & disown";

        bind = [
          "$mainMod, RETURN, exec, $terminal"
          "ALT, F4, killactive,"
          "$mainMod, E, exec, $fileManager"
          "$mainMod, V, togglefloating,"
          "bindr=SUPER, SUPER_L, exec, $menu"
          "$mainMod, J, layoutmsg, togglesplit"
          "CTRL SHIFT, Escape, exec, ${config.services.utils.system_monitor.command}"
          "$mainMod, L, exec, $lock"
          "$mainMod SHIFT, N, exec, ${config.services.desktop.themes.day_night.toggle_command}"
          "$mainMod, T, togglegroup"

          # Move in groups with mainMod + SHIFT + [arrow keys]
          "$mainMod SHIFT, right, changegroupactive, f"
          "$mainMod SHIFT, left, changegroupactive, b"
          "ALT, TAB, changegroupactive, f"
          "ALT SHIFT, TAB, changegroupactive, b"

          # Move focus with mainMod + arrow keys
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"

          # Switch workspaces with mainMod + [0-9]
          "$mainMod, ampersand, workspace, 1"
          "$mainMod, eacute, workspace, 2"
          "$mainMod, quotedbl, workspace, 3"
          "$mainMod, apostrophe, workspace, 4"
          "$mainMod, parenleft, workspace, 5"
          "$mainMod, minus, workspace, 6"
          "$mainMod, egrave, workspace, 7"
          "$mainMod, underscore, workspace, 8"
          "$mainMod, ccedilla, workspace, 9"
          "$mainMod, agrave, workspace, 10"
          "$mainMod, f1, workspace, 11"
          "$mainMod, f2, workspace, 12"
          "$mainMod, f3, workspace, 13"
          "$mainMod, f4, workspace, 14"
          "$mainMod, f5, workspace, 15"
          "$mainMod, f6, workspace, 16"
          "$mainMod, f7, workspace, 17"
          "$mainMod, f8, workspace, 18"
          "$mainMod, f9, workspace, 19"
          "$mainMod, f10, workspace, 20"

          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          "$mainMod SHIFT, ampersand, movetoworkspace, 1"
          "$mainMod SHIFT, eacute, movetoworkspace, 2"
          "$mainMod SHIFT, quotedbl, movetoworkspace, 3"
          "$mainMod SHIFT, apostrophe, movetoworkspace, 4"
          "$mainMod SHIFT, parenleft, movetoworkspace, 5"
          "$mainMod SHIFT, minus, movetoworkspace, 6"
          "$mainMod SHIFT, egrave, movetoworkspace, 7"
          "$mainMod SHIFT, underscore, movetoworkspace, 8"
          "$mainMod SHIFT, ccedilla, movetoworkspace, 9"
          "$mainMod SHIFT, agrave, movetoworkspace, 10"
          "$mainMod SHIFT, f1, movetoworkspace, 11"
          "$mainMod SHIFT, f2, movetoworkspace, 12"
          "$mainMod SHIFT, f3, movetoworkspace, 13"
          "$mainMod SHIFT, f4, movetoworkspace, 14"
          "$mainMod SHIFT, f5, movetoworkspace, 15"
          "$mainMod SHIFT, f6, movetoworkspace, 16"
          "$mainMod SHIFT, f7, movetoworkspace, 17"
          "$mainMod SHIFT, f8, movetoworkspace, 18"
          "$mainMod SHIFT, f9, movetoworkspace, 19"
          "$mainMod SHIFT, f10, movetoworkspace, 20"

          # Example special workspace (scratchpad)
          # bind=$mainMod, S, togglespecialworkspace, magic
          # bind=$mainMod SHIFT, S, movetoworkspace, special:magic

          # Scroll through existing workspaces with mainMod + scroll
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"

          # Scroll through existing workspaces with mainMod + Control
          "$mainMod CTRL, right, workspace, e+1"
          "$mainMod CTRL, left, workspace, e-1"

          # Control the luminosity of the screen
          ",XF86MonBrightnessDown,exec,brightnessctl set 5%-"
          ",XF86MonBrightnessUp,exec,brightnessctl set +5%"

          # Control the volume of the system
          ",XF86AudioMute, exec, amixer -q sset Master toggle"
          ",XF86AudioLowerVolume, exec, amixer -q sset Master 2%-"
          ",XF86AudioRaiseVolume, exec, amixer -q sset Master 2%+"
          
          # Control microphone volume
          ",XF86AudioMicMute, exec, amixer -q sset Capture toggle"

          # Dismiss all dunst notification
          "$mainMod, comma, exec, dunstctl close-all"

          # Open applications
          "$mainMod, M, exec, $musicPlayer"
          "$mainMod, W, exec, $browser"

          # Color Picker
          "$mainMod, P, exec, $colorPicker"

          # Open code editor
          "$mainMod, C, exec, $codeEditor"

          # Open discord
          "$mainMod, D, exec, $discord"

          # Music controller for mpv
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioStop, exec, playerctl stop"

          # Screenshot
          ", Print, exec, grimblast copysave active"
          "$mainMod SHIFT, s, exec, grimblast --freeze copysave area"
        ];

        bindm = [
          # Move/resize windows with mainMod + LMB/RMB and dragging
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
      };
    };
  };
}