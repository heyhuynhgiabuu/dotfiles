# Add custom ENV values here to export
export M2_HOME="$HOME/apache-maven-3.8.8"

# Add ~/.bin to PATH
export PATH="$HOME/.bin:$PATH"

# PHP Herd configurations moved to main .zshrc for centralization

# Go development environment
export GOPATH=$HOME/go
export GOBIN="$HOME/go/bin"
# Use Homebrew Go (no need to set GOROOT manually)
export PATH="$PATH:$GOBIN"
unset GOROOT
