{ config, pkgs, ... }:
{
  imports = [
    ../../components/hypr/hyprlock/hyprlock.nix
    ../../components/hypr/hypridle/hypridle.nix
    ../../components/hypr/hyprpicker/hyprpicker.nix

    ../../components/notifications/dunst/dunst.nix

    ../../components/waybar/waybar.nix

    ../../components/wlogout/wlogout.nix

    ../../components/wofi/wofi.nix
  ];

  services = {
    component = {
      hypr = {
        hyprlock.enable = true;
        hypridle.enable = true;
        hyprpicker.enable = true;
      };

      notifications = {
        dunst.enable = true;
      };

      waybar.enable = true;

      wlogout.enable = true;

      wofi.enable = true;
    };
  };
}
