#!/bin/bash

echo "🐹 Setting up Go development environment..."

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo "❌ Go is not installed. Installing via Homebrew..."
    brew install go
else
    echo "✅ Go is already installed: $(go version)"
fi

# Set up Go workspace directories
echo "📁 Setting up Go workspace..."
mkdir -p ~/go/{bin,src,pkg}
mkdir -p ~/go/src/github.com/$(git config user.name | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

# Install useful Go tools for Neovim
echo "🔧 Installing Go development tools..."
go install golang.org/x/tools/gopls@latest                    # Language server
go install github.com/go-delve/delve/cmd/dlv@latest          # Debugger
go install golang.org/x/tools/cmd/goimports@latest           # Import formatter
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest # Linter
go install mvdan.cc/gofumpt@latest                            # Stricter formatter
go install github.com/fatih/gomodifytags@latest              # Struct tag modifier
go install github.com/josharian/impl@latest                  # Interface implementation generator

echo "📝 Adding Go environment variables to .zshrc..."

# Check if Go paths are already in .zshrc
if ! grep -q "GOPATH" ~/dotfiles/zsh/.zshrc 2>/dev/null; then
    cat >> ~/dotfiles/zsh/.zshrc << 'EOF'

# Go development environment
export GOPATH=$HOME/go
export GOROOT=$(go env GOROOT 2>/dev/null || echo "/usr/local/go")
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin

# Go-specific aliases
alias gor='go run .'
alias gob='go build .'
alias got='go test ./...'
alias gotv='go test -v ./...'
alias gom='go mod tidy'
alias goi='go install'
alias gof='gofumpt -w .'
alias gol='golangci-lint run'

EOF
    echo "✅ Go environment added to .zshrc"
else
    echo "✅ Go environment already configured in .zshrc"
fi

echo ""
echo "🎉 Go development setup complete!"
echo ""
echo "Next steps:"
echo "1. Run: source ~/.zshrc"
echo "2. Create your first Go project: mkdir ~/go/src/hello && cd ~/go/src/hello"
echo "3. Start coding with: nvim main.go"
echo "4. Use tmux layout: tmux-go-layout"
