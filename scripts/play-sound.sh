#!/bin/bash
# Cross-platform sound notification script for OpenCode dotfiles
# Usage: ./scripts/play-sound.sh <path-to-mp3>

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <path-to-mp3>" >&2
  exit 1
fi

SOUND_FILE="$1"

if [ ! -f "$SOUND_FILE" ]; then
  echo "Sound file not found: $SOUND_FILE" >&2
  exit 2
fi

# Platform detection
OS_NAME=$(uname -s)

play_sound() {
  if command -v afplay >/dev/null 2>&1; then
    afplay "$SOUND_FILE"
    return 0
  elif command -v mpg123 >/dev/null 2>&1; then
    mpg123 "$SOUND_FILE"
    return 0
  elif command -v mpv >/dev/null 2>&1; then
    mpv --no-video --really-quiet "$SOUND_FILE"
    return 0
  elif command -v aplay >/dev/null 2>&1; then
    aplay "$SOUND_FILE"
    return 0
  else
    echo "No supported audio player found (afplay/mpg123/mpv/aplay). Please install one." >&2
    exit 3
  fi
}

play_sound
