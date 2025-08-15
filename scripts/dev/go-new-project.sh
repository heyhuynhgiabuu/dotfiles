#!/usr/bin/env sh

# Go Project Starter Script - cross-platform (macOS & Linux)
# Creates a new Go project with standard structure and files
# Usage: go-new-project.sh <project-name> [module-path]

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly PROJECT_DIRS=(
    "cmd"
    "internal"
    "pkg"
    "api"
    "web"
    "configs"
    "scripts"
    "test"
    "docs"
    "internal/app"
)

main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi
    
    local project_name="$1"
    local module_path="${2:-$project_name}"
    local project_dir="${HOME}/go/src/$project_name"
    
    log_header "Creating new Go project: $project_name"
    log_info "Module path: $module_path"
    log_info "Location: $project_dir"
    
    # Validate Go installation
    validate_go_installation
    
    # Create project structure
    create_project_structure "$project_dir" "$module_path"
    
    # Create project files
    create_project_files "$project_dir" "$project_name" "$module_path"
    
    # Setup development environment
    setup_project_dev_environment "$project_dir" "$project_name"
    
    show_project_completion_info "$project_name" "$project_dir"
}

show_usage() {
    echo "Usage: go-new-project <project-name> [module-path]"
    echo "Example: go-new-project my-api github.com/username/my-api"
}

validate_go_installation() {
    if ! cmd_exists go; then
        log_error "Go is not installed. Please install Go first."
        log_info "Run: setup-go.sh"
        exit 1
    fi
    
    log_success "Go $(go version | cut -d' ' -f3) found"
}

create_project_structure() {
    local project_dir="$1"
    local module_path="$2"
    
    log_info "Creating project structure..."
    
    # Create project directory
    mkdir -p "$project_dir"
    cd "$project_dir"
    
    # Initialize Go module
    log_step "Initializing Go module..."
    go mod init "$module_path"
    
    # Create standard directories
    for dir in "${PROJECT_DIRS[@]}"; do
        mkdir -p "$dir"
    done
    
    log_success "Project structure created"
}

create_project_files() {
    local project_dir="$1"
    local project_name="$2"
    local module_path="$3"
    
    log_info "Creating project files..."
    
    cd "$project_dir"
    
    create_main_file "$project_name"
    create_app_package "$module_path"
    create_readme_file "$project_name" "$module_path"
    create_gitignore_file
    create_makefile "$project_name"
    create_docker_files "$project_name"
    
    log_success "Project files created"
}

create_main_file() {
    local project_name="$1"
    
    log_step "Creating main.go..."
    cat > main.go << EOF
package main

import (
	"fmt"
	"log"
)

func main() {
	fmt.Println("Hello, Go! 🐹")
	log.Printf("Starting %s", "$project_name")
}
EOF
}

create_app_package() {
    local module_path="$1"
    
    log_step "Creating app package..."
    cat > internal/app/app.go << EOF
package app

import "fmt"

// App represents the application
type App struct {
	Name    string
	Version string
}

// New creates a new App instance
func New(name, version string) *App {
	return &App{
		Name:    name,
		Version: version,
	}
}

// Run starts the application
func (a *App) Run() error {
	fmt.Printf("Running %s v%s\n", a.Name, a.Version)
	return nil
}
EOF
}

create_readme_file() {
    local project_name="$1"
    local module_path="$2"
    
    log_step "Creating README.md..."
    cat > README.md << EOF
# $project_name

A Go application built with modern practices.

## Getting Started

### Prerequisites

- Go 1.19 or later
- Make (optional)

### Installation

\`\`\`bash
git clone https://github.com/yourusername/$project_name.git
cd $project_name
go mod download
\`\`\`

### Running

\`\`\`bash
go run main.go
\`\`\`

### Building

\`\`\`bash
go build -o bin/$project_name main.go
\`\`\`

### Testing

\`\`\`bash
go test ./...
\`\`\`

## Project Structure

- \`cmd/\` - Application entrypoints
- \`internal/\` - Internal application code
- \`pkg/\` - Public library code
- \`api/\` - API definitions (OpenAPI/gRPC)
- \`web/\` - Web assets
- \`configs/\` - Configuration files
- \`test/\` - Test files
- \`docs/\` - Documentation

## License

MIT License
EOF
}

create_gitignore_file() {
    log_step "Creating .gitignore..."
    cat > .gitignore << 'EOF'
# Binaries for programs and plugins
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

# Dependency directories
vendor/

# Go workspace file
go.work

# Environment variables
.env
.env.local

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Logs
*.log
logs/
EOF
}

create_makefile() {
    local project_name="$1"
    
    log_step "Creating Makefile..."
    cat > Makefile << EOF
.PHONY: build test clean run fmt lint

APP_NAME := $project_name
BUILD_DIR := bin

# Build the application
build:
	go build -o \$(BUILD_DIR)/\$(APP_NAME) main.go

# Run the application
run:
	go run main.go

# Run tests
test:
	go test -v ./...

# Run tests with coverage
test-coverage:
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out

# Format code
fmt:
	go fmt ./...
	gofumpt -w .

# Lint code
lint:
	golangci-lint run

# Clean build artifacts
clean:
	rm -rf \$(BUILD_DIR)
	rm -f coverage.out

# Install dependencies
deps:
	go mod download
	go mod tidy

# Build for multiple platforms
build-all:
	GOOS=linux GOARCH=amd64 go build -o \$(BUILD_DIR)/\$(APP_NAME)-linux-amd64 main.go
	GOOS=darwin GOARCH=amd64 go build -o \$(BUILD_DIR)/\$(APP_NAME)-darwin-amd64 main.go
	GOOS=windows GOARCH=amd64 go build -o \$(BUILD_DIR)/\$(APP_NAME)-windows-amd64.exe main.go

# Development setup
dev-setup:
	go install golang.org/x/tools/gopls@latest
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	go install mvdan.cc/gofumpt@latest
EOF
}

create_docker_files() {
    local project_name="$1"
    
    log_step "Creating Dockerfile..."
    cat > Dockerfile << EOF
# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Final stage
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/

COPY --from=builder /app/main .

CMD ["./main"]
EOF

    log_step "Creating docker-compose.yml..."
    cat > docker-compose.yml << EOF
version: '3.8'

services:
  $project_name:
    build: .
    ports:
      - "8080:8080"
    environment:
      - ENV=development
    volumes:
      - .:/app
    working_dir: /app
EOF
}

setup_project_dev_environment() {
    local project_dir="$1"
    local project_name="$2"
    
    log_info "Setting up development environment..."
    
    cd "$project_dir"
    
    # Download dependencies
    log_step "Downloading dependencies..."
    go mod tidy
    
    # Create basic test
    log_step "Creating basic test..."
    cat > main_test.go << 'EOF'
package main

import "testing"

func TestMain(t *testing.T) {
	// Basic test to ensure main function exists
	main()
}
EOF
    
    # Test the build
    log_step "Testing build..."
    if go build -o "bin/$project_name" main.go; then
        log_success "Build test passed"
        rm -f "bin/$project_name"
    else
        log_warning "Build test failed"
    fi
}

show_project_completion_info() {
    local project_name="$1"
    local project_dir="$2"
    
    echo
    log_success "Go project '$project_name' created successfully!"
    echo
    log_info "Next steps:"
    echo "  1. cd $project_dir"
    echo "  2. nvim . (open in Neovim)"
    echo "  3. go run main.go (test the project)"
    echo "  4. make test (run tests)"
    echo "  5. tmux-go-layout (start development session)"
    echo
    log_info "Available make commands:"
    echo "  • make build    - Build the application"
    echo "  • make test     - Run tests"
    echo "  • make fmt      - Format code"
    echo "  • make lint     - Lint code"
    echo "  • make run      - Run the application"
    echo
    log_info "Project structure includes:"
    echo "  • Standard Go project layout"
    echo "  • Makefile for common tasks"
    echo "  • Docker support"
    echo "  • Comprehensive .gitignore"
    echo "  • README with usage instructions"
}

# Execute main function
main "$@"#!/bin/bash

# Go Project Starter Script - cross-platform (macOS & Linux)
# Creates a new Go project with standard structure and files
# Usage: go-new-project.sh <project-name> [module-path]

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly PROJECT_DIRS=(
    "cmd"
    "internal"
    "pkg"
    "api"
    "web"
    "configs"
    "scripts"
    "test"
    "docs"
    "internal/app"
)

main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi
    
    local project_name="$1"
    local module_path="${2:-$project_name}"
    local project_dir="${HOME}/go/src/$project_name"
    
    log_header "Creating new Go project: $project_name"
    log_info "Module path: $module_path"
    log_info "Location: $project_dir"
    
    # Validate Go installation
    validate_go_installation
    
    # Create project structure
    create_project_structure "$project_dir" "$module_path"
    
    # Create project files
    create_project_files "$project_dir" "$project_name" "$module_path"
    
    # Setup development environment
    setup_project_dev_environment "$project_dir" "$project_name"
    
    show_project_completion_info "$project_name" "$project_dir"
}

show_usage() {
    echo "Usage: go-new-project <project-name> [module-path]"
    echo "Example: go-new-project my-api github.com/username/my-api"
}

validate_go_installation() {
    if ! cmd_exists go; then
        log_error "Go is not installed. Please install Go first."
        log_info "Run: setup-go.sh"
        exit 1
    fi
    
    log_success "Go $(go version | cut -d' ' -f3) found"
}

create_project_structure() {
    local project_dir="$1"
    local module_path="$2"
    
    log_info "Creating project structure..."
    
    # Create project directory
    mkdir -p "$project_dir"
    cd "$project_dir"
    
    # Initialize Go module
    log_step "Initializing Go module..."
    go mod init "$module_path"
    
    # Create standard directories
    for dir in "${PROJECT_DIRS[@]}"; do
        mkdir -p "$dir"
    done
    
    log_success "Project structure created"
}

create_project_files() {
    local project_dir="$1"
    local project_name="$2"
    local module_path="$3"
    
    log_info "Creating project files..."
    
    cd "$project_dir"
    
    create_main_file "$project_name"
    create_app_package "$module_path"
    create_readme_file "$project_name" "$module_path"
    create_gitignore_file
    create_makefile "$project_name"
    create_docker_files "$project_name"
    
    log_success "Project files created"
}

create_main_file() {
    local project_name="$1"
    
    log_step "Creating main.go..."
    cat > main.go << EOF
package main

import (
	"fmt"
	"log"
)

func main() {
	fmt.Println("Hello, Go! 🐹")
	log.Printf("Starting %s", "$project_name")
}
EOF
}

create_app_package() {
    local module_path="$1"
    
    log_step "Creating app package..."
    cat > internal/app/app.go << EOF
package app

import "fmt"

// App represents the application
type App struct {
	Name    string
	Version string
}

// New creates a new App instance
func New(name, version string) *App {
	return &App{
		Name:    name,
		Version: version,
	}
}

// Run starts the application
func (a *App) Run() error {
	fmt.Printf("Running %s v%s\n", a.Name, a.Version)
	return nil
}
EOF
}

create_readme_file() {
    local project_name="$1"
    local module_path="$2"
    
    log_step "Creating README.md..."
    cat > README.md << EOF
# $project_name

A Go application built with modern practices.

## Getting Started

### Prerequisites

- Go 1.19 or later
- Make (optional)

### Installation

\`\`\`bash
git clone https://github.com/yourusername/$project_name.git
cd $project_name
go mod download
\`\`\`

### Running

\`\`\`bash
go run main.go
\`\`\`

### Building

\`\`\`bash
go build -o bin/$project_name main.go
\`\`\`

### Testing

\`\`\`bash
go test ./...
\`\`\`

## Project Structure

- \`cmd/\` - Application entrypoints
- \`internal/\` - Internal application code
- \`pkg/\` - Public library code
- \`api/\` - API definitions (OpenAPI/gRPC)
- \`web/\` - Web assets
- \`configs/\` - Configuration files
- \`test/\` - Test files
- \`docs/\` - Documentation

## License

MIT License
EOF
}

create_gitignore_file() {
    log_step "Creating .gitignore..."
    cat > .gitignore << 'EOF'
# Binaries for programs and plugins
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

# Dependency directories
vendor/

# Go workspace file
go.work

# Environment variables
.env
.env.local

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Logs
*.log
logs/
EOF
}

create_makefile() {
    local project_name="$1"
    
    log_step "Creating Makefile..."
    cat > Makefile << EOF
.PHONY: build test clean run fmt lint

APP_NAME := $project_name
BUILD_DIR := bin

# Build the application
build:
	go build -o \$(BUILD_DIR)/\$(APP_NAME) main.go

# Run the application
run:
	go run main.go

# Run tests
test:
	go test -v ./...

# Run tests with coverage
test-coverage:
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out

# Format code
fmt:
	go fmt ./...
	gofumpt -w .

# Lint code
lint:
	golangci-lint run

# Clean build artifacts
clean:
	rm -rf \$(BUILD_DIR)
	rm -f coverage.out

# Install dependencies
deps:
	go mod download
	go mod tidy

# Build for multiple platforms
build-all:
	GOOS=linux GOARCH=amd64 go build -o \$(BUILD_DIR)/\$(APP_NAME)-linux-amd64 main.go
	GOOS=darwin GOARCH=amd64 go build -o \$(BUILD_DIR)/\$(APP_NAME)-darwin-amd64 main.go
	GOOS=windows GOARCH=amd64 go build -o \$(BUILD_DIR)/\$(APP_NAME)-windows-amd64.exe main.go

# Development setup
dev-setup:
	go install golang.org/x/tools/gopls@latest
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	go install mvdan.cc/gofumpt@latest
EOF
}

create_docker_files() {
    local project_name="$1"
    
    log_step "Creating Dockerfile..."
    cat > Dockerfile << EOF
# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Final stage
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/

COPY --from=builder /app/main .

CMD ["./main"]
EOF

    log_step "Creating docker-compose.yml..."
    cat > docker-compose.yml << EOF
version: '3.8'

services:
  $project_name:
    build: .
    ports:
      - "8080:8080"
    environment:
      - ENV=development
    volumes:
      - .:/app
    working_dir: /app
EOF
}

setup_project_dev_environment() {
    local project_dir="$1"
    local project_name="$2"
    
    log_info "Setting up development environment..."
    
    cd "$project_dir"
    
    # Download dependencies
    log_step "Downloading dependencies..."
    go mod tidy
    
    # Create basic test
    log_step "Creating basic test..."
    cat > main_test.go << 'EOF'
package main

import "testing"

func TestMain(t *testing.T) {
	// Basic test to ensure main function exists
	main()
}
EOF
    
    # Test the build
    log_step "Testing build..."
    if go build -o "bin/$project_name" main.go; then
        log_success "Build test passed"
        rm -f "bin/$project_name"
    else
        log_warning "Build test failed"
    fi
}

show_project_completion_info() {
    local project_name="$1"
    local project_dir="$2"
    
    echo
    log_success "Go project '$project_name' created successfully!"
    echo
    log_info "Next steps:"
    echo "  1. cd $project_dir"
    echo "  2. nvim . (open in Neovim)"
    echo "  3. go run main.go (test the project)"
    echo "  4. make test (run tests)"
    echo "  5. tmux-go-layout (start development session)"
    echo
    log_info "Available make commands:"
    echo "  • make build    - Build the application"
    echo "  • make test     - Run tests"
    echo "  • make fmt      - Format code"
    echo "  • make lint     - Lint code"
    echo "  • make run      - Run the application"
    echo
    log_info "Project structure includes:"
    echo "  • Standard Go project layout"
    echo "  • Makefile for common tasks"
    echo "  • Docker support"
    echo "  • Comprehensive .gitignore"
    echo "  • README with usage instructions"
}

# Execute main function
main "$@"