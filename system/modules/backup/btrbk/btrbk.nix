{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.module.backup.btrbk;
in
{
  options.services.module.backup.btrbk = {
    enable = mkEnableOption {
      description = "Enable btrbk backups";
    };

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
        description = "Path to source data directory (must be a btrfs volume)";
      };

      target = mkOption {
        type = types.path;
        default = "/disks/save";
        description = "Path to local backup target directory (must be a btrfs volume)";
      };

      sshTarget = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Optional SSH target (e.g. ssh://nas:/backup)";
      };
    };

    interval = mkOption {
      type = types.str;
      default = "*-*-* 00/3:00:00"; # Every 3 hours
      description = "Backup schedule (systemd timer format or daily/hourly/etc.)";
    };
  };

  config = mkIf cfg.enable {

    # Ensure directories exist
    systemd.tmpfiles.rules = [
      "d ${cfg.path.data}/.snapshots 0755 root root -"
      "d ${cfg.path.target}/data 0755 root root -"
    ];

    # btrbk service
    services.btrbk = {
      niceness = cfg.performance.niceness;
      ioSchedulingClass = cfg.performance.ioSchedulingClass;

      instances."main" = {
        onCalendar = cfg.interval;

        settings = {
          timestamp_format = "long";
          snapshot_preserve = "24h 7d 4w 12m";
          snapshot_preserve_min = "2d";
          target_preserve = "7d 4w 12m";

          volume."${cfg.path.data}" = {
            subvolume."." = { snapshot_dir = ".snapshots"; };
          };

          # merge optional SSH target using // syntax
          target = {
            "${cfg.path.target}" = { subvolume = "data"; };
          } // optionalAttrs (cfg.path.sshTarget != null) {
            "${cfg.path.sshTarget}" = { subvolume = "data"; };
          };
        };
      };
    };
  };
}