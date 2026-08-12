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
          "eDP-1, 1920x1080, auto, 1"
          "desc:Samsung Electric Company SyncMaster H1ERC05595, preferred, auto-right, 1"
          "desc:Sentronic International Corp. 24 PIXEL VIEW, 1920x1080, auto-right, 1"
        ];
      };
    };
  };
}
