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
  #    Only the listed paths (relative to mountPoint) are snapshotted.
  #    snapshot_dir / retention are set on each `subvolume` line.
  #
  sourceType = types.submodule {
    options = {

      mountPoint = mkOption {
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
          Subvolume paths relative to `mountPoint` to back up.
          Set to [] (the default) to back up the whole btrfs filesystem —
          btrbk will discover and snapshot every top-level subvolume.
        '';
      };

      snapshotDir = mkOption {
        type    = types.str;
        default = ".snapshots";
        description = ''
          Directory relative to `mountPoint` where btrbk stores local
          read-only snapshots. Must be on the same btrfs filesystem.
        '';
      };

      # Per-source retention overrides (fall back to global retention if unset)
      preserveMin = mkOption {
        type    = types.nullOr types.str;
        default = null;
        example = "2d";
        description = ''
          Minimum retention for local snapshots on this source.
          Overrides `retention.preserveMin` when set.
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
  mkVolumeBlock = src:
    let
      # Resolve per-source overrides, falling back to global defaults
      resolvedPreserveMin = if src.preserveMin != null
                            then src.preserveMin
                            else cfg.retention.preserveMin;
      resolvedPreserve    = if src.preserve != null
                            then src.preserve
                            else cfg.retention.preserve;

      indent = "  "; # two-space indent for children of `volume`

      # Whole-disk: retention attrs sit directly under the volume block
      volumeAttrs = optionalString (src.subvolumes == []) (
        "${indent}snapshot_dir          ${src.snapshotDir}\n" +
        "${indent}snapshot_preserve_min ${resolvedPreserveMin}\n" +
        "${indent}snapshot_preserve     ${resolvedPreserve}\n"
      );

      # Selective: one `subvolume` block per path, indented under volume
      subvolumeBlocks = optionalString (src.subvolumes != [])
        (concatMapStringsSep "\n" (sv:
          "${indent}subvolume ${sv}\n" +
          "${indent}${indent}snapshot_dir          ${src.snapshotDir}\n" +
          "${indent}${indent}snapshot_preserve_min ${resolvedPreserveMin}\n" +
          "${indent}${indent}snapshot_preserve     ${resolvedPreserve}\n"
        ) src.subvolumes);

    in
      "volume ${src.mountPoint}\n" +
      volumeAttrs +        # snapshot_dir / retention BEFORE target
      subvolumeBlocks +    # subvolume blocks BEFORE target
      "${indent}target ${cfg.target.path}\n" +
      "\n";

  # ionice class number
  ioniceClassNum = {
    "idle"        = "3";
    "best-effort" = "2";
    "realtime"    = "1";
  }.${cfg.performance.ioClass};

  # ============================================================
  #  Rolling cleanup script (free-space based snapshot pruning)
  # ============================================================
  #
  #  Runs as ExecStartPre before every btrbk run, when
  #  rollingCleanup.enable is true. For each source's snapshot
  #  directory and for the target, it repeatedly deletes the
  #  OLDEST snapshot subvolume until filesystem usage drops below
  #  rollingCleanup.threshold, or until only rollingCleanup.minKeep
  #  snapshots remain — i.e. a rolling window instead of a hard
  #  failure on "No space left on device".
  #
  #  Relies on timestamp_format = long (set below), so snapshot
  #  subvolume names sort lexically in chronological order: the
  #  "oldest" one is simply the first name alphabetically.
  #
  rollingCleanupScript = pkgs.writeShellScript "btrbk-rolling-cleanup" ''
    set -u
    BTRFS=${pkgs.btrfs-progs}/bin/btrfs

    prune_dir() {
      dir="$1"
      threshold="$2"
      minKeep="$3"

      [ -d "$dir" ] || return 0

      while true; do
        used=$(df --output=pcent "$dir" 2>/dev/null | tail -n1 | tr -dc '0-9')
        if [ -z "$used" ]; then
          echo "btrbk-rolling-cleanup: impossible de lire l'usage disque de $dir, on ignore" >&2
          return 0
        fi
        if [ "$used" -lt "$threshold" ]; then
          break
        fi

        # ne garder que les vrais sous-volumes btrfs, tries du plus ancien
        # au plus recent (fiable car timestamp_format = long)
        mapfile -t snaps < <(
          find "$dir" -mindepth 1 -maxdepth 1 -type d | sort |
          while read -r d; do
            "$BTRFS" subvolume show "$d" >/dev/null 2>&1 && echo "$d"
          done
        )
        count=''${#snaps[@]}

        if [ "$count" -le "$minKeep" ]; then
          echo "btrbk-rolling-cleanup: $dir a ''${used}% d'usage mais il ne reste que $count snapshot(s) (minKeep=$minKeep), on arrete" >&2
          break
        fi

        oldest="''${snaps[0]}"
        echo "btrbk-rolling-cleanup: $dir a ''${used}% (seuil ''${threshold}%), suppression du plus ancien : $oldest"
        "$BTRFS" subvolume delete "$oldest"
      done
    }

    ${concatMapStringsSep "\n" (s:
      ''prune_dir "${s.mountPoint}/${s.snapshotDir}" ${toString cfg.rollingCleanup.threshold} ${toString cfg.rollingCleanup.minKeep}''
    ) cfg.sources}

    prune_dir "${cfg.target.path}" ${toString cfg.rollingCleanup.threshold} ${toString cfg.rollingCleanup.minKeep}
  '';

in {

  # ============================================================
  #  Options
  # ============================================================
  options.services.module.backup.btrbk = {

    enable = mkEnableOption "btrbk btrfs backup service";

    # ── Sources ───────────────────────────────────────────────
    sources = mkOption {
      type    = types.listOf sourceType;
      default = [];
      example = literalExpression ''
        [
          # Back up an entire btrfs disk
          { mountPoint = "/disks/data"; subvolumes = []; }

          # Back up only specific subvolumes on root
          { mountPoint = "/"; subvolumes = [ "home" "var/lib" ]; }
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

      preserveMin = mkOption {
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
      preserveMin = mkOption {
        type    = types.str;
        default = "2d";
        example = "1d";
        description = ''
          Global default for the minimum age of local snapshots to keep.
          Can be overridden per source with `sources[].preserveMin`.
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

      ioClass = mkOption {
        type    = types.enum [ "idle" "best-effort" "realtime" ];
        default = "idle";
        example = "best-effort";
        description = ''
          I/O scheduling class (passed to `ionice -c`):
            idle        — only use disk I/O when nothing else needs it.
            best-effort — normal scheduling, priority set by `ioLevel`.
            realtime    — highest I/O priority (use with care).
        '';
      };

      ioLevel = mkOption {
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
    extraConfig = mkOption {
      type    = types.lines;
      default = "";
      example = "stream_compress zstd";
      description = ''
        Raw lines appended verbatim to the global section of btrbk.conf.
        Useful for directives not exposed as module options.
      '';
    };

    # ── Rolling cleanup (free-space based pruning) ────────────
    rollingCleanup = {
      enable = mkEnableOption ''
        automatic pruning of the oldest snapshot when a source or the
        target is nearly full, instead of letting btrbk fail with
        "No space left on device". Runs as ExecStartPre before each
        backup and deletes the oldest snapshot subvolume, repeatedly,
        until usage is back under `threshold` (or `minKeep` is reached)
      '';

      threshold = mkOption {
        type    = types.ints.between 1 99;
        default = 90;
        example = 85;
        description = ''
          Filesystem usage percentage (as reported by `df`) that
          triggers pruning of the oldest snapshot, checked on each
          source's snapshot directory and on the target directory.
        '';
      };

      minKeep = mkOption {
        type    = types.ints.positive;
        default = 1;
        example = 3;
        description = ''
          Minimum number of snapshots to always keep in a given
          directory (a source's snapshotDir, or the target). Pruning
          stops here even if usage is still above `threshold`, so you
          never end up with zero backups.
        '';
      };
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
      target_preserve_min ${cfg.target.preserveMin}
      target_preserve     ${cfg.target.preserve}

      ${cfg.extraConfig}

      ${concatMapStringsSep "\n" mkVolumeBlock cfg.sources}
    '';

    # ── Auto-create snapshot and target subvolumes ───────────
    # btrbk requires both snapshotDir (on each source) and the target
    # directory to exist as btrfs subvolumes before running.
    # This script is idempotent — it checks before creating.
    system.activationScripts.btrbk-snapshot-dirs = {
      text =
        # One snapshot subvolume per source — paths are Nix values, interpolated at build time
        concatMapStringsSep "\n" (s:
          let
            snapDir   = s.mountPoint + "/" + s.snapshotDir;
            btrfs     = "${pkgs.btrfs-progs}/bin/btrfs";
          in
          ''
            if ! ${btrfs} subvolume show "${snapDir}" &>/dev/null; then
              echo "btrbk: creating snapshot subvolume ${snapDir}"
              ${btrfs} subvolume create "${snapDir}"
            fi
          ''
        ) cfg.sources
        +
        # Target subvolume
        (
          let
            btrfs      = "${pkgs.btrfs-progs}/bin/btrfs";
            targetPath = cfg.target.path;
            parentDir  = builtins.dirOf targetPath;
          in
          ''
            if ! ${btrfs} subvolume show "${targetPath}" &>/dev/null; then
              echo "btrbk: creating target subvolume ${targetPath}"
              mkdir -p "${parentDir}"
              ${btrfs} subvolume create "${targetPath}"
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

        ExecStartPre = optional cfg.rollingCleanup.enable "${rollingCleanupScript}";

        ExecStart =
          "${pkgs.util-linux}/bin/ionice"
          + " -c ${ioniceClassNum}"
          + " -n ${toString cfg.performance.ioLevel}"
          + " ${pkgs.coreutils}/bin/nice -n ${toString cfg.performance.niceness}"
          + " ${pkgs.btrbk}/bin/btrbk -c /etc/btrbk/btrbk.conf run";

        ProtectSystem  = "strict";
        ReadWritePaths = [ cfg.target.path ] ++ map (s: s.mountPoint) cfg.sources;
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
