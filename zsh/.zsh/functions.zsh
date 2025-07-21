#My custom functions

# Access to GPT in the CLI. Requires https://github.com/openai/openai-python
gpt() {
    openai api chat_completions.create -m gpt-3.5-turbo -g user "\"$*\""
}

# Create and CD into folder 
function mkcd() {
  mkdir -p "$1" && cd "$1"
}

# push with set upstream for the current branch
gpup() {
  branch=$(git rev-parse --abbrev-ref HEAD)
  git push --set-upstream origin "$branch"
}

opg() {
  local base="$HOME/Documents/git"
  local dir
  dir=$(find "$base" -mindepth 1 -maxdepth 1 \( -type d -o -type l \) -exec test -d {} \; -print | fzf)
  if [[ -n "$dir" ]]; then
    cd "$dir"
  else
    cd "$base"
  fi
}
op() {
  local user_dir="$HOME"
  local dir
  dir=$(find "$user_dir" -mindepth 1 -maxdepth 1 -type d  ! -name '.*' | fzf) && cd "$dir"
}

# quick session
qss() {
  local dotfiles_dir="$HOME/dotfiles"
  local git_base="$HOME/Documents/git"

  if ! tmux has-session -t setting 2>/dev/null; then
    tmux new-session -d -s setting -c "$dotfiles_dir"
  fi

  local dir
  local base="$HOME/Documents/git"

  dir=$(find "$base" -mindepth 1 -maxdepth 1 -type d ! -name '.*' | fzf)

  local name="$(basename "$dir")"

  if ! tmux has-session -t "$name" 2>/dev/null; then
    tmux new-session -d -s "$name" -c "$dir"
  fi
   if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$name"
  else
    tmux attach-session -t "$name"
  fi       
}
bindkey -v

# GitHub Copilot CLI Enhanced Functions

# Interactive command suggestion with Copilot
suggest() {
  local input="$*"
  if [[ -z "$input" ]]; then
    echo "Usage: suggest <description of what you want to do>"
    echo "Example: suggest 'find all javascript files modified in the last 7 days'"
    return 1
  fi
  
  if command -v gh >/dev/null && gh extension list | grep -q copilot; then
    gh copilot suggest -t shell "$input"
  else
    echo "⚠️  GitHub Copilot CLI not installed. Install with: gh extension install github/gh-copilot"
    return 1
  fi
}

# Explain a command using Copilot
explain() {
  local cmd="$*"
  if [[ -z "$cmd" ]]; then
    echo "Usage: explain <command to explain>"
    echo "Example: explain 'docker run -it --rm -v \$(pwd):/app node:16'"
    return 1
  fi
  
  if command -v gh >/dev/null && gh extension list | grep -q copilot; then
    gh copilot explain "$cmd"
  else
    echo "⚠️  GitHub Copilot CLI not installed. Install with: gh extension install github/gh-copilot"
    return 1
  fi
}

# Smart git command suggestions using Copilot
gitsuggest() {
  local context="$*"
  if [[ -z "$context" ]]; then
    echo "Usage: gitsuggest <what you want to do with git>"
    echo "Example: gitsuggest 'undo last commit but keep changes'"
    return 1
  fi
  
  if command -v gh >/dev/null && gh extension list | grep -q copilot; then
    gh copilot suggest -t git "$context"
  else
    echo "⚠️  GitHub Copilot CLI not installed. Install with: gh extension install github/gh-copilot"
    return 1
  fi
}

# Kubernetes command suggestions using Copilot  
k8ssuggest() {
  local context="$*"
  if [[ -z "$context" ]]; then
    echo "Usage: k8ssuggest <what you want to do with kubectl>"
    echo "Example: k8ssuggest 'get all pods in kube-system namespace'"
    return 1
  fi
  
  if command -v gh >/dev/null && gh extension list | grep -q copilot; then
    gh copilot suggest -t shell "kubectl $context"
  else
    echo "⚠️  GitHub Copilot CLI not installed. Install with: gh extension install github/gh-copilot"
    return 1
  fi
}
