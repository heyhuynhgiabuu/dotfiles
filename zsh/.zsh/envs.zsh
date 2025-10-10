# Environment Variables
# All custom environment exports in one place

# Maven
export M2_HOME="$HOME/apache-maven-3.8.8"

# Go development
export GOPATH=$HOME/go
export GOBIN="$HOME/go/bin"
export PATH="$PATH:$GOBIN"
unset GOROOT  # Use Homebrew Go

# Security & API keys - LOADED VIA CACHE (see cache-secrets.zsh)
# Regenerate cache: rm ~/.zsh/cache/secrets.zsh && source ~/.zshrc
# All secrets are now cached to avoid 11 subprocess calls on every shell startup

export DNS_OVER_HTTPS=1

# OpenCode MCP Configuration
export MCP_CHROME_PATH="/Users/killerkidbo/.nvm/versions/node/v22.14.0/lib/node_modules/mcp-chrome-bridge/dist/mcp/mcp-server-stdio.js"
export DATABASE_URL="postgresql://postgres@localhost:5433/ocusage"

export OPENCODE_DISABLE_AUTOCOMPACT=true  # Disable broken compaction
export OPENCODE_DISABLE_PRUNE=false        # Disable potentially buggy pruning

# Terminal color support for OpenCode TUI
export FORCE_COLOR=1
export CLICOLOR=1
export COLORTERM=truecolor
export OPENCODE_COLOR=always

# halo
export CF_R2_ACCESS_KEY_STAGING=18bd74645bfd2d48c0565faf0c6а4676
export CF_R2_BUCKET_STAGING=staging
export CF_R2_ENABLED=true
export CF_R2_ENDPOINT_STAGING=https://051804eb2afb27b9cf126aff0d94d845.r2.cloudflarestorage.com
export CF_R2_PUBLIC_URL_STAGING=https://pub-4758ffb705c2433490e2f329cdc71db2.r2.dev/staging
export CF_R2_SECRET_KEY_STAGING=6bd390307c03d0104053bcbd08b65a786f28aa571931c2e35f65db66aaf3c5e1

