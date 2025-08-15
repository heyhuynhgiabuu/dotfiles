# Lazy Oh-My-Zsh Loading
# Only load oh-my-zsh when needed to improve startup performance

# Essential oh-my-zsh variables
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # Using Starship instead

# Minimal plugin loading - only essential ones
plugins=(
  zsh-autosuggestions    # Essential for productivity
  zsh-syntax-highlighting # Essential for accuracy
  zsh-z                  # Essential for navigation
)

# Lazy load oh-my-zsh function
_lazy_load_omz() {
  if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
    source "$ZSH/oh-my-zsh.sh"
    unset -f _lazy_load_omz
  fi
}

# Create wrapper functions that trigger oh-my-zsh loading
for plugin in "${plugins[@]}"; do
  case "$plugin" in
    zsh-autosuggestions)
      # Auto-trigger on first prompt
      autoload -U add-zsh-hook
      add-zsh-hook precmd _lazy_load_omz
      ;;
  esac
done