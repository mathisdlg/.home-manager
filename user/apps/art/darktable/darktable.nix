{
  config,
  pkgs,
  unstable_pkgs,
  lib,
  globals,
  ...
}:
with lib;
let
  cfg = config.services.apps.art.darktable;

  # darktable compilé avec le sous-système IA (masques d'objet, neural restore)
  darktable-ai = unstable_pkgs.darktable.overrideAttrs (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [
      unstable_pkgs.onnxruntime
      unstable_pkgs.libarchive
    ];
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [
      "-DUSE_AI=ON"
      "-DONNXRUNTIME_OFFLINE=ON"
    ];
  });

  basePkg = if cfg.ai.enable then darktable-ai else unstable_pkgs.darktable;

  # Ne montre au chargeur OpenCL que le pilote RustiCL (Mesa), en pointant vers
  # /run/opengl-driver pour suivre la version de Mesa du système.
  icdSetup = ''
    d="''${XDG_CACHE_HOME:-$HOME/.cache}/darktable-icd"
    mkdir -p "$d"
    ln -sf /run/opengl-driver/etc/OpenCL/vendors/rusticl.icd "$d/rusticl.icd"
    export OCL_ICD_VENDORS="$d"
  '';

  wrapperArgs =
    if cfg.opencl.mode == "rusticl" then
      "--set RUSTICL_ENABLE ${cfg.opencl.rusticlDriver} --run ${escapeShellArg icdSetup}"
    else
      "--add-flags --disable-opencl";

  # Le gros build (darktable-ai) reste identique entre machines : seul ce petit
  # wrapper change, donc le cache binaire reste partageable.
  darktable-final =
    if cfg.opencl.mode == "default" then
      basePkg
    else
      pkgs.symlinkJoin {
        name = "darktable-opencl-${cfg.opencl.mode}";
        paths = [ basePkg ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/darktable ${wrapperArgs}

          # Le lanceur du menu doit passer par le wrapper
          for f in $out/share/applications/*.desktop; do
            [ -e "$f" ] || continue
            src="$(readlink -f "$f")"
            rm "$f"
            sed "s|^Exec=[^ ]*|Exec=$out/bin/darktable|" "$src" > "$f"
          done
        '';
      };

  baseSettings = {
    "ui_last/theme" = "darktable-icons-grey";
    "ui_last/import_custom_places" = concatStringsSep "," cfg.importPlaces;

    "context_help/url" = "https://docs.darktable.org/usermanual/";
    "context_help/use_default_url" = "true";

    "plugins/darkroom/basecurve/auto_apply_percamera_presets" = "TRUE";
    "plugins/darkroom/modulegroups_preset" = "Modules : Tous";

    "plugins/darkroom/clipping/extra_aspect_ratios/insta_square" = "100:100";
    "plugins/darkroom/clipping/extra_aspect_ratios/insta_portrait" = "400:500";
    "plugins/darkroom/clipping/extra_aspect_ratios/insta_link_preview" = "300:400";
    "plugins/darkroom/clipping/extra_aspect_ratios/insta_landscape" = "100:191";

    "plugins/darkroom/workflow" = "none";

    "plugins/imageio/storage/disk/file_directory" = "$(FILE_FOLDER)/Final/$(FILE_NAME)";
  };

  aiSettings = {
    "plugins/ai/enabled" = "TRUE";
    "plugins/ai/provider" = "auto";
    "plugins/ai/repository" = "darktable-org/darktable-ai";
    "plugins/ai/models/active/mask" = "mask-object-sam21-small";
    "plugins/ai/models/active/denoise" = "denoise-nind";
    "plugins/ai/models/active/rawdenoise" = "rawdenoise-nind";
    "plugins/ai/ort_library_path" = "${unstable_pkgs.onnxruntime}/lib/libonnxruntime.so";
  };

  settings = baseSettings // optionalAttrs cfg.ai.enable aiSettings // cfg.extraSettings;

  declaredFile = pkgs.writeText "darktablerc-declared" (
    concatStringsSep "\n" (mapAttrsToList (k: v: "${k}=${v}") settings) + "\n"
  );

  rcFile = "${config.xdg.configHome}/darktable/darktablerc";
in
{
  options.services.apps.art.darktable = {
    enable = mkEnableOption "Enable darktable.";

    ai.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Compiler darktable avec le sous-système IA (masques d'objet, neural restore).";
    };

    opencl = {
      mode = mkOption {
        type = types.enum [
          "default"
          "rusticl"
          "disabled"
        ];
        default = "default";
        description = ''
          Contourne le conflit gflags entre ONNX Runtime et le pilote OpenCL AMD ROCm.
          - default : comportement normal de darktable
          - rusticl : n'expose que RustiCL (Mesa) au chargeur OpenCL
          - disabled : lance darktable avec --disable-opencl
        '';
      };

      rusticlDriver = mkOption {
        type = types.str;
        default = "radeonsi";
        description = "Valeur de RUSTICL_ENABLE (pilote Mesa à exposer via RustiCL).";
      };
    };

    extraSettings = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Clés darktablerc supplémentaires ou surchargées, propres à une machine.";
    };

    importPlaces = mkOption {
      type = types.listOf types.str;
      default = [
        "${globals.homeDirectory}/Data/Photo"
        "${globals.homeDirectory}/Data/Photo/Conv"
        "${globals.homeDirectory}/OpenCloud/Personnel/Photo/Working"
      ];
      description = "Dossiers affichés dans les emplacements personnalisés du module d'import (ui_last/import_custom_places).";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ darktable-final ];

    # Fusionne les clés déclarées dans darktablerc sans écraser le reste
    # (darktable doit pouvoir écrire ses propres réglages).
    home.activation.darktableConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      rc="${rcFile}"
      mkdir -p "$(dirname "$rc")"

      # Ancien lien vers le store (ancienne config) -> vraie copie modifiable
      if [ -L "$rc" ]; then
        cp --remove-destination "$(readlink -f "$rc")" "$rc"
        chmod u+w "$rc"
      fi
      touch "$rc"

      tmp="$(mktemp)"
      ${pkgs.gawk}/bin/awk '
        NR==FNR {
          i = index($0, "=")
          if (i > 0) decl[substr($0, 1, i - 1)] = $0
          next
        }
        {
          k = $0; sub(/=.*/, "", k)
          if (!(k in decl)) print
        }
        END { for (k in decl) print decl[k] }
      ' ${declaredFile} "$rc" > "$tmp"
      mv "$tmp" "$rc"
    '';
  };
}
