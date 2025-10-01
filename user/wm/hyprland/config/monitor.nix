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
          "DMI-A-1, 1024x600, 448x1081, 1"
          "desc:Samsung Electric Company T22B350, 1920x1080@60, 1920x0, 1"
          "DP-3, 1920x1080@60, 0x0, 1"
        ];
      };
    };
  };
}
