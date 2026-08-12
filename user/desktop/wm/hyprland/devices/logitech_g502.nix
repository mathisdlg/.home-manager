{
  config,
  pkgs,
  lib,
  ...
}: {
  config = {
    wayland.windowManager.hyprland = {
      settings = {
        device = {
            name="logitech-g502-hero-se";
            sensitivity=-0.55;
            accel_profile="flat";
        };
      };
    };
  };
}