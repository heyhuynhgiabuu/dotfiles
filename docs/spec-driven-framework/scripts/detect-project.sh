#!/usr/bin/env bash
# Universal project type detection for OpenCode Spec-Driven Development
# Detects project type, tech stack, and structure from existing files

set -euo pipefail

# Get repository root
get_repo_root() {
    git rev-parse --show-toplevel 2>/dev/null || pwd
}

# Detect primary language
detect_language() {
    local repo_root="$1"

    # Check for language-specific files
    if [[ -f "$repo_root/package.json" ]]; then
        echo "javascript"
    elif [[ -f "$repo_root/Cargo.toml" ]]; then
        echo "rust"
    elif [[ -f "$repo_root/go.mod" ]]; then
        echo "go"
    elif [[ -f "$repo_root/requirements.txt" ]] || [[ -f "$repo_root/pyproject.toml" ]]; then
        echo "python"
    elif [[ -f "$repo_root/pom.xml" ]] || [[ -f "$repo_root/build.gradle" ]]; then
        echo "java"
    elif [[ -f "$repo_root/Gemfile" ]]; then
        echo "ruby"
    elif [[ -f "$repo_root/composer.json" ]]; then
        echo "php"
    elif [[ -f "$repo_root/Package.swift" ]]; then
        echo "swift"
    elif [[ -f "$repo_root/pubspec.yaml" ]]; then
        echo "dart"
    else
        echo "unknown"
    fi
}

# Detect framework from dependencies
detect_framework() {
    local repo_root="$1"
    local language="$2"

    case "$language" in
        javascript)
            if [[ -f "$repo_root/package.json" ]]; then
                if grep -q '"react"' "$repo_root/package.json"; then
                    echo "react"
                elif grep -q '"vue"' "$repo_root/package.json"; then
                    echo "vue"
                elif grep -q '"angular"' "$repo_root/package.json"; then
                    echo "angular"
                elif grep -q '"express"' "$repo_root/package.json"; then
                    echo "express"
                elif grep -q '"next"' "$repo_root/package.json"; then
                    echo "nextjs"
                elif grep -q '"nuxt"' "$repo_root/package.json"; then
                    echo "nuxtjs"
                else
                    echo "vanilla-js"
                fi
            fi
            ;;
        python)
            if [[ -f "$repo_root/requirements.txt" ]]; then
                if grep -q "fastapi\|starlette" "$repo_root/requirements.txt" 2>/dev/null; then
                    echo "fastapi"
                elif grep -q "django" "$repo_root/requirements.txt" 2>/dev/null; then
                    echo "django"
                elif grep -q "flask" "$repo_root/requirements.txt" 2>/dev/null; then
                    echo "flask"
                else
                    echo "python"
                fi
            elif [[ -f "$repo_root/pyproject.toml" ]]; then
                if grep -q "fastapi\|starlette" "$repo_root/pyproject.toml" 2>/dev/null; then
                    echo "fastapi"
                elif grep -q "django" "$repo_root/pyproject.toml" 2>/dev/null; then
                    echo "django"
                elif grep -q "flask" "$repo_root/pyproject.toml" 2>/dev/null; then
                    echo "flask"
                else
                    echo "python"
                fi
            fi
            ;;
        go)
            if [[ -f "$repo_root/go.mod" ]]; then
                if grep -q "gin-gonic" "$repo_root/go.mod"; then
                    echo "gin"
                elif grep -q "echo" "$repo_root/go.mod"; then
                    echo "echo"
                elif grep -q "fiber" "$repo_root/go.mod"; then
                    echo "fiber"
                else
                    echo "net/http"
                fi
            fi
            ;;
        rust)
            if [[ -f "$repo_root/Cargo.toml" ]]; then
                if grep -q "axum" "$repo_root/Cargo.toml"; then
                    echo "axum"
                elif grep -q "actix-web" "$repo_root/Cargo.toml"; then
                    echo "actix"
                elif grep -q "rocket" "$repo_root/Cargo.toml"; then
                    echo "rocket"
                elif grep -q "warp" "$repo_root/Cargo.toml"; then
                    echo "warp"
                else
                    echo "rust"
                fi
            fi
            ;;
        *)
            echo "$language"
            ;;
    esac
}

# Detect project type from structure
detect_project_type() {
    local repo_root="$1"
    local language="$2"
    local framework="$3"

    # Check for mobile indicators
    if [[ -d "$repo_root/android" ]] || [[ -d "$repo_root/ios" ]] || [[ -f "$repo_root/pubspec.yaml" ]]; then
        echo "mobile-app"
        return
    fi

    # Check for CLI indicators
    if [[ -d "$repo_root/cmd" ]] || [[ -d "$repo_root/bin" ]] || [[ "$framework" == "vanilla-js" ]]; then
        if [[ -d "$repo_root/src" ]] && [[ -d "$repo_root/pkg" ]]; then
            echo "cli-tool"
            return
        fi
    fi

    # Check for library indicators
    if [[ -d "$repo_root/lib" ]] || [[ -d "$repo_root/pkg" ]] || [[ -d "$repo_root/examples" ]]; then
        if [[ ! -d "$repo_root/public" ]] && [[ ! -f "$repo_root/index.html" ]]; then
            echo "library"
            return
        fi
    fi

    # Check for web app indicators
    if [[ -d "$repo_root/public" ]] || [[ -f "$repo_root/index.html" ]] || [[ "$framework" =~ ^(react|vue|angular|nextjs|nuxtjs)$ ]]; then
        if [[ -d "$repo_root/src" ]] && { [[ -d "$repo_root/backend" ]] || [[ -d "$repo_root/server" ]] || [[ -d "$repo_root/api" ]]; }; then
            echo "web-app"
            return
        else
            echo "frontend-app"
            return
        fi
    fi

    # Check for API/backend indicators
    if [[ -d "$repo_root/routes" ]] || [[ -d "$repo_root/controllers" ]] || [[ -d "$repo_root/models" ]]; then
        echo "api-service"
        return
    fi

    # Default based on language
    case "$language" in
        javascript|python|go|rust|java)
            echo "api-service"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Detect testing framework
detect_testing() {
    local repo_root="$1"
    local language="$2"

    case "$language" in
        javascript)
            if [[ -f "$repo_root/package.json" ]]; then
                if grep -q '"jest"' "$repo_root/package.json"; then
                    echo "jest"
                elif grep -q '"vitest"' "$repo_root/package.json"; then
                    echo "vitest"
                elif grep -q '"mocha"' "$repo_root/package.json"; then
                    echo "mocha"
                else
                    echo "jest"
                fi
            fi
            ;;
        python)
            if [[ -f "$repo_root/requirements.txt" ]] || [[ -f "$repo_root/pyproject.toml" ]]; then
                if grep -q "pytest" "$repo_root/requirements.txt" "$repo_root/pyproject.toml" 2>/dev/null; then
                    echo "pytest"
                else
                    echo "unittest"
                fi
            fi
            ;;
        go)
            echo "testing"
            ;;
        rust)
            echo "cargo-test"
            ;;
        java)
            echo "junit"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Detect project structure
detect_structure() {
    local repo_root="$1"
    local project_type="$2"

    case "$project_type" in
        web-app)
            if [[ -d "$repo_root/frontend" ]] && [[ -d "$repo_root/backend" ]]; then
                echo "frontend+backend"
            elif [[ -d "$repo_root/client" ]] && [[ -d "$repo_root/server" ]]; then
                echo "client+server"
            else
                echo "monorepo"
            fi
            ;;
        mobile-app)
            if [[ -d "$repo_root/android" ]] && [[ -d "$repo_root/ios" ]]; then
                echo "android+ios"
            else
                echo "cross-platform"
            fi
            ;;
        cli-tool)
            if [[ -d "$repo_root/cmd" ]] && [[ -d "$repo_root/pkg" ]]; then
                echo "cmd+pkg"
            else
                echo "simple-cli"
            fi
            ;;
        library)
            if [[ -d "$repo_root/src" ]] && [[ -d "$repo_root/examples" ]]; then
                echo "src+examples"
            else
                echo "simple-lib"
            fi
            ;;
        api-service)
            if [[ -d "$repo_root/src" ]] && [[ -d "$repo_root/tests" ]]; then
                echo "src+tests"
            else
                echo "simple-api"
            fi
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Main detection function
detect_project() {
    local repo_root
    repo_root=$(get_repo_root)

    local language
    language=$(detect_language "$repo_root")

    local framework
    framework=$(detect_framework "$repo_root" "$language")

    local project_type
    project_type=$(detect_project_type "$repo_root" "$language" "$framework")

    local testing
    testing=$(detect_testing "$repo_root" "$language")

    local structure
    structure=$(detect_structure "$repo_root" "$project_type")

    # Output JSON for consumption by other scripts
    cat <<EOF
{
  "repo_root": "$repo_root",
  "language": "$language",
  "framework": "$framework",
  "project_type": "$project_type",
  "testing": "$testing",
  "structure": "$structure",
  "detected_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
}

# If run directly, output detection results
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    detect_project
fi