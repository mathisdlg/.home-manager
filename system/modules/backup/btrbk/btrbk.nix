{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.module.backup.btrbk;

  # ============================================================
  #  Source submodule
  # ============================================================
  #
  #  Two modes, controlled by `subvolumes`:
  #
  #  • subvolumes = []   → whole-disk mode
  #    btrbk snapshots every top-level subvolume on the filesystem.
  #    snapshot_dir / retention are set on the `volume` line itself.
  #
  #  • subvolumes = ["home" "var/lib"]  → selective mode
  #    Only the listed paths (relative to mount_point) are snapshotted.
  #    snapshot_dir / retention are set on each `subvolume` line.
  #
  source_type = types.submodule {
    options = {

      mount_point = mkOption {
        type    = types.str;
        example = "/disks/data";
        description = ''
          Mount-point of the btrfs filesystem to back up.
          Becomes the `volume` entry in btrbk.conf.
        '';
      };

      subvolumes = mkOption {
        type    = types.listOf types.str;
        default = [];
        example = [ "home" "var/lib" ];
        description = ''
          Subvolume paths relative to `mount_point` to back up.
          Set to [] (the default) to back up the whole btrfs filesystem —
          btrbk will discover and snapshot every top-level subvolume.
        '';
      };

      snapshot_dir = mkOption {
        type    = types.str;
        default = ".snapshots";
        description = ''
          Directory relative to `mount_point` where btrbk stores local
          read-only snapshots. Must be on the same btrfs filesystem.
        '';
      };

      # Per-source retention overrides (fall back to global retention if unset)
      preserve_min = mkOption {
        type    = types.nullOr types.str;
        default = null;
        example = "2d";
        description = ''
          Minimum retention for local snapshots on this source.
          Overrides `retention.preserve_min` when set.
          Uses btrbk syntax: Nd / Nw / Nm (days / weeks / months).
        '';
      };

      preserve = mkOption {
        type    = types.nullOr types.str;
        default = null;
        example = "7d 4w 6m";
        description = ''
          Retention policy for local snapshots on this source.
          Overrides `retention.preserve` when set.
          Uses btrbk syntax, e.g. "14d 4w 6m".
        '';
      };
    };
  };

  # ============================================================
  #  btrbk.conf generator
  # ============================================================
  mk_volume_block = src:
    let
      # Resolve per-source overrides, falling back to global defaults
      resolved_preserve_min = if src.preserve_min != null
                            then src.preserve_min
                            else cfg.retention.preserve_min;
      resolved_preserve    = if src.preserve != null
                            then src.preserve
                            else cfg.retention.preserve;

      indent = "  "; # two-space indent for children of `volume`

      # Whole-disk: retention attrs sit directly under the volume block
      volume_attrs = optionalString (src.subvolumes == []) (
        "${indent}snapshot_dir          ${src.snapshot_dir}\n" +
        "${indent}snapshot_preserve_min ${resolved_preserve_min}\n" +
        "${indent}snapshot_preserve     ${resolved_preserve}\n"
      );

      # Selective: one `subvolume` block per path, indented under volume
      subvolume_blocks = optionalString (src.subvolumes != [])
        (concatMapStringsSep "\n" (sv:
          "${indent}subvolume ${sv}\n" +
          "${indent}${indent}snapshot_dir          ${src.snapshot_dir}\n" +
          "${indent}${indent}snapshot_preserve_min ${resolved_preserve_min}\n" +
          "${indent}${indent}snapshot_preserve     ${resolved_preserve}\n"
        ) src.subvolumes);

    in
      "volume ${src.mount_point}\n" +
      volume_attrs +        # snapshot_dir / retention BEFORE target
      subvolume_blocks +    # subvolume blocks BEFORE target
      "${indent}target ${cfg.target.path}\n" +
      "\n";

  # ionice class number
  ionice_class_num = {
    "idle"        = "3";
    "best-effort" = "2";
    "realtime"    = "1";
  }.${cfg.performance.io_class};

in {

  # ============================================================
  #  Options
  # ============================================================
  options.services.module.backup.btrbk = {

    enable = mkEnableOption "btrbk btrfs backup service";

    # ── Sources ───────────────────────────────────────────────
    sources = mkOption {
      type    = types.listOf source_type;
      default = [];
      example = literalExpression ''
        [
          # Back up an entire btrfs disk
          { mount_point = "/disks/data"; subvolumes = []; }

          # Back up only specific subvolumes on root
          { mount_point = "/"; subvolumes = [ "home" "var/lib" ]; }
        ]
      '';
      description = ''
        List of btrfs filesystems (and optionally subvolumes) to back up.
        Each entry maps to a `volume` block in btrbk.conf.
      '';
    };

    # ── Target ────────────────────────────────────────────────
    target = {
      path = mkOption {
        type    = types.str;
        example = "/mnt/backup/btrbk";
        description = ''
          Destination directory for backup snapshots.
          Must reside on a btrfs filesystem.
        '';
      };

      preserve_min = mkOption {
        type    = types.str;
        default = "no";
        example = "2d";
        description = ''
          Minimum age of target backups to preserve before pruning.
          "no" means btrbk will prune freely according to `preserve`.
        '';
      };

      preserve = mkOption {
        type    = types.str;
        default = "30d 10w 6m";
        example = "30d 10w 12m";
        description = ''
          Retention policy for backups at the target.
          Uses btrbk syntax: "30d 10w 6m" = 30 daily, 10 weekly, 6 monthly.
        '';
      };
    };

    # ── Retention (local snapshot defaults) ───────────────────
    retention = {
      preserve_min = mkOption {
        type    = types.str;
        default = "2d";
        example = "1d";
        description = ''
          Global default for the minimum age of local snapshots to keep.
          Can be overridden per source with `sources[].preserve_min`.
        '';
      };

      preserve = mkOption {
        type    = types.str;
        default = "14d";
        example = "7d 4w 3m";
        description = ''
          Global default retention policy for local snapshots.
          Can be overridden per source with `sources[].preserve`.
          Uses btrbk syntax, e.g. "14d 4w" = 14 daily, 4 weekly.
        '';
      };
    };

    # ── Scheduling ────────────────────────────────────────────
    scheduling = {
      calendar = mkOption {
        type    = types.str;
        default = "daily";
        example = "*-*-* 02:30:00";
        description = ''
          Systemd OnCalendar expression controlling when backups run.
          Shorthands: "hourly", "daily", "weekly".
          Custom: "*-*-* 02:30:00" (every day at 02:30).
        '';
      };

      persistent = mkOption {
        type    = types.bool;
        default = true;
        description = ''
          When true, systemd will run the backup immediately on next boot
          if a scheduled run was missed (e.g. the machine was off).
        '';
      };
    };

    # ── Performance ───────────────────────────────────────────
    performance = {
      niceness = mkOption {
        type    = types.ints.between (-20) 19;
        default = 19;
        example = 10;
        description = ''
          CPU scheduling priority (passed to `nice -n`).
           19 = lowest priority — recommended for background backups.
          -20 = highest priority.
        '';
      };

      io_class = mkOption {
        type    = types.enum [ "idle" "best-effort" "realtime" ];
        default = "idle";
        example = "best-effort";
        description = ''
          I/O scheduling class (passed to `ionice -c`):
            idle        — only use disk I/O when nothing else needs it.
            best-effort — normal scheduling, priority set by `io_level`.
            realtime    — highest I/O priority (use with care).
        '';
      };

      io_level = mkOption {
        type    = types.ints.between 0 7;
        default = 7;
        example = 4;
        description = ''
          I/O priority level within the chosen class (0 = highest, 7 = lowest).
          Only meaningful for `best-effort` and `realtime`.
        '';
      };
    };

    # ── Escape hatch ──────────────────────────────────────────
    extra_config = mkOption {
      type    = types.lines;
      default = "";
      example = "stream_compress zstd";
      description = ''
        Raw lines appended verbatim to the global section of btrbk.conf.
        Useful for directives not exposed as module options.
      '';
    };
  };

  # ============================================================
  #  Implementation
  # ============================================================
  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.btrbk ];

    # ── /etc/btrbk/btrbk.conf ─────────────────────────────────
    environment.etc."btrbk/btrbk.conf".text = ''
      # ------------------------------------------------------------
      # btrbk.conf — generated by services.module.backup.btrbk
      # ------------------------------------------------------------

      timestamp_format    long
      target_preserve_min ${cfg.target.preserve_min}
      target_preserve     ${cfg.target.preserve}

      ${cfg.extra_config}

      ${concatMapStringsSep "\n" mk_volume_block cfg.sources}
    '';

    # ── Auto-create snapshot and target subvolumes ───────────
    # btrbk requires both snapshot_dir (on each source) and the target
    # directory to exist as btrfs subvolumes before running.
    # This script is idempotent — it checks before creating.
    system.activationScripts.btrbk-snapshot-dirs = {
      text =
        # One snapshot subvolume per source — paths are Nix values, interpolated at build time
        concatMapStringsSep "\n" (s:
          let
            snap_dir  = s.mount_point + "/" + s.snapshot_dir;
            btrfs     = "${pkgs.btrfs-progs}/bin/btrfs";
          in
          ''
            if ! ${btrfs} subvolume show "${snap_dir}" &>/dev/null; then
              echo "btrbk: creating snapshot subvolume ${snap_dir}"
              ${btrfs} subvolume create "${snap_dir}"
            fi
          ''
        ) cfg.sources
        +
        # Target subvolume
        (
          let
            btrfs       = "${pkgs.btrfs-progs}/bin/btrfs";
            target_path = cfg.target.path;
            parent_dir  = builtins.dirOf target_path;
          in
          ''
            if ! ${btrfs} subvolume show "${target_path}" &>/dev/null; then
              echo "btrbk: creating target subvolume ${target_path}"
              mkdir -p "${parent_dir}"
              ${btrfs} subvolume create "${target_path}"
            fi
          ''
        );
      deps = [ "specialfs" ];
    };

    # ── systemd service ───────────────────────────────────────
    systemd.services.btrbk-backup = {
      description = "btrbk btrfs backup";
      wants       = [ "local-fs.target" ];
      after       = [ "local-fs.target" ];

      serviceConfig = {
        Type = "oneshot";
        User = "root";

        ExecStart =
          "${pkgs.util-linux}/bin/ionice"
          + " -c ${ionice_class_num}"
          + " -n ${toString cfg.performance.io_level}"
          + " ${pkgs.coreutils}/bin/nice -n ${toString cfg.performance.niceness}"
          + " ${pkgs.btrbk}/bin/btrbk -c /etc/btrbk/btrbk.conf run";

        ProtectSystem  = "strict";
        ReadWritePaths = [ cfg.target.path ] ++ map (s: s.mount_point) cfg.sources;
        PrivateTmp      = true;
        NoNewPrivileges = true;
      };
    };

    # ── systemd timer ─────────────────────────────────────────
    systemd.timers.btrbk-backup = {
      description = "btrbk backup timer";
      wantedBy    = [ "timers.target" ];

      timerConfig = {
        OnCalendar         = cfg.scheduling.calendar;
        Persistent         = cfg.scheduling.persistent;
        RandomizedDelaySec = "5min";
      };
    };
  };
}
