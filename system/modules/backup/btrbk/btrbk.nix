{ config, lib, pkgs, ... }:

let
  cfg = config.module.backup.btrbk;
in
{
  options.module.backup.btrbk = {
    enable = lib.types.mkEnableOption {
      description = "Enable btrbk backups";
    };

    performance = {
      niceness = lib.types.mkOption {
        type = lib.types.ints.between (-20) 19;
        default = 19;
        description = "CPU niceness for btrbk service";
      };

      ioSchedulingClass = lib.types.mkOption {
        type = lib.types.enum [ "idle" "best-effort" "realtime" ];
        default = "idle";
        description = "I/O scheduling class for btrbk service";
      };
    };

    path = {
      data = lib.types.mkOption {
        type = lib.types.path;
        default = "/data";
        description = "Path to source data directory (must be a btrfs volume)";
      };

      target = lib.types.mkOption {
        type = lib.types.path;
        default = "/save";
        description = "Path to local backup target directory (must be a btrfs volume)";
      };

      sshTarget = lib.types.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional SSH target (e.g. ssh://nas:/backup)";
      };
    };

    interval = lib.types.mkOption {
      type = lib.types.str;
      default = "daily";
      description = "Backup schedule (systemd timer format or daily/hourly/etc.)";
    };
  };

  config = lib.mkIf cfg.enable {

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
          } // lib.optionalAttrs (cfg.path.sshTarget != null) {
            "${cfg.path.sshTarget}" = { subvolume = "data"; };
          };
        };
      };
    };
  };
}