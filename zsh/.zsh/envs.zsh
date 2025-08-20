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


# export JASYPT_ENCRYPTOR_PASSWORD=s35kWyczEbT8kJR8
export JASYPT_ENCRYPTOR_PASSWORD=$(pass dev/halo-jasypt)
export FIGMA_API_KEY=$(pass dev/figma-tung-pat)
export JAVA_HOME=/Users/killerkidbo/Library/Java/JavaVirtualMachines/corretto-17.0.15/Contents/Home
