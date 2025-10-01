{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.themes;
in
{
  options.services.themes.enable = mkEnableOption "Enable themes.";

  imports = [
    ./background/background.nix
  ];

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        nordzy-cursor-theme
      ];

      pointerCursor = {
        gtk.enable = lib.mkForce true;
        x11.enable = lib.mkForce true;
        name = lib.mkForce "Nordzy-cursors";
        size = lib.mkForce 24;

        package = pkgs.nordzy-cursor-theme;
      };
    };

    fonts.fontconfig.enable = true;

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        cursor-theme = "Nordzy-cursors";
        cursor-size = 24;
        gtk-theme = "Nordzy-dark";

        enable-animations = false;
        color-scheme = "prefer-dark";
      };
    };
  };
}
