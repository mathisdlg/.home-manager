#!/usr/bin/env bash
set -e

SIZE="${1:-1440x}"

if ! command -v magick >/dev/null 2>&1; then
    echo "Error: ImageMagick 'magick' command not found. Please install ImageMagick to use this script."
    exit 1
fi

files=$(find . -type f -name "*.JPG")

for file in $files; do
    echo "Resizing $file to $SIZE..."
    magick "$file" -resize "$SIZE" -quality 90 -colorspace sRGB "${file%.*}-IG.jpg"
done