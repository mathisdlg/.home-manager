{ config, pkgs, ... }:
{
  imports = [
    ./config/animation.nix
    ./config/binding.nix
    ./config/decoration.nix
    ./config/general.nix
    ./config/input.nix
    ./config/monitor.nix

    ./devices/logitech_g502.nix

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
        hyprpaper = {
          enable = true;
          latitude = 45.78;
          longitude = 3.1;
          wallpapersDir = "${config.home.homeDirectory}/.wallpapers";
        }
      };

      notifications = {
        dunst.enable = false;
      };

      waybar.enable = false;

      wlogout.enable = true;

      wofi.enable = true;
    };
  };
}
