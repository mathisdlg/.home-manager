{ config, pkgs, ... }:
{
  imports = [
    ../../components/hypr/hypridle/hypridle.nix
    ../../components/hypr/hyprlock/hyprlock.nix
    ../../components/hypr/hyprpanel/hyprpanel.nix
    ../../components/hypr/hyprpaper/hyprpaper.nix
    ../../components/hypr/hyprpicker/hyprpicker.nix

    ../../components/notifications/dunst/dunst.nix

    ../../components/waybar/waybar.nix

    ../../components/wlogout/wlogout.nix

    ../../components/wofi/wofi.nix
  ];

  services = {
    component = {
      hypr = {
        hypridle.enable = true;
        hyprlock.enable = true;
        hyprpanel.enable = true;
        hyprpicker.enable = true;
        hyprpaper.enable = true;
      };

      notifications = {
        dunst.enable = true;
      };

      waybar.enable = false;

      wlogout.enable = true;

      wofi.enable = true;
    };
  };
}
