# Centralized PATH Management
# All PATH modifications in one place for easier maintenance

# Cross-platform path helper
path_add() { [[ -d "$1" && ":$PATH:" != *":$1:"* ]] && PATH="$1:$PATH"; }

# Platform detection (used throughout dotfiles)
detect_platform() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        *)      echo "unknown" ;;
    esac
}

PLATFORM=$(detect_platform)

# Core system paths (highest priority)
path_add "/opt/homebrew/bin"
path_add "/opt/homebrew/sbin"
path_add "/usr/local/bin"
path_add "$HOME/bin"
path_add "$HOME/.bin"

# Development tools
path_add "$HOME/.krew/bin"
path_add "$HOME/apache-maven-3.8.8/bin"
path_add "$HOME/go/bin"

# Platform-specific paths
if [[ "$PLATFORM" == "macos" ]]; then
    # macOS specific paths
    path_add "/opt/homebrew/opt/postgresql@16/bin"
    path_add "/opt/homebrew/opt/mysql-client/bin"
    path_add "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    path_add "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
    path_add "$HOME/Library/Application Support/Herd/bin"
    path_add "$HOME/.opencode/bin"
elif [[ "$PLATFORM" == "linux" ]]; then
    # Linux specific paths
    [[ -d "/usr/share/code/bin" ]] && path_add "/usr/share/code/bin"
    [[ -d "$HOME/.local/share/JetBrains/Toolbox/scripts" ]] && path_add "$HOME/.local/share/JetBrains/Toolbox/scripts"
    [[ -d "$HOME/.opencode/bin" ]] && path_add "$HOME/.opencode/bin"
fi

# Node.js (default version without loading nvm)
path_add "$NVM_DIR/versions/node/v22.14.0/bin"

# Cache & app integrations
path_add "$HOME/.cache/lm-studio/bin"

export PATH