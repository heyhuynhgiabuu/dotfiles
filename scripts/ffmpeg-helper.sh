#!/bin/bash
# Cross-platform ffmpeg detection & optional installation / diagnostics helper
# Usage:
#   ./scripts/ffmpeg-helper.sh [--auto-install] [--force-conflicts] [--diagnose] [--brew-fix]
#   ./scripts/ffmpeg-helper.sh input.srt output.txt --extract
# Flags:
#   --auto-install      Attempt to install ffmpeg via detected package manager (brew/apt/yum/pacman)
#   --force-conflicts   (brew only) Force unlink + overwrite relink of known conflicting formulas before reinstall
#   --diagnose          Run brew / environment diagnostics (non-destructive) after operations
#   --brew-fix          Output (dry-run) remediation commands for a dirty / inconsistent Homebrew state (no execution)
#   --extract           Treat two positional args as SRT -> plaintext transcript extraction
# Environment:
#   FFMPEG_CONFLICTS    Space or comma separated extra brew formula names to treat as potential link conflicts
# Notes:
#   - Keeps dependencies minimal (project guideline). No static binary fallback unless explicitly added later.
#   - Subtitle artifacts (*.srt, *.vtt) are ignored by .gitignore.
#   - All remediation commands printed by --brew-fix are suggestions; user must run manually.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

AUTO_INSTALL=false
FORCE_CONFLICTS=false
DIAGNOSE=false
BREW_FIX=false
EXTRACT_MODE=false
IN_SRT=""; OUT_TXT=""

print_usage() {
  cat <<'EOF'
ffmpeg-helper: detect / install / diagnose ffmpeg, extract transcripts.

Basic:
  ./scripts/ffmpeg-helper.sh                # Detect only
  ./scripts/ffmpeg-helper.sh --auto-install # Detect + install if missing

Transcript extraction:
  ./scripts/ffmpeg-helper.sh input.srt output.txt --extract

Advanced flags:
  --force-conflicts   Force relink known + user-provided conflict formulas (brew)
  --diagnose          Show brew doctor/info/linkage diagnostics for ffmpeg
  --brew-fix          Print suggested Homebrew remediation commands (dry-run)

Env customization:
  FFMPEG_CONFLICTS="formula1 formula2"  (space or comma separated)
EOF
}

parse_args() {
  # Support: flags can appear in any order; extraction form uses two positional args + --extract
  local positional=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --auto-install)    AUTO_INSTALL=true; shift ;;
      --force-conflicts) FORCE_CONFLICTS=true; shift ;;
      --diagnose)        DIAGNOSE=true; shift ;;
      --brew-fix)        BREW_FIX=true; shift ;;
      --extract)         EXTRACT_MODE=true; shift ;;
      -h|--help)         print_usage; exit 0 ;;
      *) positional+=("$1"); shift ;;
    esac
  done

  if $EXTRACT_MODE; then
    if [[ ${#positional[@]} -lt 2 ]]; then
      log_error "Extraction mode requires: input.srt output.txt --extract"
      exit 1
    fi
    IN_SRT="${positional[0]}"; OUT_TXT="${positional[1]}"
  fi
}

# Turn a list with commas into space separated unique tokens
normalize_formula_list() {
  local raw="$1"
  echo "$raw" | tr ',;' ' ' | tr -s ' ' | tr ' ' '\n' | awk 'NF' | sort -u | tr '\n' ' '
}

brew_conflict_formula_base() {
  # Curated common ffmpeg-related formulae that occasionally produce link conflicts
  # (OpenEXR tools, AV1 codecs, crypto/SSL libs, streaming libs)
  echo "openexr aom rav1e dav1d libvpx nettle gnutls librist libbluray libidn2"
}

brew_effective_conflict_formulas() {
  local base extra
  base="$(brew_conflict_formula_base)"
  extra="${FFMPEG_CONFLICTS:-}"
  if [[ -n "$extra" ]]; then
    normalize_formula_list "$base $extra"
  else
    normalize_formula_list "$base"
  fi
}

brew_relink_formula() {
  local formula="$1"
  if brew list --versions "$formula" >/dev/null 2>&1; then
    log_info "Unlinking $formula (if linked)..."
    brew unlink "$formula" >/dev/null 2>&1 || true
    log_info "Relinking $formula with --overwrite..."
    brew link --overwrite "$formula" >/dev/null 2>&1 || true
  fi
}

brew_detect_conflict_for_formula() {
  # Heuristic: if formula installed AND has known binaries that are *symlinks* in Homebrew prefix
  local formula="$1"; shift || true
  local bins=()
  case "$formula" in
    openexr) bins=(exrinfo exrheader exr2aces) ;;
    aom)     bins=(aomenc aomdec) ;;
    rav1e)   bins=(rav1e) ;;
    dav1d)   bins=(dav1d) ;;
    libvpx)  bins=(vpxenc vpxdec) ;;
    nettle)  bins=() ;; # libraries only; rely on force mode
    gnutls)  bins=() ;;
    librist) bins=(rist) ;;
    libbluray) bins=() ;;
    libidn2) bins=() ;;
    *) bins=() ;;
  esac
  local prefix
  if [[ "$(uname -m)" == "arm64" ]]; then
    prefix="/opt/homebrew/bin"
  else
    prefix="/usr/local/bin"
  fi
  local b
  for b in "${bins[@]}"; do
    [[ -L "$prefix/$b" ]] && return 0
  done
  return 1
}

brew_attempt_conflict_resolution() {
  local formulas
  formulas="$(brew_effective_conflict_formulas)"
  local attempted=false
  for f in $formulas; do
    if brew list --versions "$f" >/dev/null 2>&1; then
      if $FORCE_CONFLICTS || brew_detect_conflict_for_formula "$f"; then
        log_warning "Handling potential conflict formula: $f"
        brew_relink_formula "$f"
        attempted=true
      fi
    fi
  done
  if $attempted; then
    log_info "Reinstalling ffmpeg after conflict handling..."
    brew reinstall ffmpeg || true
  fi
}

brew_detect_dirty_state() {
  local core dirty=false
  if ! cmd_exists brew; then
    return 0
  fi
  core="$(brew --repo)"
  if git -C "$core" status --porcelain 2>/dev/null | grep -q .; then
    log_warning "Homebrew core repo has uncommitted changes"
    dirty=true
  fi
  # Check taps (skip if many to keep lightweight)
  local tap
  for tap in $(brew tap 2>/dev/null || true); do
    local tapdir
    tapdir="$(brew --repo "$tap" 2>/dev/null || true)"
    [[ -z "$tapdir" ]] && continue
    if git -C "$tapdir" status --porcelain 2>/dev/null | grep -q .; then
      log_warning "Tap '$tap' is dirty"
      dirty=true
    fi
  done
  if $dirty; then
    log_info "Run --brew-fix for remediation suggestions."
  fi
}

brew_list_unlinked() {
  if cmd_exists brew; then
    local unlinked
    unlinked="$(brew list --unlinked 2>/dev/null || true)"
    if [[ -n "$unlinked" ]]; then
      log_warning "Unlinked kegs: $unlinked"
    fi
  fi
}

print_brew_fix_suggestions() {
  [[ $BREW_FIX == true ]] || return 0
  if ! cmd_exists brew; then
    log_warning "brew not found; --brew-fix ignored"
    return 0
  fi
  log_header "Homebrew remediation suggestions (dry-run output only)"
  cat <<EOF
# Review and run manually if appropriate:
# Reset core & taps:
(cd "$(brew --repo)" && git fetch origin && git reset --hard origin/HEAD)
for tap in \$(brew tap); do (cd "$(brew --repo \"$tap\")" && git fetch origin && git reset --hard origin/HEAD); done
# Cleanup & doctor:
brew update --force --quiet
brew cleanup -s
brew autoremove
brew doctor
# Inspect unlinked kegs:
brew list --unlinked
# Dry-run conflict overwrite (example):
for f in $(brew_effective_conflict_formulas); do echo "== $f =="; brew link --overwrite "${f}" --dry-run || true; done
# Reinstall ffmpeg explicitly:
brew reinstall ffmpeg
# Diagnostics after remediation:
./scripts/ffmpeg-helper.sh --diagnose
EOF
}

run_diagnostics() {
  log_header "ffmpeg diagnostics"
  if cmd_exists ffmpeg; then
    log_success "ffmpeg present: $(ffmpeg -version | head -n1)"
  else
    log_warning "ffmpeg still missing"
  fi
  if cmd_exists brew; then
    brew_detect_dirty_state || true
    brew_list_unlinked || true
    log_step "brew info ffmpeg (truncated)"
    brew info ffmpeg | head -n 20 || true
    if cmd_exists ffmpeg; then
      log_step "brew linkage --test ffmpeg"
      brew linkage --test ffmpeg || true
    fi
    log_step "brew doctor (filtered warnings)"
    brew doctor 2>&1 | grep -E 'Warning|error|Error' | head -n 25 || true
  fi
  log_info "Potential conflict formulas considered: $(brew_effective_conflict_formulas)"
  print_brew_fix_suggestions
}

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

  if [[ "$manager" == "brew" ]]; then
    # First attempt (capture logs for future enhancement if needed)
    local log_file; log_file="$(mktemp /tmp/ffmpeg_install.XXXXXX.log)"
    if ! brew install ffmpeg 2>&1 | tee "$log_file"; then
      log_warning "Initial brew install attempt encountered warnings/errors (continuing)."
    fi

    if ! cmd_exists ffmpeg; then
      log_info "ffmpeg still missing after initial brew install. Trying brew upgrade..."
      brew upgrade ffmpeg || true
    fi

    if ! cmd_exists ffmpeg; then
      log_info "Attempting conflict resolution (force mode: $FORCE_CONFLICTS)..."
      brew_attempt_conflict_resolution
    fi
  else
    # Non-brew path uses generic installer
    install_package ffmpeg || true
  fi

  if cmd_exists ffmpeg; then
    log_success "ffmpeg installed successfully: $(ffmpeg -version | head -n1)"
    return 0
  fi

  log_warning "ffmpeg installation failed after automated attempts. Suggested manual steps:"
  cat <<'EOF'
Manual resolution (brew example):
  1. Check conflicts: brew link --overwrite <formula> --dry-run
  2. Force relink formulas you trust.
  3. Reinstall: brew reinstall ffmpeg
  4. Diagnostics: ./scripts/ffmpeg-helper.sh --diagnose
  5. (Optional) Remediation suggestions: ./scripts/ffmpeg-helper.sh --brew-fix --diagnose
EOF
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
  # Remove numeric indices, timestamps, carriage returns; collapse extra blank lines
  sed -E '/^[0-9]+$/d; /-->/d; s/\r//g' "$srt_file" | awk 'NF' >"$out_file"
  log_success "Extracted transcript: $out_file"
}

main() {
  parse_args "$@"
  ensure_ffmpeg || true
  if $DIAGNOSE || $BREW_FIX; then
    run_diagnostics || true
  fi
  if $EXTRACT_MODE; then
    extract_plaintext_from_srt "$IN_SRT" "$OUT_TXT"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
