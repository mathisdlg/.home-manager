{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.hyprland;
in
{
  options.services.hyprland.enable = mkEnableOption "Enable hyprland.";

  imports = [
    ./imports.nix
    ./config.nix
  ];

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        wl-clipboard
      ];
    };

    wayland.windowManager.hyprland = {
      enable = true;

      settings = {
        exec-once = [
          "waybar"
          "hypridle"
        ];

        env = [
          "QT_QPA_PLATFORMTHEME,qt6ct"
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_DESKTOP,hyprland"
          "ELECTRON_OZONE_PLATFORM_HINT,auto"
          "MOZ_ENABLE_WAYLAND,1"
          "GDK_BACKEND,wayland"
        ];

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        master = {
          new_on_top = true;
        };

        gestures = {
          workspace_swipe = true;
        };

        misc = {
          force_default_wallpaper = -1;
        };

        windowrulev2 = "suppressevent maximize, class:.*";
      };
    };
  };
}
