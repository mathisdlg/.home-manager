{
  config,
  pkgs,
  lib,
  ...
}: {
  config = {
    wayland.windowManager.hyprland = {
      settings = {
        monitor = [
          "HDMI-A-1, 1920x1080@60, 2560x180, 1"
          "DP-3, 2560x1440@179.95, 0x0, 1"
        ];
      };
    };
  };
}
