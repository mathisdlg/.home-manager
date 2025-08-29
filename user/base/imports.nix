{ config, pkgs, ... }:
{
  imports = [
    ../art/blender/blender.nix
    ../art/krita/krita.nix
    ../art/gimp/gimp.nix

    ../baobab/baobab.nix

    ../browser/brave/brave.nix
    ../browser/firefox/firefox.nix
    ../browser/firefox/firefox-dev.nix

    ../communication/thunderbird/thunderbird.nix

    ../editor/libreoffice/libreoffice.nix
    ../editor/vscodium/vscodium.nix
    ../editor/neovim/neovim.nix

    ../games/epic-games/epic-games.nix
    ../games/puzzles/puzzles.nix
    ../games/mines/mines.nix
    ../games/osu/osu.nix
    ../games/steam/steam.nix

    ../ia/tabby/tabby.nix

    ../keepass/keepass.nix

    ../media_player/mpv/mpv.nix

    ../programming/python/python.nix
    ../programming/swift/swift.nix

    ../screenshare/screenshare.nix

    ../system-monitor/gnome-system-monitor/gnome-system-monitor.nix
    ../system-monitor/mission-center/mission-center.nix

    ../terminal/shell/shell.nix
    ../terminal/kitty/kitty.nix

    ../themes/themes.nix

    ../wm/hyprland/hyprland.nix
  ];

  services = {
    art = {
      blender.enable = true;
      krita.enable = true;
      gimp.enable = true;
    };

    baobab.enable = true;

    browser = {
      brave.enable = true;
      firefox.enable = false;
      firefox-dev.enable = true;
    };

    communication = {
      thunderbird.enable = true;
    };

    component = {
    };

    editor = {
      libreoffice.enable = true;
      vscodium = {
        enable = true;
        package = pkgs.vscode;
      };
      neovim.enable = true;
    };

    games = {
      epic-games.enable = false;
      puzzles.enable = true;
      mines.enable = true;
      osu.enable = true;
      steam.enable = false;
    };

    ia = {
      tabby.enable = false;
    };

    keepassxc.enable = true;

    mpv.enable = true;

    programming = {
      python.enable = true;
      swift.enable = false;
    };

    screenshare.screenshare.enable = true;

    system-monitor = {
      gnome-system-monitor.enable = false;
      mission-center.enable = true;
    };

    terminal = {
      bash.enable = true;
      kitty.enable = true;
    };

    themes.enable = true;

    hyprland.enable = true;
  };
}
