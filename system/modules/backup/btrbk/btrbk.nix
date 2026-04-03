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

    # Ensure directories exist
    systemd.tmpfiles.rules = [
      "d ${cfg.path.data}/.snapshots 0755 root root -"
      "d ${cfg.path.target}/${host}/data 0755 root root -"
    ];

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
            "${cfg.path.target}" = {
              subvolume = "/${host}/data";
            };
          } // optionalAttrs (cfg.path.sshTarget != null) {
            "${cfg.path.sshTarget}" = {
              subvolume = "/${host}/data"; # This path is bound to change based on the remote setup, adjust as needed
            };
          };
        };
      };
    };
  };
}