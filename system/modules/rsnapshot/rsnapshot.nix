{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.backup-rsnapshot;

  backupLines = concatMapStringsSep "\n" (src:
    "backup  ${src.path}/  ${src.name}/"
  ) cfg.sources;

  excludeArgs =
    if cfg.excludes == []
    then ""
    else "--exclude=" + concatStringsSep " --exclude=" cfg.excludes;

  mountPoints =
    concatStringsSep " " (map (s: s.path) cfg.sources) + " ${cfg.backupDir}";

in
{
  options.services.backup-rsnapshot = {
    enable = mkEnableOption "rsnapshot backup";

    backupDir = mkOption {
      type = types.str;
      default = "/mnt/backup";
    };

    sources = mkOption {
      type = types.listOf (types.submodule {
        options = {
          path = mkOption { type = types.str; };
          name = mkOption { type = types.str; };
        };
      });
      default = [
        { path = "/mnt/data"; name = "data"; }
      ];
    };

    retention = {
      daily = mkOption { type = types.int; default = 7; };
      weekly = mkOption { type = types.int; default = 4; };
      monthly = mkOption { type = types.int; default = 3; };
    };

    excludes = mkOption {
      type = types.listOf types.str;
      default = [];
    };

    immutableDays = mkOption {
      type = types.int;
      default = 3;
      description = "Number of daily snapshots to make immutable";
    };

    smartDisks = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of disks to check with smartctl (e.g., /dev/sda)";
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [
      pkgs.rsnapshot
      pkgs.rsync
      pkgs.coreutils
      pkgs.findutils
      pkgs.smartmontools
    ];

    # --- RSNAPSHOT CONFIG ---
    environment.etc."rsnapshot.conf".text = ''
      config_version  1.2
      snapshot_root   ${cfg.backupDir}/

      cmd_rsync       ${pkgs.rsync}/bin/rsync
      cmd_cp          ${pkgs.coreutils}/bin/cp
      cmd_rm          ${pkgs.coreutils}/bin/rm
      cmd_logger      ${pkgs.util-linux}/bin/logger

      retain  daily   ${toString cfg.retention.daily}
      retain  weekly  ${toString cfg.retention.weekly}
      retain  monthly ${toString cfg.retention.monthly}

      verbose         2
      loglevel        3
      logfile         /var/log/rsnapshot.log

      sync_first      1

      rsync_long_args --delete --numeric-ids --relative --delete-excluded --partial --delay-updates ${excludeArgs}

      ${backupLines}
    '';

    # --- BACKUP SERVICE ---
    systemd.services.rsnapshot-daily = {
      description = "rsnapshot daily backup with immutables";
      serviceConfig.Type = "oneshot";
      script = ''
        set -e

        # 1️⃣ Retirer immuables des anciens (pour rotation)
        for SNAP in $(seq ${toString cfg.immutableDays} $(( ${cfg.retention.daily} - 1 )) ); do
          SNAP_PATH=${cfg.backupDir}/daily.${SNAP}
          if [ -d "$SNAP_PATH" ]; then
            chattr -i -R "$SNAP_PATH" || true
          fi
        done

        # 2️⃣ Lancer rsnapshot
        ${pkgs.rsnapshot}/bin/rsnapshot daily

        # 3️⃣ Rendre immuables les derniers snapshots
        for SNAP in $(seq 0 $(( ${toString cfg.immutableDays} - 1 )) ); do
          SNAP_PATH=${cfg.backupDir}/daily.${SNAP}
          if [ -d "$SNAP_PATH" ]; then
            chattr +i -R "$SNAP_PATH" || true
          fi
        done
      '';
      unitConfig.RequiresMountsFor = mountPoints;
    };

    systemd.services.rsnapshot-weekly = {
      description = "rsnapshot weekly";
      serviceConfig.Type = "oneshot";
      script = "${pkgs.rsnapshot}/bin/rsnapshot weekly";
      unitConfig.RequiresMountsFor = mountPoints;
    };

    systemd.services.rsnapshot-monthly = {
      description = "rsnapshot monthly";
      serviceConfig.Type = "oneshot";
      script = "${pkgs.rsnapshot}/bin/rsnapshot monthly";
      unitConfig.RequiresMountsFor = mountPoints;
    };

    # --- TIMERS ---
    systemd.timers.rsnapshot-daily = {
      wantedBy = [ "timers.target" ];
      timerConfig = { OnCalendar = "daily"; Persistent = true; };
    };
    systemd.timers.rsnapshot-weekly = {
      wantedBy = [ "timers.target" ];
      timerConfig = { OnCalendar = "weekly"; Persistent = true; };
    };
    systemd.timers.rsnapshot-monthly = {
      wantedBy = [ "timers.target" ];
      timerConfig = { OnCalendar = "monthly"; Persistent = true; };
    };

    # --- CHECKSUM SERVICE ---
    systemd.services.backup-checksum = {
      description = "Incremental checksum verification";
      serviceConfig.Type = "oneshot";
      script = ''
        set -e

        SNAP="${cfg.backupDir}/daily.0"
        DB="${cfg.backupDir}/.checksums"
        NEW_DB="${cfg.backupDir}/.checksums.new"

        echo "Running checksum verification..."

        if [ ! -d "$SNAP" ]; then
          echo "No snapshot found"
          exit 1
        fi

        ${pkgs.findutils}/bin/find "$SNAP" -type f -print0 | \
          ${pkgs.coreutils}/bin/sort -z | \
          xargs -0 ${pkgs.coreutils}/bin/sha256sum > "$NEW_DB"

        if [ -f "$DB" ]; then
          if ! diff -q "$DB" "$NEW_DB" >/dev/null; then
            echo "WARNING: Differences detected in checksums!"
            diff "$DB" "$NEW_DB" || true
          else
            echo "Checksums OK"
          fi
        else
          echo "Initializing checksum database"
        fi

        mv "$NEW_DB" "$DB"
      '';
      unitConfig.RequiresMountsFor = mountPoints;
    };

    systemd.timers.backup-checksum = {
      wantedBy = [ "timers.target" ];
      timerConfig = { OnCalendar = "daily"; Persistent = true; };
    };

    # --- SMART MONITORING ---
    systemd.services.smart-monitor = {
      description = "SMART disk check";
      serviceConfig.Type = "oneshot";
      script = ''
        for DISK in ${concatStringsSep " " cfg.smartDisks}; do
          echo "Checking SMART for $DISK"
          ${pkgs.smartmontools}/bin/smartctl -H "$DISK"
          ${pkgs.smartmontools}/bin/smartctl -A "$DISK" | tail -n 10
        done
      '';
    };

    systemd.timers.smart-monitor = {
      wantedBy = [ "timers.target" ];
      timerConfig = { OnCalendar = "weekly"; Persistent = true; };
    };
  };
}