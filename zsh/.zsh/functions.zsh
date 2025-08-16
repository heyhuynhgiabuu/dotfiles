#My custom functions

# Access to GPT in the CLI. Requires https://github.com/openai/openai-python
# Security hardened with input validation and safe argument handling
gpt() {
    if [[ $# -eq 0 ]]; then
        printf "Usage: gpt <prompt>\n" >&2
        printf "Example: gpt 'Explain how to use git'\n" >&2
        return 2
    fi
    
    local prompt="$*"
    
    # Input validation
    if [[ ${#prompt} -gt 4000 ]]; then
        printf "Error: Prompt too long (max 4000 characters)\n" >&2
        return 1
    fi
    
    # Check for potentially sensitive patterns
    if [[ "$prompt" =~ (password|secret|key|token|credential) ]]; then
        printf "Warning: Prompt may contain sensitive information. Continue? [y/N] " >&2
        read -r response
        case "$response" in
            [yY]|[yY][eE][sS]) ;;
            *) printf "Cancelled\n" >&2; return 1 ;;
        esac
    fi
    
    # Use safer argument passing - avoid embedding quotes in command
    printf '%s\n' "$prompt" | openai api chat_completions.create -m gpt-3.5-turbo -g user
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

# View the latest opencode log file and follow it
logocode() {
  local log_dir="$HOME/.local/share/opencode/log"
  if [[ -d "$log_dir" ]]; then
    # zsh glob to get the latest modified file
    local -a files
    files=("$log_dir"/*(N.om[1]))
    if (( ${#files[@]} > 0 )); then
      # Use tail -f to follow the file. +F in less is also an option,
      # but tail is more direct for this use case.
      tail -f "$files[1]"
    else
      echo "No log files found in $log_dir"
    fi
  else
    echo "Log directory not found: $log_dir"
  fi
}

# Clean up merged git branches
git_clean_merged() {
  git branch --merged | egrep -v "(^\*|main|master)" | xargs git branch -d
}

