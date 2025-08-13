#!/bin/bash
# Cross-platform ffmpeg detection & optional installation helper
# Usage:
#   ./scripts/ffmpeg-helper.sh [--auto-install]
#   source within other scripts to ensure ffmpeg availability.
# Respects project rule: keep dependencies minimal; only installs when explicitly requested.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

AUTO_INSTALL=false
if [[ "${1:-}" == "--auto-install" ]]; then
  AUTO_INSTALL=true
fi

ensure_ffmpeg() {
  if cmd_exists ffmpeg; then
    log_success "ffmpeg already installed: $(ffmpeg -version | head -n1)"
    return 0
  fi
  if ! $AUTO_INSTALL; then
    log_warning "ffmpeg not found. Re-run with --auto-install to install (brew/apt/yum/pacman)."
    return 1
  fi
  log_info "Attempting to install ffmpeg..."
  install_package ffmpeg
  if cmd_exists ffmpeg; then
    log_success "ffmpeg installed successfully: $(ffmpeg -version | head -n1)"
  else
    log_error "ffmpeg installation failed. Please install manually."
    return 1
  fi
}

# Provide simple conversion helper (SRT -> plain text transcript)
extract_plaintext_from_srt() {
  local srt_file="$1"
  local out_file="$2"
  if [[ ! -f "$srt_file" ]]; then
    log_error "Missing SRT file: $srt_file"
    return 1
  fi
  # Remove numeric indices, timestamps, blank collapse
  sed -E '/^[0-9]+$/d; /-->/d; s/\r//g' "$srt_file" | awk 'NF' >"$out_file"
  log_success "Extracted transcript: $out_file"
}

main() {
  ensure_ffmpeg || true
  if [[ ${3:-} == "--extract" ]]; then
    local in_srt="${1:-}" out_txt="${2:-}";
    if [[ -z "$in_srt" || -z "$out_txt" ]]; then
      log_error "Usage: ffmpeg-helper.sh input.srt output.txt --extract"
      exit 1
    fi
    extract_plaintext_from_srt "$in_srt" "$out_txt"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
