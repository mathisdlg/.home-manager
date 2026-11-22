# Miniatures des fichiers RAW Canon (CR3) dans Nautilus.
#
# Nautilus (via gnome-desktop) lit les fichiers *.thumbnailer de
# $XDG_DATA_HOME/thumbnailers. On en déclare un pour image/x-canon-cr3 qui :
#   1. extrait le JPEG embarqué dans le CR3 avec exiftool (pas de décodage RAW
#      complet, donc rapide),
#   2. applique l'orientation EXIF du RAW (l'aperçu n'est pas toujours pivoté),
#   3. redimensionne et sort un PNG avec ImageMagick.
#
# Fichier pris en charge automatiquement par user/base/imports.nix (auto-import) ;
# il suffit d'activer l'option dans modules.nix :
#   user.utils.raw_thumbnailer.enable = true;
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.utils.raw_thumbnailer;

  cr3_thumbnailer = pkgs.writeShellApplication {
    name = "cr3-thumbnailer";
    runtimeInputs = with pkgs; [
      exiftool
      imagemagick
      coreutils
    ];
    text = ''
      src="$1"
      dst="$2"
      size="''${3:-256}"

      tmp="$(mktemp)"
      trap 'rm -f "$tmp"' EXIT

      # Aperçus embarqués, du plus grand au plus petit :
      #  - PreviewImage   : ~1620x1080 (boîte PRVW du CR3)
      #  - JpgFromRaw     : JPEG pleine taille sur certains boîtiers
      #  - ThumbnailImage : 160x120 (boîte THMB)
      for tag in PreviewImage JpgFromRaw ThumbnailImage; do
        exiftool -b "-$tag" "$src" > "$tmp" 2>/dev/null || true
        if [ -s "$tmp" ]; then
          break
        fi
      done

      if [ ! -s "$tmp" ]; then
        echo "cr3-thumbnailer: aucun aperçu embarqué dans $src" >&2
        exit 1
      fi

      # Orientation lue sur le RAW (1=normal, 3=180°, 6=90° horaire, 8=270°).
      case "$(exiftool -n -s3 -Orientation "$src" 2>/dev/null || true)" in
        3) rot=180 ;;
        6) rot=90 ;;
        8) rot=270 ;;
        *) rot=0 ;;
      esac

      magick "$tmp" -rotate "$rot" -thumbnail "''${size}x''${size}>" -strip "png:$dst"
    '';
  };
in
{
  options.services.utils.raw_thumbnailer.enable = mkEnableOption "Enable CR3 (Canon RAW) thumbnails in Nautilus.";

  config = mkIf cfg.enable {
    xdg.dataFile."thumbnailers/cr3.thumbnailer".text = ''
      [Thumbnailer Entry]
      TryExec=${cr3_thumbnailer}/bin/cr3-thumbnailer
      Exec=${cr3_thumbnailer}/bin/cr3-thumbnailer %i %o %s
      MimeType=image/x-canon-cr3;
    '';
  };
}
