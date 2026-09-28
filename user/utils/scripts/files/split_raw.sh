#!/bin/bash

# Source directory (current directory by default)
SRC_DIR="${1:-.}"

# Destination folders
JPG_DIR="$SRC_DIR/jpg"
RAW_DIR="$SRC_DIR/raw"

# Create folders if they don’t exist
mkdir -p "$JPG_DIR"
mkdir -p "$RAW_DIR"

# Move JPG files
find "$SRC_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -exec mv -n {} "$JPG_DIR"/ \;

# Move CR3 files (Canon RAW)
find "$SRC_DIR" -maxdepth 1 -type f -iname "*.cr3" -exec mv -n {} "$RAW_DIR"/ \;

echo "Done organizing files!"