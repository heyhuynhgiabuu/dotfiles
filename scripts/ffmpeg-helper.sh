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

  local manager
  manager=$(detect_package_manager)
  log_info "Attempting to install ffmpeg (manager: $manager)..."
  install_package ffmpeg || true

  if cmd_exists ffmpeg; then
    log_success "ffmpeg installed successfully: $(ffmpeg -version | head -n1)"
    return 0
  fi

  # Special handling for common Homebrew link conflicts (openexr, aom, others)
  if [[ "$manager" == "brew" ]]; then
    local conflict_formulas=(openexr aom)
    local attempted_fix=false

    for formula in "${conflict_formulas[@]}"; do
      if brew list --versions "$formula" >/dev/null 2>&1; then
        # Check if any of its expected binaries already exist & point elsewhere (heuristic)
        case "$formula" in
          openexr)
            local bins=(exrinfo exrheader exr2aces)
            ;;
          aom)
            local bins=(aomenc aomdec)
            ;;
          *) bins=() ;;
        esac
        local conflict_detected=false
        for b in "${bins[@]}"; do
          if [[ -L "/opt/homebrew/bin/$b" ]]; then
            conflict_detected=true; break
          fi
        done
        if [[ "$conflict_detected" == true ]]; then
          log_warning "Potential brew link conflict involving $formula detected (blocking ffmpeg). Attempting relink." 
          attempted_fix=true
          log_info "Unlinking $formula..."
          brew unlink "$formula" || true
          log_info "Relinking $formula with overwrite..."
          brew link --overwrite "$formula" || true
        fi
      fi
    done

    if [[ "$attempted_fix" == true ]]; then
      log_info "Reinstalling ffmpeg after resolving detected link conflicts..."
      brew reinstall ffmpeg || true
    fi

    if ! cmd_exists ffmpeg; then
      log_warning "ffmpeg still not found after conflict resolution attempts. Showing dry-run info for each candidate formula..."
      for formula in "${conflict_formulas[@]}"; do
        if brew list --versions "$formula" >/dev/null 2>&1; then
          brew link --overwrite "$formula" --dry-run || true
        fi
      done
      cat <<'EOF'
Manual resolution steps (execute manually if desired):
  1. Review above dry-run outputs for conflicting files.
  2. Force relink any culprit: brew link --overwrite <formula>
  3. Reinstall ffmpeg: brew reinstall ffmpeg
  4. Verify: which ffmpeg && ffmpeg -version
  5. If still failing, run: brew doctor  (inspect guidance) and re-attempt.
EOF
    else
      log_success "ffmpeg installed after resolving brew link conflicts: $(ffmpeg -version | head -n1)"
      return 0
    fi
  fi

  if cmd_exists ffmpeg; then
    log_success "ffmpeg installed successfully: $(ffmpeg -version | head -n1)"
    return 0
  fi

  log_error "ffmpeg installation failed. Please resolve conflicts manually (see above)."
  return 1
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
