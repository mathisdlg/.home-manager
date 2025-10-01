{
  config,
  pkgs,
  lib,
  ...
}: {
  config = {
    wayland.windowManager.hyprland = {
      settings = {
        input = {
          kb_layout="fr";
          # kb_variant=;
          # kb_model=;
          # kb_options=;
          # kb_rules=;

          follow_mouse=1;

          touchpad={
            natural_scroll=true;
          };

          accel_profile="flat";

          sensitivity=0.8; # -1.0 - 1.0, 0 means no modification.
        };
      };
    };
  };
}