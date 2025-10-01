{
  config,
  pkgs,
  lib,
  ...
}: {
  config = {
    wayland.windowManager.hyprland = {
      settings = {
        "$mainMod" = "SUPER";
        "$shiftMod" = "SUPER_SHIFT";

        # Applications
        "$terminal" = "kitty";
        "$fileManager" = "nautilus";
        "$menu" = "wofi --show drun";
        "$browser" = "brave";
        "$musicPlayer" = "mpv --shuffle --loop-playlist --no-video --input-ipc-server=/tmp/mpvsocket /disks/data/Music/Musique";
        "$lock" = "wlogout";
        "$colorPicker" = "hyprpicker -a -r -n";
        "$codeEditor" = "code";
        "$discord" = "$browser --new-window https://discord.com/channels/@me & disown";

        bind = [
          "$mainMod, RETURN, exec, $terminal"
          "ALT, F4, killactive,"
          "$mainMod, ESCAPE, exit,"
          "$mainMod, E, exec, $fileManager"
          "$mainMod, V, togglefloating,"
          "$mainMod, SPACE, exec, $menu"
          "bindr=SUPER, SUPER_L, exec, $menu"
          "$mainMod, J, togglesplit,"
          "CTRL SHIFT, Escape, exec, missioncenter"
          "$mainMod, L, exec, $lock"
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
          ", XF86AudioNext, exec, echo 'playlist-next' | socat - /tmp/mpvsocket"
          ", XF86AudioPrev, exec, echo 'playlist-prev' | socat - /tmp/mpvsocket"
          ", XF86AudioPlay, exec, echo 'cycle pause' | socat - /tmp/mpvsocket"
          ", XF86AudioStop, exec, echo 'stop' | socat - /tmp/mpvsocket"

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