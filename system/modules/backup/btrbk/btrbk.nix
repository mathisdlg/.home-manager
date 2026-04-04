{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.module.backup.btrbk;
  host = config.networking.hostName;
in
{
  options.services.module.backup.btrbk = {

    enable = mkEnableOption "Enable btrbk backups";

    performance = {
      niceness = mkOption {
        type = types.ints.between (-20) 19;
        default = 19;
        description = "CPU niceness for btrbk service (-20 is highest priority, 19 is lowest)";
      };

      ioSchedulingClass = mkOption {
        type = types.enum [ "idle" "best-effort" "realtime" ];
        default = "idle";
        description = "I/O scheduling class for btrbk service";
      };
    };

    path = {
      data = mkOption {
        type = types.path;
        default = "/disks/data";
        description = "Source data directory (btrfs)";
      };

      target = mkOption {
        type = types.path;
        default = "/disks/save";
        description = "Local backup target (btrfs)";
      };

      sshTarget = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Optional SSH target (e.g. ssh://nas:/backup)";
      };
    };

    interval = mkOption {
      type = types.str;
      default = "daily";
      description = "Backup schedule (systemd timer format)";
    };
  };

  config = mkIf cfg.enable {

    ########################################
    # Init service
    ########################################
    systemd.services.btrbk-init = {
      description = "Initialize btrbk subvolumes";

      after = [ "disks-data.mount" "disks-save.mount" ];
      requires = [ "disks-data.mount" "disks-save.mount" ];

      wantedBy = [ "multi-user.target" ];

      path = [ pkgs.btrfs-progs ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        set -e

        echo "Initializing btrbk layout..."

        # Source snapshot dir (must be subvolume)
        if ! btrfs subvolume show ${cfg.path.data}/.snapshots >/dev/null 2>&1; then
          echo "Creating snapshot subvolume..."
          btrfs subvolume create ${cfg.path.data}/.snapshots
        fi

        # Target structure
        mkdir -p ${cfg.path.target}/${host}

        if ! btrfs subvolume show ${cfg.path.target}/${host}/data >/dev/null 2>&1; then
          echo "Creating target subvolume..."
          btrfs subvolume create ${cfg.path.target}/${host}/data
        fi
      '';
    };

    ########################################
    # btrbk config
    ########################################
    services.btrbk = {
      niceness = cfg.performance.niceness;
      ioSchedulingClass = cfg.performance.ioSchedulingClass;

      instances.main = {
        onCalendar = cfg.interval;

        settings = {
          timestamp_format = "long";

          snapshot_preserve = "24h 7d 4w 12m";
          snapshot_preserve_min = "2d";
          target_preserve = "7d 4w 12m";

          stream_compress = "zstd";
          stream_compress_threads = "4";
          stream_compress_adapt = "yes";

          volume."${cfg.path.data}" = {
            subvolume."." = {
              snapshot_dir = ".snapshots";
            };
          };

          target = {
            "${cfg.path.target}/${host}" = {
              subvolume = "/data";
            };
          } // optionalAttrs (cfg.path.sshTarget != null) {
            "${cfg.path.sshTarget}/${host}" = {
              subvolume = "/data";
            };
          };
        };
      };
    };

    ########################################
    # Ordering
    ########################################
    systemd.services.btrbk-main = {
      after = [
        "btrbk-init.service"
        "disks-data.mount"
        "disks-save.mount"
        "local-fs.target"
      ];
      requires = [
        "btrbk-init.service"
        "disks-data.mount"
        "disks-save.mount"
      ];
    };

    ########################################
    # Timer
    ########################################
    systemd.timers.btrbk-main.timerConfig = {
      Persistent = true;
      OnBootSec = "3min";
    };
  };
}