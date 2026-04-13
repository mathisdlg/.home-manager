{ config, pkgs, ... }:
{
  imports = [
    ./modules/backup/btrbk/btrbk.nix

    ./modules/bootloader/bootloader.nix
    
    ./modules/openrgb/openrgb.nix

    ./modules/zram/zram.nix
  ];

  services = {
    module = {
      backup.btrbk = {
        enable = true;

        # ── Sources ──────────────────────────────────────────────────
        sources = [
          # Whole btrfs disk — subvolumes = [] snapshots everything
          {
            mountPoint  = "/disks/data";
            subvolumes  = [ "." ];
            snapshotDir = ".snapshots";
            # preserveMin / preserve are optional: falls back to retention.*
          }

          # Selected subvolumes only, with a custom per-source retention
          # {
          #   mountPoint  = "/";
          #   subvolumes  = [ "home" "var/lib" ];
          #   snapshotDir = ".snapshots";
          #   preserveMin = "1d";
          #   preserve    = "7d 4w";
          # }
        ];

        # ── Target ───────────────────────────────────────────────────
        target = {
          path        = "/disks/save/btrbk";  # must be on a btrfs filesystem
          preserveMin = "no";
          preserve    = "30d 10w 6m";
        };

        # ── Retention (global defaults for local snapshots) ──────────
        retention = {
          preserveMin = "2d";
          preserve    = "14d 4w";
        };

        # ── Scheduling ───────────────────────────────────────────────
        scheduling = {
          calendar   = "daily";   # or "*-*-* 02:30:00"
          persistent = true;      # catch up on missed runs after boot
        };

        # ── Performance ──────────────────────────────────────────────
        performance = {
          niceness = 19;         # CPU: lowest priority
          ioClass  = "idle";     # I/O: only when disk is free
          ioLevel  = 7;          # gentlest level within the class
        };

        # ── Extra btrbk.conf directives ──────────────────────────────
        extraConfig = ''
          stream_compress zstd
        '';
      };
    };

    bootloader-mod.enable = true;

    rgb.openrgb = {
        enable = false;
    };

    zram = {
        enable = true;
        size = 100;
    };
  };
}