# Environment Variables
# All custom environment exports in one place

# Maven
export M2_HOME="$HOME/apache-maven-3.8.8"

# Go development
export GOPATH=$HOME/go
export GOBIN="$HOME/go/bin"
export PATH="$PATH:$GOBIN"
unset GOROOT  # Use Homebrew Go

# Security & API keys (using pass for secure storage)
export JASYPT_ENCRYPTOR_PASSWORD="$(pass dev/halo-jasypt 2>/dev/null || echo '')"
export FIGMA_API_KEY="$(pass dev/figma-tung-pat 2>/dev/null || echo '')"
export DNS_OVER_HTTPS=1

# OpenCode MCP Configuration
export MCP_CHROME_PATH="/Users/killerkidbo/.nvm/versions/node/v22.14.0/lib/node_modules/mcp-chrome-bridge/dist/mcp/mcp-server-stdio.js"
