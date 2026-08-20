# modules.nix
#
# Single source of truth for which custom modules (the ones under user/ and
# system/modules/, each declaring its own `options.services.<...>`) are
# enabled, and for the small option values that go with them — a default
# browser, day/night coordinates, wallpaper dirs, btrbk retention, etc.
#
# Companion to globals.nix: that file is "who/where" (identity, paths,
# locale); this one is "what's turned on, and how". Same delivery mechanism
# too — flake.nix imports this file and passes the result through as
# `module_config` via `specialArgs` (NixOS) / `extraSpecialArgs`
# (home-manager), so any module can read it by adding `module_config` to its
# function arguments, exactly like `globals`.
#
# This file itself sets nothing — it's plain data, not a NixOS/home-manager
# module. Three thin "wiring" files actually hand these values to the real
# `services.*` options your modules declare:
#   - user/base/imports.nix                -> services = module_config.user;
#   - user/desktop/wm/hyprland/imports.nix -> services.desktop.components = module_config.component;
#   - system/import.nix                    -> services = module_config.system;
# `component` is kept separate from `user` because it only makes sense once
# `user.desktop.wm.hyprland.enable` is true, and is wired from hyprland's
# own imports.nix rather than the base one.
#
# Shape rule #1: each key path here must match the `options.services.<path>`
# the corresponding module declares in its own .nix file — that's still the
# place to go to see what an option means or add a new one. Adding a brand
# new custom module: give it its usual `options.services.<path>` as before,
# then add the matching entry here instead of hardcoding it in one of the
# three wiring files above.
#
# Shape rule #2: under `user`, every key path also matches the module's
# location on disk — services.apps.browser.* lives under user/apps/browser/,
# services.utils.baobab under user/utils/baobab/, and so on. `component`
# below follows the same rule one level down: services.desktop.components.bar.*
# lives under user/desktop/components/bar/. Two exceptions:
#   - `user.dev.*` drops the module's own "programming" folder segment —
#     dev/ already says that; see user/dev/python/python.nix.
#   - `system.displayManager` wraps NixOS's own real
#     services.displayManager.<name> options (see
#     system/modules/display-manager/display-manager.nix) rather than an
#     option this repo declares itself, so it keeps NixOS's own spelling
#     and isn't nested under anything.
{ pkgs, globals }:
{
  # ---------------------------------------------------------------------
  # user/ — every custom home-manager module (except hyprland's own
  # components, see `component` below), nested to match user/apps/,
  # user/dev/, user/desktop/, user/utils/.
  # ---------------------------------------------------------------------
  user = {
    apps = {
      art = {
        blender.enable = false;
        darktable.enable = true;
        gimp.enable = false;
        gphoto2.enable = false;
        imagemagick.enable = false;
        krita.enable = false;
      };

      browser = {
        default = "brave";

        brave.enable = true;
        firefox.enable = false;
        firefox_dev.enable = false;
      };

      cad = {
        freecad.enable = false;
        kicad.enable = false;
        prusa_slicer.enable = false;
      };

      cloud.nextcloud.enable = false;

      communication = {
        discord.enable = false;
        thunderbird.enable = false;
      };

      editor = {
        libreoffice.enable = true;
        # No package override here — this keeps the module's own default
        # (pkgs.vscodium, open source). See user/apps/editor/vscodium/vscodium.nix.
        vscodium.enable = true;
        neovim.enable = true;
      };

      files = {
        default = "nautilus";

        dolphin.enable = false;
        nautilus.enable = true;
        thunar.enable = false;
      };

      games = {
        beammp.enable = false;
        heroic.enable = false;
        puzzles.enable = false;
        minecraft.enable = false;
        mines.enable = true;
        osu.enable = false;
      };

      ia.tabby.enable = false;

      media_player = {
        mpv.enable = true;
        playerctl.enable = true;
        yt_dlp.enable = true;
      };

      notes = {
        default = "joplin";

        joplin.enable = true;
        logseq.enable = false;
      };

      photos = {
        default = "loupe";

        loupe.enable = true;
        gwenview.enable = false;
        ristretto.enable = false;
      };

      security.keepassxc.enable = true;

      terminal = {
        bash.enable = true;
        kitty.enable = true;
      };
    };

    dev = {
      python.enable = true;
      swift.enable = false;
    };

    desktop = {
      wm.hyprland.enable = true;

      screenshare.screenshare.enable = true;

      themes = {
        fonts = {
          jetbrains.enable = true;
          nerd.enable = true;
          noto.enable = true;
        };

        day_night = {
          enable = true;
          latitude = "45.78N";
          longitude = "3.1E";
        };

        themes.enable = true;
      };
    };

    utils = {
      disk_usage = {
        default = "baobab";

        baobab.enable = true;
        filelight.enable = false;
        qdirstat.enable = false;
      };

      scripts.enable = true;

      system_monitor = {
        default = "mission_center";

        gnome_system_monitor.enable = false;
        mission_center.enable = true;
      };

      usb.enable = true;
    };
  };

  # ---------------------------------------------------------------------
  # Hyprland's own components — nested to match
  # user/desktop/components/<bar|session|wallpaper|picker|launcher|notifications>/.
  # Split out from `user` above because they're only meaningful when
  # `user.desktop.wm.hyprland.enable` is true, and are wired from hyprland's
  # own imports.nix rather than user/base/imports.nix.
  # ---------------------------------------------------------------------
  component = {
    bar = {
      default = "hyprpanel";

      waybar.enable = false;
      hyprpanel.enable = true;
    };

    session = {
      hypridle.enable = true;
      hyprlock.enable = true;
      wlogout.enable = true;
    };

    wallpaper.hyprpaper = {
      enable = true;
      latitude = "45.78N";
      longitude = "3.1E";
      wallpapers_dir = {
        day = "${globals.wallpaperDir}/day";
        night = "${globals.wallpaperDir}/night";
        both = "${globals.wallpaperDir}/both";
      };
    };

    picker.hyprpicker.enable = true;

    launcher.wofi.enable = true;

    notifications.dunst.enable = false;
  };

  # ---------------------------------------------------------------------
  # system/ — every custom NixOS module under system/modules/.
  # ---------------------------------------------------------------------
  system = {
    module.backup.btrbk = {
      enable = false;

      # ── Sources ──────────────────────────────────────────────────
      sources = [
        # Whole btrfs disk — subvolumes = [] snapshots everything
        {
          mount_point  = "/disks/data";
          subvolumes   = [ "." ];
          snapshot_dir = ".snapshots";
          # preserve_min / preserve are optional: falls back to retention.*
        }

        # Selected subvolumes only, with a custom per-source retention
        # {
        #   mount_point  = "/";
        #   subvolumes   = [ "home" "var/lib" ];
        #   snapshot_dir = ".snapshots";
        #   preserve_min = "1d";
        #   preserve     = "7d 4w";
        # }
      ];

      # ── Target ───────────────────────────────────────────────────
      target = {
        path         = "/disks/save/btrbk";  # must be on a btrfs filesystem
        preserve_min = "no";
        preserve     = "30d 10w 6m";
      };

      # ── Retention (global defaults for local snapshots) ──────────
      retention = {
        preserve_min = "2d";
        preserve     = "14d 4w";
      };

      # ── Scheduling ───────────────────────────────────────────────
      scheduling = {
        calendar   = "daily";   # or "*-*-* 02:30:00"
        persistent = true;      # catch up on missed runs after boot
      };

      # ── Performance ──────────────────────────────────────────────
      performance = {
        niceness = 19;         # CPU: lowest priority
        io_class = "idle";     # I/O: only when disk is free
        io_level = 7;          # gentlest level within the class
      };

      # ── Extra btrbk.conf directives ──────────────────────────────
      extra_config = ''
        stream_compress zstd
      '';
    };

    bootloader_mod.enable = true;

    # Exception to the shape rules above — see this file's header comment.
    displayManager.default = "gdm";

    rgb.openrgb.enable = false;

    zram = {
      enable = true;
      size = 100;
    };
  };
}
