# 🏠 Cross-Platform Development Dotfiles

Modern, efficient dotfiles for cross-platform development environments. Optimized for **macOS** and **Linux** with a focus on simplicity, functionality, and developer productivity.

## ✨ Core Philosophy

This repository contains a comprehensive, cross-platform development environment optimized for **macOS and Linux**. The setup is built around a "Hybrid AI" model, leveraging the unique strengths of different tools to create a powerful and efficient workflow:

-   **Neovim (NvChad):** The core editor, providing a fast, extensible, and keyboard-centric experience.
-   **OpenCode & Serena:** A powerful terminal-based AI duo for complex, multi-step tasks, code analysis, and automated modifications.
-   **GitHub Copilot:** Integrated into Neovim for real-time, inline code completions.
-   **AugmentCode:** Provides deep workspace-aware chat and context for in-editor assistance.
-   **WezTerm & Tmux:** A modern terminal emulator combined with a robust session manager for organized, persistent workspaces.
-   **Zsh:** An enhanced shell with advanced completions, aliases, and functions to streamline command-line operations.

## 🚀 Getting Started

Setting up the environment is designed to be simple and idempotent.

```bash
# 1. Clone the repository
git clone https://github.com/heyhuynhgiabuu/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Run the installation script
# This will set up symlinks and install necessary dependencies.
./scripts/setup/install.sh
```

## 🛠️ Key Features

-   **Unified Development Environment:** Consistent tools, shortcuts, and configurations across macOS and Linux.
-   **Advanced Debugging:** An IntelliJ-like debugging experience for Java and Go, featuring a 5-panel UI, standard F-key hotkeys, and a clear separation between the debug console and application logs.
-   **AI-Powered Workflow:** A multi-layered AI setup that combines the strengths of OpenCode, Serena, GitHub Copilot, and AugmentCode.
-   **Optimized Shell:** A rich set of Zsh aliases and functions to accelerate common tasks for Git, Docker, Kubernetes, and more.
-   **Pre-configured Sessions:** Tmux layouts for specific languages (Java, Go) that can be launched with a single command.

## 📁 Repository Structure

The repository is organized by tool, making it easy to navigate and manage configurations.

```
.
├── nvim/          # Neovim configuration (Lua)
├── tmux/          # Tmux configuration and layouts
├── zsh/           # Zsh configuration, aliases, and functions
├── wezterm/       # WezTerm terminal emulator settings
├── aerospace/     # AeroSpace window manager configuration (macOS)
├── opencode/      # OpenCode AI agent configuration and prompts
├── augment/       # AugmentCode AI tool configuration
├── scripts/       # Installation, setup, and utility scripts
├── homebrew/      # Layered Brewfiles (min, dev, extra, snapshot)
└── docs/          # Documentation and guides
```

## 🛠️ Review Automation

The repository includes a lightweight, cross-platform review automation suite (Bash 3.2+ compatible) to surface risk, coverage deltas, and legacy hotspots for any branch vs a base (default main).

Scripts:
- scripts/ci/pre-review-manifest.sh — Diff manifest (JSON/Markdown)
- scripts/ci/diff-risk-classifier.sh — Classifies diff risk tags
- scripts/test-coverage-delta.sh — Heuristic test adjacency & missing test delta detection
- scripts/legacy-hotspot-detector.sh — Composite heuristic legacy/refactor hotspot scoring
- scripts/review-scope.sh — Orchestrator producing consolidated artifacts (review_artifacts/)

Artifacts (generated, ignored by git): review_artifacts/
- manifest.json/md, risk.json/md, coverage.json/md, hotspots.json/md, index.md, all.json (combined schema)

Quick Usage:
```bash
./scripts/ci/review-scope.sh --base main        # Generate JSON + Markdown
./scripts/ci/review-scope.sh --base main --no-md # JSON only
```

Manual Verification (macOS default /bin/bash 3.2):
```bash
/bin/bash --version | head -1
./scripts/ci/review-scope.sh --base main --no-md
jq -e '.version >= 1' review_artifacts/all.json  # if jq installed
rg -n 'declare -A|mapfile|readarray' scripts/ || true  # should output nothing
```
If jq is missing, all.json build is skipped with a warning (non-fatal).

Risk Tag Principles:
- large_change: Added lines or churn thresholds exceeded
- missing_test_delta: Significant additions without related test change
- performance / security / high_churn / high_concentration: Contextual heuristics

CI Gating (GitHub Actions):
A workflow (.github/workflows/review-scope.yml) runs the suite on pull requests. It always uploads artifacts and fails the job (exit 2) when gating risks are detected (security / large_change / missing_test_delta / hotspot). This provides early signal without blocking artifact visibility.

Extensibility Ideas (future):
- --strict flag in review-scope.sh to exit non-zero on security or missing_test_delta findings
- Optional CI job invoking the suite for PR gating

Portability Notes:
- No associative arrays or mapfile used (Bash 3.2 safe)
- Avoids external deps; jq only for combined all.json if present

## 🛠️ Utilities

### Package Manager Detection
A helper function is available in scripts/common.sh to detect the first available package manager on the system.

Example usage inside a script:
```bash
manager=$(detect_package_manager)
if [[ $manager == "unknown" ]]; then
  log_error "No supported package manager found"
else
  log_info "Using package manager: $manager"
  case "$manager" in
    brew) brew install jq ;;
    apt) sudo apt-get update && sudo apt-get install -y jq ;;
    yum) sudo yum install -y jq ;;
    pacman) sudo pacman -S --noconfirm jq ;;
  esac
fi
```
Supported managers (priority order): Homebrew (macOS), apt, yum, pacman.

### ffmpeg Helper & Transcript Extraction
Use scripts/dev/ffmpeg-helper.sh to detect (and optionally install) ffmpeg, diagnose Homebrew issues, suggest remediation steps, or extract plaintext from an SRT file.

Examples:
```bash
# Detect only
./scripts/dev/ffmpeg-helper.sh

# Auto-install (if supported manager present)
./scripts/dev/ffmpeg-helper.sh --auto-install

# Auto-install + aggressive conflict resolution
./scripts/dev/ffmpeg-helper.sh --auto-install --force-conflicts

# Diagnostics (brew info / linkage / doctor summary)
./scripts/dev/ffmpeg-helper.sh --diagnose

# Diagnostics + remediation suggestions (dry-run only)
./scripts/dev/ffmpeg-helper.sh --brew-fix --diagnose

# Extract transcript text from SRT
./scripts/dev/ffmpeg-helper.sh video.en.srt video.txt --extract
```
Flags:
- `--auto-install` Attempt installation using available package manager (brew/apt/yum/pacman)
- `--force-conflicts` (brew) Force relink of curated + user-provided conflict formulas before reinstall
- `--diagnose` Show truncated diagnostics (brew info/linkage/doctor) and conflict set considered
- `--brew-fix` Print (dry-run) remediation command suggestions for dirty Homebrew repos and unlinked kegs
- `--extract` Switch to SRT → plaintext transcript extraction mode (requires two positional args)

Environment:
- `FFMPEG_CONFLICTS` Space or comma separated extra formulas to include in conflict handling

By default subtitle artifacts (*.srt, *.vtt) are ignored via .gitignore.

### Neovim Performance Guards
Large or extreme long-line files can degrade performance. The custom module custom/perf-guards.lua automatically disables expensive features (Treesitter highlight/indent, semantic tokens) for files >200KB, and applies more aggressive simplifications >1MB.

## 💻 Development Workflows

### Java Development
```bash
# Start a pre-configured Tmux session for Java development
./scripts/tmux/tmux-java-layout.sh

# Use F9 to toggle breakpoints and F12 to start debugging.
```

### Go Development
```bash
# Start a pre--configured Tmux session for Go development
./scripts/tmux/tmux-go-layout.sh

# Use F9 to toggle breakpoints and F12 to start debugging.
```



### Development Guidelines
1. **Test thoroughly** - Verify changes on both macOS and Linux
2. **Follow KISS principle** - Keep configurations simple and maintainable
3. **Update documentation** - Reflect changes in relevant docs
4. **Maintain cross-platform compatibility** - Ensure configs work everywhere
5. **Test F-key hotkeys** - Verify debugging and development workflows
6. **Preserve existing functionality** - Don't break working configurations

### Agent Guidelines
- **Clean commits** - No "Generated with opencode" messages in this repo
- **Respect structure** - Follow existing directory organization
- **Match conventions** - Use Lua for Neovim, shell for scripts
- **Self-contained configs** - New configurations shouldn't require external dependencies

### Neovim Treesitter Migration
- [Treesitter Modernization Guide](docs/treesitter-modernization-guide.md) - Complete guide for migrating to main branch and fixing common issues

### AI Agent Documentation
- [Serena MCP Best Practices](docs/serena-mcp-best-practices.md) - Guidelines for leveraging Serena MCP with OpenCode agents
- [Serena MCP Example Workflows](docs/serena-mcp-example-workflows.md) - Practical examples of Serena-enhanced agent operations

## 🛡️ Homebrew Maintenance & Media Tooling

### Snapshot & Reproducibility

#### Layered Brewfiles
To enable lean setups, the monolithic Brewfile is split into layers under `homebrew/` (moved from the repository root for clearer organization, reduced root clutter, and to reserve the top level for primary tooling directories):
- homebrew/Brewfile.min   — Minimal baseline (core shell + editor + terminal tooling)
- homebrew/Brewfile.dev   — Development stack (languages, build tools, services, language servers)
- homebrew/Brewfile.extra  — Optional extras (niche CLI, specialty tools)
- homebrew/Brewfile.gui    — GUI / window manager / terminal / subscription casks
- homebrew/Brewfile.vscode — VSCode extensions layer (apply only if using VSCode)
- homebrew/Brewfile.fonts  — Nerd Fonts layer (optional, curated subset enabled)


Usage examples (apply in order as needed):
```bash
# Minimal core
brew bundle --file=homebrew/Brewfile.min

# Add development tooling
brew bundle --file=homebrew/Brewfile.dev

# Add optional extras
brew bundle --file=homebrew/Brewfile.extra

# (Optional) Install VSCode extensions
brew bundle --file=homebrew/Brewfile.vscode

# (Optional) Install GUI apps
brew bundle --file=homebrew/Brewfile.gui

# (Optional) Install fonts (curated subset enabled; uncomment more if needed)
brew bundle --file=homebrew/Brewfile.fonts
```
Each file declares only the taps it needs. You can safely skip dev or extra on constrained machines.

A locked snapshot of the current toolchain is stored in `homebrew/Brewfile` (generated via `brew bundle dump`). If tooling expects a root-level Brewfile you can optionally create a symlink:
```bash
ln -s homebrew/Brewfile Brewfile
```
To reproduce the core environment on macOS:
```bash
# Review before execution (never blindly run on prod machines)
brew bundle --file=homebrew/Brewfile
```
Only install what you actually need; fonts / GUI casks are optional. For scripted automation use scripts/brew-apply-layer.sh which supports --dry-run and skips macOS-only casks on Linux. Use --layers to specify order, e.g.:

```bash
./scripts/setup/brew-apply-layer.sh --dry-run min dev gui extra
./scripts/setup/brew-apply-layer.sh min dev gui
```

Validate installations and detect overlaps:
```bash
./scripts/verify/verify-brew-layers.sh --layers "min dev gui" --show-overlaps
```

Regenerate snapshot safely:
```bash
./scripts/setup/brew-dump-snapshot.sh      # aborts if uncommitted changes
./scripts/setup/brew-dump-snapshot.sh --force  # override check
```

### Routine Maintenance (Quarterly or After Issues)
```bash
brew update --force --quiet
brew upgrade            # (optional) keep formulae current
brew cleanup -s         # prune old versions
brew autoremove         # remove orphaned dependencies
brew doctor             # review warnings
brew list --unlinked    # inspect stray kegs
```
If repos become dirty (modified taps):
```bash
(cd "$(brew --repo)" && git fetch origin && git reset --hard origin/HEAD)
for tap in $(brew tap); do (cd "$(brew --repo "$tap")" && git fetch origin && git reset --hard origin/HEAD); done
```
Re‑dump snapshot after meaningful changes:
```bash
brew bundle dump --file=homebrew/Brewfile --force
```

### ffmpeg Helper Usage
The script `scripts/dev/ffmpeg-helper.sh` provides detection, optional install, diagnostics, conflict handling suggestions, and SRT → plaintext extraction.

Common examples:
```bash
# Detect only
./scripts/dev/ffmpeg-helper.sh

# Install if missing (brew/apt/yum/pacman detected automatically)
./scripts/dev/ffmpeg-helper.sh --auto-install

# Diagnose + remediation suggestions (no execution of fixes)
./scripts/dev/ffmpeg-helper.sh --diagnose --brew-fix

# Force conflict relinks then reinstall (brew only)
./scripts/dev/ffmpeg-helper.sh --auto-install --force-conflicts

# Extract transcript
./scripts/dev/ffmpeg-helper.sh input.srt output.txt --extract
```
Flags:
- --auto-install  Attempt installation via available manager.
- --force-conflicts  Force unlink/relink curated + user-provided formulas (brew) before reinstall.
- --diagnose  Show truncated brew info/linkage/doctor & conflict set.
- --brew-fix  Print (dry-run) remediation commands (never auto-executes).
- --extract  Switch to SRT → plaintext mode (requires input & output paths).

Environment:
- FFMPEG_CONFLICTS  Space or comma separated additional formula names to examine for relink.

### PATH Ordering Notes
Ensure Homebrew paths (`/opt/homebrew/bin`, `/opt/homebrew/sbin`) appear early (they do in `.zshrc`) so that modern tool versions (ripgrep, fd, jq, etc.) shadow any system-provided variants.

### Tap Review
Current taps snapshot (see Brewfile). Prune taps you do not actively use to reduce update noise (e.g., specialty or experimental taps). Remove with:
```bash
brew untap <tap/name>
```

---

## 🐛 Troubleshooting

### Neovim Treesitter Issues

If you encounter Treesitter errors like "Impossible pattern: '~' @conceal" or parser download failures:

**Quick Fix:**
```bash
# Run the automated fix script
./scripts/verify/fix-treesitter.sh
```

**Manual Steps:**
1. Close all Neovim instances
2. Clear parser cache: `rm -rf ~/.local/share/nvim/treesitter`
3. Remove problematic queries: `rm -f ~/.local/share/nvim/lazy/nvim-treesitter/queries/vimdoc/highlights.scm`
4. Restart Neovim and run `:TSUpdate`

The configuration now uses the `main` branch with improved error handling and automatic parser management.

### Environment Variables

Ensure these are properly set:
- `$VIMRUNTIME` - Usually set automatically by Neovim
- Check with `:echo $VIMRUNTIME` in Neovim

### Network Issues

For parser download failures:
- Check internet connection
- Clear cache and retry: `rm -rf ~/.local/share/nvim/treesitter && nvim -c 'TSUpdate' -c 'quit'`

## 📄 License

Personal dotfiles collection - use at your own discretion.

**Note**: This repository follows the KISS (Keep It Simple, Stupid) principle for maintainable, cross-platform development environments.