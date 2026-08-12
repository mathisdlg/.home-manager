#!/usr/bin/env bash
set -e

SIZE="${1:-1440x}"
JOBS="${2:-$(( $(nproc) / 2 ))}"
JOBS=$(( JOBS < 1 ? 1 : JOBS ))

if ! command -v magick >/dev/null 2>&1; then
    echo "Error: ImageMagick 'magick' command not found. Please install ImageMagick to use this script."
    exit 1
fi

resize_image() {
    local file="$1"
    local size="$2"
    local output="${file%.*}-IG.jpg"

    if [[ -f "$output" ]]; then
        echo "Skipping $file (already processed)"
        return 0
    fi

    echo "Resizing $file..."
    magick "$file" -resize "$size" -quality 90 -colorspace sRGB "$output"
}
export -f resize_image

mapfile -d '' files < <(find . -type f -iname "*.JPG" -not -iname "*-IG.jpg" -print0)

if [[ ${#files[@]} -eq 0 ]]; then
    echo "No JPG files found."
    exit 0
fi

echo "Found ${#files[@]} files — running with $JOBS parallel jobs..."

printf '%s\0' "${files[@]}" | xargs -0 -P "$JOBS" -I{} bash -c 'resize_image "$@"' _ {} "$SIZE"

echo "Done."