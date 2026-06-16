#!/usr/bin/env bash
set -e

if ! command -v yt-dlp >/dev/null 2>&1; then
    echo "Error: 'yt-dlp' command not found. Please install yt-dlp to use this script."
    exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "Error: 'ffmpeg' command not found. Please install ffmpeg to use this script."
    exit 1
fi

yt-dlp -f bestaudio -x --audio-format mp3 --audio-quality 0 --yes-playlist --embed-thumbnail --add-metadata -o "%(title)s.%(ext)s" "$@"