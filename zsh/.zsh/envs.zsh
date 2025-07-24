# Add custom ENV values here to export
export GOPATH="$HOME/go"
export M2_HOME="$HOME/apache-maven-3.8.8"

# Add ~/.bin to PATH
export PATH="$HOME/.bin:$PATH"


# Herd injected PHP 8.4 configuration.
export HERD_PHP_84_INI_SCAN_DIR="/Users/killerkidbo/Library/Application Support/Herd/config/php/84/"


# Herd injected PHP 8.3 configuration.
export HERD_PHP_83_INI_SCAN_DIR="/Users/killerkidbo/Library/Application Support/Herd/config/php/83/"


# Herd injected PHP 8.2 configuration.
export HERD_PHP_82_INI_SCAN_DIR="/Users/killerkidbo/Library/Application Support/Herd/config/php/82/"

# Go development environment
export GOPATH=$HOME/go
export GOROOT=$(go env GOROOT 2>/dev/null || echo "/usr/local/go")
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin

