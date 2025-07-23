#!/bin/bash

# Go Project Starter Script
# Usage: go-new-project <project-name> [module-path]

if [ $# -eq 0 ]; then
    echo "Usage: go-new-project <project-name> [module-path]"
    echo "Example: go-new-project my-api github.com/username/my-api"
    exit 1
fi

PROJECT_NAME=$1
MODULE_PATH=${2:-"$PROJECT_NAME"}
PROJECT_DIR="$HOME/go/src/$PROJECT_NAME"

echo "🐹 Creating new Go project: $PROJECT_NAME"
echo "📦 Module path: $MODULE_PATH"
echo "📁 Location: $PROJECT_DIR"

# Create project directory
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Initialize Go module
go mod init "$MODULE_PATH"

# Create basic project structure
mkdir -p {cmd,internal,pkg,api,web,configs,scripts,test,docs}

# Create main.go
cat > main.go << 'EOF'
package main

import (
	"fmt"
	"log"
)

func main() {
	fmt.Println("Hello, Go! 🐹")
	log.Println("Starting", "main")
}
EOF

# Create a basic package
mkdir -p internal/app
cat > internal/app/app.go << 'EOF'
package app

import "fmt"

// App represents the main application
type App struct {
	Name    string
	Version string
}

// New creates a new App instance
func New() *App {
	return &App{
		Name:    "Go Application",
		Version: "0.1.0",
	}
}

// Run starts the application
func (a *App) Run() error {
	fmt.Printf("Running %s v%s\n", a.Name, a.Version)
	return nil
}
EOF

# Create basic test
cat > internal/app/app_test.go << 'EOF'
package app

import "testing"

func TestNew(t *testing.T) {
	app := New()
	if app == nil {
		t.Error("New() returned nil")
	}
	if app.Name == "" {
		t.Error("App name is empty")
	}
}

func TestRun(t *testing.T) {
	app := New()
	if err := app.Run(); err != nil {
		t.Errorf("Run() returned error: %v", err)
	}
}
EOF

# Create README
cat > README.md << EOF
# $PROJECT_NAME

A Go project created with go-new-project script.

## Getting Started

\`\`\`bash
# Run the application
go run main.go

# Run tests
go test ./...

# Build
go build -o bin/$PROJECT_NAME

# Run with development layout
tmux-go-layout $PROJECT_NAME $(pwd)
\`\`\`

## Project Structure

\`\`\`
$PROJECT_NAME/
├── main.go              # Application entry point
├── internal/            # Private application code
│   └── app/            # Application logic
├── pkg/                # Public packages
├── cmd/                # Command line applications
├── api/                # API definitions (OpenAPI, gRPC)
├── web/                # Web application assets
├── configs/            # Configuration files
├── scripts/            # Build and deployment scripts
├── test/               # Integration tests
└── docs/               # Documentation
\`\`\`
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
# Binaries
*.exe
*.exe~
*.dll
*.so
*.dylib
bin/
dist/

# Test binary, built with `go test -c`
*.test

# Output of the go coverage tool
*.out

# Go workspace file
go.work

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log

# Environment variables
.env
.env.local
EOF

# Initialize git if not already a git repo
if [ ! -d ".git" ]; then
    git init
    git add .
    git commit -m "Initial commit: Go project $PROJECT_NAME"
fi

echo ""
echo "✅ Go project '$PROJECT_NAME' created successfully!"
echo ""
echo "Next steps:"
echo "1. cd $PROJECT_DIR"
echo "2. go run main.go"
echo "3. tmux-go-layout $PROJECT_NAME"
echo "4. Start coding! 🚀"

# Ask if user wants to start tmux session
read -p "Start tmux development session now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd "$PROJECT_DIR"
    exec tmux-go-layout "$PROJECT_NAME" "$PROJECT_DIR"
fi
