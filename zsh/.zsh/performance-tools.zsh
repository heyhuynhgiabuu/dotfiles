# ZSH Performance Monitoring and Optimization Tools

# Function to profile ZSH startup
zsh-profile() {
  echo "Profiling ZSH startup..."
  for i in {1..5}; do
    time zsh -i -c exit
  done
}

# Function to analyze ZSH startup with detailed profiling
zsh-analyze() {
  echo "Analyzing ZSH startup with zprof..."
  zsh -c "zmodload zsh/zprof; source ~/.zshrc; zprof | head -20"
}

# Function to check plugin loading times
zsh-plugin-times() {
  echo "Plugin loading analysis..."
  zsh -c "
    zmodload zsh/datetime
    start=\$EPOCHREALTIME
    source ~/.zshrc
    end=\$EPOCHREALTIME
    echo \"Total startup time: \$((\$end - \$start)) seconds\"
  "
}

# Function to clean ZSH cache and recompile
zsh-reset() {
  echo "Cleaning ZSH cache and recompiling..."
  rm -f ~/.zcompdump* ~/.zsh_history
  rm -rf ~/.zsh/cache/*
  zsh -c "autoload -U compinit; compinit -C"
  echo "ZSH reset complete. Restart your terminal."
}

# Function to benchmark different configs
zsh-benchmark() {
  local configs=("$HOME/.zshrc" "$HOME/dotfiles/zsh/.zshrc.ultra-optimized")
  for config in $configs; do
    if [[ -f "$config" ]]; then
      echo "Testing: $config"
      time zsh -c "source $config; exit"
      echo ""
    fi
  done
}