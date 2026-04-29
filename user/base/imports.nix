{ 
  config, 
  pkgs, 
  unstablePkgs, 
  ... 
}:
{
  imports = [
    ../art/blender/blender.nix
    ../art/darktable/darktable.nix
    ../art/gimp/gimp.nix
    ../art/gphoto2/gphoto2.nix
    ../art/imagemacick/imagemagick.nix
    ../art/krita/krita.nix

    ../baobab/baobab.nix

    ../browser/brave/brave.nix
    ../browser/firefox/firefox.nix
    ../browser/firefox/firefox-dev.nix

    ../cad/freecad/freecad.nix
    ../cad/kicad/kicad.nix
    ../cad/prusa_slicer/prusa_slicer.nix

    ../communication/thunderbird/thunderbird.nix

    ../editor/libreoffice/libreoffice.nix
    ../editor/vscodium/vscodium.nix
    ../editor/neovim/neovim.nix

    ../games/beammp/beammp.nix
    ../games/epic-games/epic-games.nix
    ../games/puzzles/puzzles.nix
    ../games/minecraft/minecraft.nix
    ../games/mines/mines.nix
    ../games/osu/osu.nix

    ../ia/tabby/tabby.nix

    ../keepass/keepass.nix

    ../media_player/mpv/mpv.nix
    ../media_player/playerctl/playerctl.nix
    ../media_player/yt-dlp/yt-dlp.nix

    ../programming/python/python.nix
    ../programming/swift/swift.nix

    ../screenshare/screenshare.nix

    ../scripts/scripts.nix

    ../system-monitor/gnome-system-monitor/gnome-system-monitor.nix
    ../system-monitor/mission-center/mission-center.nix

    ../terminal/shell/shell.nix
    ../terminal/kitty/kitty.nix

    ../themes/fonts/jetbrains/jetbrains.nix
    ../themes/fonts/nerd/nerd.nix
    ../themes/fonts/noto/noto.nix
    ../themes/themes/themes.nix

    ../usb/usb.nix

    ../wm/hyprland/hyprland.nix
  ];

  services = {
    art = {
      blender.enable = true;
      darktable.enable = true;
      gimp.enable = true;
      gphoto2.enable = true;
      imagemagick.enable = true;
      krita.enable = true;
    };

    baobab.enable = true;

    browser = {
      brave.enable = true;
      firefox.enable = false;
      firefox-dev.enable = true;
    };

    cad = {
      freecad.enable = true;
      kicad.enable = true;
      prusa_slicer.enable = true;
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
      beammp.enable = true;
      epic-games.enable = true;
      puzzles.enable = true;
      minecraft.enable = true;
      mines.enable = true;
      osu.enable = true;
    };

    ia = {
      tabby.enable = false;
    };

    keepassxc.enable = true;

    media_player = {
      mpv.enable = true;
      playerctl.enable = true;
      yt-dlp.enable = true;
    };

    programming = {
      python.enable = true;
      swift.enable = false;
    };

    screenshare.screenshare.enable = true;

    scipts.enable = true;

    system-monitor = {
      gnome-system-monitor.enable = false;
      mission-center.enable = true;
    };

    terminal = {
      bash.enable = true;
      kitty.enable = true;
    };

    themes = {
      fonts = {
        jetbrains.enable = true;
        nerd.enable = true;
        noto.enable = true;
      };
      themes.enable = true;
    };

    usb.enable = true;

    hyprland.enable = true;
  };
}
