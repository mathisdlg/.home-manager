{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.desktop.themes.themes;
in
{
  options.services.desktop.themes.themes.enable = mkEnableOption "Enable themes.";

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

    # adw-gtk3 rather than the previous "Nordzy-dark" name: that name had no
    # matching theme package actually installed anywhere (only the cursor
    # theme was), so it likely wasn't rendering as intended. adw-gtk3 is a
    # real, maintained GTK3 port of Adwaita/Adwaita-dark, with both a light
    # and dark variant — needed for day/night switching (see
    # ../day_night/day_night.nix) and for GTK3 apps (Thunar) to actually
    # follow it.
    gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };

      # adw-gtk3 only ships a GTK3 theme — it has nothing to give GTK4 apps,
      # which is also why this needs to be explicit: home-manager warns
      # that gtk.gtk4.theme's default is moving from "inherit gtk.theme" to
      # null, and inheriting adw-gtk3(-dark) as a *GTK4* theme name isn't
      # meaningful anyway. GTK4/libadwaita apps (Nautilus) follow the
      # color-scheme dconf key alone instead — see day_night.nix.
      gtk4.theme = null;
    };

    fonts.fontconfig.enable = true;

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        cursor-theme = "Nordzy-cursors";
        cursor-size = 24;
        gtk-theme = "adw-gtk3-dark";

        enable-animations = false;
        color-scheme = "prefer-dark";
      };
    };
  };
}
