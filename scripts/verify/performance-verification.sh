#!/bin/bash
# Performance Optimization Verification Script
# Tests all performance improvements and reports metrics

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log_info() { printf "${BLUE}[INFO]${NC} %s\n" "$*"; }
log_success() { printf "${GREEN}[PASS]${NC} %s\n" "$*"; }
log_warning() { printf "${YELLOW}[WARN]${NC} %s\n" "$*"; }
log_error() { printf "${RED}[FAIL]${NC} %s\n" "$*"; }

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0

test_function() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    log_info "Testing: $test_name"
    
    if eval "$test_command" >/dev/null 2>&1; then
        log_success "$test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        log_error "$test_name"
        return 1
    fi
}

# Performance benchmarking
benchmark_shell_startup() {
    log_info "Benchmarking shell startup time..."
    local startup_time
    startup_time=$(time zsh -i -c exit 2>&1 | grep real | awk '{print $2}')
    
    log_info "Shell startup time: $startup_time"
    
    # Parse time and check if under 1 second
    local seconds
    seconds=$(echo "$startup_time" | sed 's/[^0-9.]//g')
    if (( $(echo "$seconds < 1.0" | bc -l) )); then
        log_success "Shell startup time acceptable (< 1.0s)"
        return 0
    else
        log_warning "Shell startup time slow (≥ 1.0s)"
        return 1
    fi
}

benchmark_git_operations() {
    log_info "Benchmarking git operations..."
    
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log_warning "Not in a git repository, skipping git benchmarks"
        return 0
    fi
    
    # Test git status caching
    local start_time end_time duration
    
    start_time=$(date +%s.%N)
    "$HOME/dotfiles/scripts/dev/git-perf.sh" status >/dev/null
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc)
    
    log_info "Git status (cached): ${duration}s"
    
    if (( $(echo "$duration < 0.5" | bc -l) )); then
        log_success "Git status performance good (< 0.5s)"
        return 0
    else
        log_warning "Git status performance could be better"
        return 1
    fi
}

# Verify installed performance tools
verify_performance_files() {
    log_info "Verifying performance optimization files..."
    
    local files=(
        "$HOME/dotfiles/zsh/.zsh/performance-opts.zsh"
        "$HOME/dotfiles/scripts/dev/brew-perf.sh"
        "$HOME/dotfiles/scripts/dev/git-perf.sh"
        "$HOME/dotfiles/nvim/.config/nvim/lua/custom/configs/lspconfig-unified.lua"
    )
    
    local all_exist=0  # Use 0 for success, 1 for failure
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            log_success "Found: $(basename "$file")"
        else
            log_error "Missing: $file"
            all_exist=1
        fi
    done
    
    return $all_exist
}

# Test performance script functionality
test_performance_scripts() {
    log_info "Testing performance scripts..."
    
    # Test brew-perf
    test_function "brew-perf status" "$HOME/dotfiles/scripts/dev/brew-perf.sh status"
    
    # Test git-perf (only in git repo)
    if git rev-parse --git-dir >/dev/null 2>&1; then
        test_function "git-perf status" "$HOME/dotfiles/scripts/dev/git-perf.sh status"
    else
        log_warning "Not in git repo, skipping git-perf tests"
    fi
}

# Test Neovim LSP configuration
test_neovim_config() {
    if ! command -v nvim >/dev/null 2>&1; then
        log_warning "Neovim not found, skipping LSP tests"
        return 0
    fi
    
    log_info "Testing Neovim configuration..."
    
    # Test if unified LSP config exists and is valid Lua
    local lsp_config="$HOME/dotfiles/nvim/.config/nvim/lua/custom/configs/lspconfig-unified.lua"
    if [[ -f "$lsp_config" ]]; then
        if nvim --headless -c "luafile $lsp_config" -c "quit" 2>/dev/null; then
            log_success "LSP unified config syntax valid"
        else
            log_error "LSP unified config has syntax errors"
            return 1
        fi
    else
        log_error "LSP unified config not found"
        return 1
    fi
    
    return 0
}

# Test Mason tool installation
test_mason_tools() {
    if ! command -v nvim >/dev/null 2>&1; then
        log_warning "Neovim not found, skipping Mason tests"
        return 0
    fi
    
    log_info "Testing Mason tool availability..."
    
    # Check if Mason directory exists
    local mason_dir="$HOME/.local/share/nvim/mason"
    if [[ -d "$mason_dir" ]]; then
        local tool_count
        tool_count=$(find "$mason_dir/bin" -type f 2>/dev/null | wc -l || echo "0")
        log_info "Mason tools installed: $tool_count"
        
        if [[ $tool_count -gt 5 ]]; then
            log_success "Mason has good tool coverage"
            return 0
        else
            log_warning "Mason tool count low, may need setup"
            return 1
        fi
    else
        log_warning "Mason directory not found, run :Mason in Neovim"
        return 1
    fi
}

# Test alias availability
test_performance_aliases() {
    log_info "Testing performance aliases..."
    
    # Source aliases and test
    if [[ -f "$HOME/dotfiles/zsh/.zsh/aliases.zsh" ]]; then
        # shellcheck source=/dev/null
        source "$HOME/dotfiles/zsh/.zsh/aliases.zsh" 2>/dev/null || true
        
        test_function "brew-perf alias" "command -v brew-perf"
        test_function "git-perf alias" "command -v git-perf"
        test_function "bp alias" "alias bp"
        test_function "gp alias" "alias gp"
    else
        log_error "Aliases file not found"
        return 1
    fi
}

# Cache performance test
test_cache_functionality() {
    log_info "Testing cache functionality..."
    
    # Test git cache
    if git rev-parse --git-dir >/dev/null 2>&1; then
        # Clear cache and time first run
        "$HOME/dotfiles/scripts/dev/git-perf.sh" refresh >/dev/null 2>&1 || true
        
        local start_time end_time duration1 duration2
        
        start_time=$(date +%s.%N)
        "$HOME/dotfiles/scripts/dev/git-perf.sh" status >/dev/null
        end_time=$(date +%s.%N)
        duration1=$(echo "$end_time - $start_time" | bc)
        
        # Second run should be faster (cached)
        start_time=$(date +%s.%N)
        "$HOME/dotfiles/scripts/dev/git-perf.sh" status >/dev/null
        end_time=$(date +%s.%N)
        duration2=$(echo "$end_time - $start_time" | bc)
        
        log_info "Git status: first=${duration1}s, cached=${duration2}s"
        
        if (( $(echo "$duration2 < $duration1" | bc -l) )); then
            log_success "Git caching working (cached faster than fresh)"
            return 0
        else
            log_warning "Git caching may not be working optimally"
            return 1
        fi
    else
        log_warning "Not in git repo, skipping cache test"
        return 0
    fi
}

# Generate performance report
generate_performance_report() {
    log_info "Generating performance report..."
    
    echo "=================================="
    echo "PERFORMANCE OPTIMIZATION REPORT"
    echo "=================================="
    echo "Date: $(date)"
    echo "System: $(uname -s) $(uname -m)"
    echo ""
    
    # Shell performance
    echo "Shell Performance:"
    echo "  Startup time: $(time zsh -i -c exit 2>&1 | grep real | awk '{print $2}')"
    echo ""
    
    # Git performance (if in repo)
    if git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Git Performance:"
        echo "  Repository: $(git remote get-url origin 2>/dev/null || echo 'local')"
        echo "  Branch: $(git branch --show-current 2>/dev/null || echo 'detached')"
        echo "  Cache directory: $HOME/.cache/git-perf"
        echo "  Cache files: $(find "$HOME/.cache/git-perf" -name "*.cache" 2>/dev/null | wc -l || echo '0')"
        echo ""
    fi
    
    # Homebrew performance  
    echo "Homebrew Performance:"
    echo "  Cache directory: $HOME/.cache/homebrew-perf"
    echo "  Packages: $(brew list --formula 2>/dev/null | wc -l || echo '0')"
    echo "  Casks: $(brew list --cask 2>/dev/null | wc -l || echo '0')"
    echo ""
    
    # Neovim performance
    if command -v nvim >/dev/null 2>&1; then
        echo "Neovim Performance:"
        echo "  Mason tools: $(find "$HOME/.local/share/nvim/mason/bin" -type f 2>/dev/null | wc -l || echo '0')"
        echo "  LSP config: unified (optimized)"
        echo ""
    fi
    
    echo "Test Results: $TESTS_PASSED/$TESTS_TOTAL passed"
    echo "=================================="
}

# Main execution
main() {
    log_info "Starting performance optimization verification..."
    echo ""
    
    # Core verification tests
    verify_performance_files
    test_performance_scripts
    test_neovim_config
    test_mason_tools
    test_performance_aliases
    test_cache_functionality
    
    # Performance benchmarks
    echo ""
    log_info "Running performance benchmarks..."
    benchmark_shell_startup
    benchmark_git_operations
    
    echo ""
    generate_performance_report
    
    # Final summary
    echo ""
    if [[ $TESTS_PASSED -eq $TESTS_TOTAL ]]; then
        log_success "All performance optimizations verified successfully!"
        exit 0
    else
        log_warning "Some performance tests failed. Check the report above."
        exit 1
    fi
}

# Run main function
main "$@"