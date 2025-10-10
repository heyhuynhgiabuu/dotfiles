#!/usr/bin/env sh

# OpenCode Plugin Sandbox Utilities
# POSIX-compliant helper scripts for process isolation and resource limits
# 
# Security functions:
# - Resource limit enforcement via ulimit
# - Cross-platform compatibility (macOS/Linux)
# - Privilege verification and sandbox setup
# - Process monitoring and cleanup

set -e

# Color definitions for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default resource limits
DEFAULT_MEMORY_MB=128
DEFAULT_CPU_SECONDS=10
DEFAULT_FILE_DESCRIPTORS=50

# Logging functions
log_info() {
    printf "${GREEN}[INFO]${NC} %s\n" "$1"
}

log_warn() {
    printf "${YELLOW}[WARN]${NC} %s\n" "$1"
}

log_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1"
}

log_debug() {
    if [ "${DEBUG:-0}" = "1" ]; then
        printf "${BLUE}[DEBUG]${NC} %s\n" "$1"
    fi
}

# Check if running on macOS or Linux
get_platform() {
    uname -s
}

# Get current user info
get_user_info() {
    id
}

# Apply memory limit (convert MB to KB for ulimit)
apply_memory_limit() {
    local memory_mb="${1:-$DEFAULT_MEMORY_MB}"
    local memory_kb=$((memory_mb * 1024))
    
    log_debug "Applying memory limit: ${memory_mb}MB (${memory_kb}KB)"
    
    if ! ulimit -v "$memory_kb" 2>/dev/null; then
        log_warn "Failed to set memory limit to ${memory_mb}MB"
        return 1
    fi
    
    log_info "Memory limit set: ${memory_mb}MB"
    return 0
}

# Apply CPU time limit
apply_cpu_limit() {
    local cpu_seconds="${1:-$DEFAULT_CPU_SECONDS}"
    
    log_debug "Applying CPU limit: ${cpu_seconds} seconds"
    
    if ! ulimit -t "$cpu_seconds" 2>/dev/null; then
        log_warn "Failed to set CPU limit to ${cpu_seconds} seconds"
        return 1
    fi
    
    log_info "CPU limit set: ${cpu_seconds} seconds"
    return 0
}

# Apply file descriptor limit
apply_fd_limit() {
    local fd_count="${1:-$DEFAULT_FILE_DESCRIPTORS}"
    
    log_debug "Applying file descriptor limit: ${fd_count}"
    
    if ! ulimit -n "$fd_count" 2>/dev/null; then
        log_warn "Failed to set file descriptor limit to ${fd_count}"
        return 1
    fi
    
    log_info "File descriptor limit set: ${fd_count}"
    return 0
}

# Apply all resource limits
apply_all_limits() {
    local memory_mb="${1:-$DEFAULT_MEMORY_MB}"
    local cpu_seconds="${2:-$DEFAULT_CPU_SECONDS}"
    local fd_count="${3:-$DEFAULT_FILE_DESCRIPTORS}"
    
    log_info "Applying resource limits..."
    
    apply_memory_limit "$memory_mb"
    apply_cpu_limit "$cpu_seconds"
    apply_fd_limit "$fd_count"
    
    log_info "Resource limits applied successfully"
}

# Check current ulimit settings
check_limits() {
    log_info "Current resource limits:"
    printf "  Memory (virtual): %s KB\n" "$(ulimit -v)"
    printf "  CPU time: %s seconds\n" "$(ulimit -t)"
    printf "  File descriptors: %s\n" "$(ulimit -n)"
    printf "  Core file size: %s\n" "$(ulimit -c)"
    printf "  Stack size: %s KB\n" "$(ulimit -s)"
}

# Test memory limit enforcement
test_memory_limit() {
    local test_mb="${1:-64}"
    
    log_info "Testing memory limit enforcement (${test_mb}MB)..."
    
    # Apply strict memory limit
    apply_memory_limit "$test_mb"
    
    # Try to allocate more memory than allowed (using Node.js)
    if command -v node >/dev/null 2>&1; then
        local test_kb=$((test_mb * 1024 * 2)) # Try to allocate 2x the limit
        
        if node -e "
            try {
                const buffer = Buffer.alloc(${test_kb} * 1024);
                console.log('Memory allocation succeeded - limit not enforced');
                process.exit(1);
            } catch (error) {
                console.log('Memory allocation failed - limit enforced');
                process.exit(0);
            }
        " 2>/dev/null; then
            log_info "Memory limit enforcement: WORKING"
            return 0
        else
            log_error "Memory limit enforcement: FAILED"
            return 1
        fi
    else
        log_warn "Node.js not available - skipping memory test"
        return 0
    fi
}

# Test CPU limit enforcement
test_cpu_limit() {
    local test_seconds="${1:-5}"
    
    log_info "Testing CPU limit enforcement (${test_seconds} seconds)..."
    
    # Apply strict CPU limit
    apply_cpu_limit "$test_seconds"
    
    # Start time tracking
    start_time=$(date +%s)
    
    # Run CPU-intensive task that should be killed by limit
    if timeout $((test_seconds + 5)) sh -c '
        i=0
        while true; do
            i=$((i + 1))
            if [ $((i % 1000000)) -eq 0 ]; then
                echo "Still running: $i iterations"
            fi
        done
    ' 2>/dev/null; then
        log_error "CPU limit enforcement: FAILED (process not killed)"
        return 1
    else
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        
        if [ "$duration" -le $((test_seconds + 2)) ]; then
            log_info "CPU limit enforcement: WORKING (killed after ${duration}s)"
            return 0
        else
            log_warn "CPU limit enforcement: PARTIAL (killed after ${duration}s, expected ~${test_seconds}s)"
            return 1
        fi
    fi
}

# Test file descriptor limit enforcement
test_fd_limit() {
    local test_fd="${1:-20}"
    
    log_info "Testing file descriptor limit enforcement (${test_fd} FDs)..."
    
    # Apply strict FD limit
    apply_fd_limit "$test_fd"
    
    # Try to open more files than allowed
    temp_dir=$(mktemp -d)
    trap "rm -rf '$temp_dir'" EXIT
    
    fd_count=0
    while [ "$fd_count" -lt $((test_fd + 10)) ]; do
        if exec 3>"$temp_dir/test_$fd_count" 2>/dev/null; then
            fd_count=$((fd_count + 1))
        else
            break
        fi
    done
    
    # Close all file descriptors
    fd_num=3
    while [ "$fd_num" -lt $((fd_count + 3)) ]; do
        exec 3>&- 2>/dev/null || true
        fd_num=$((fd_num + 1))
    done
    
    if [ "$fd_count" -le "$test_fd" ]; then
        log_info "File descriptor limit enforcement: WORKING (opened ${fd_count}/${test_fd})"
        return 0
    else
        log_warn "File descriptor limit enforcement: PARTIAL (opened ${fd_count}/${test_fd})"
        return 1
    fi
}

# Verify platform-specific features
verify_platform() {
    local platform
    platform=$(get_platform)
    
    log_info "Platform: $platform"
    
    case "$platform" in
        "Darwin")
            log_info "macOS detected - checking features..."
            # Check macOS-specific ulimit behavior
            if ulimit -v 65536 2>/dev/null; then
                log_info "Virtual memory limit: SUPPORTED"
            else
                log_warn "Virtual memory limit: NOT SUPPORTED"
            fi
            ;;
        "Linux")
            log_info "Linux detected - checking features..."
            # Check Linux-specific features
            if [ -d "/proc" ]; then
                log_info "Proc filesystem: AVAILABLE"
            fi
            if command -v cgroups >/dev/null 2>&1; then
                log_info "Cgroups: AVAILABLE"
            else
                log_debug "Cgroups: NOT AVAILABLE"
            fi
            ;;
        *)
            log_warn "Unknown platform: $platform"
            log_warn "Some features may not work correctly"
            ;;
    esac
}

# Run comprehensive verification
verify_all() {
    log_info "Running comprehensive sandbox verification..."
    
    verify_platform
    check_limits
    
    log_info "Testing resource limit enforcement..."
    
    # Test with reduced limits for safety
    test_memory_limit 32
    test_cpu_limit 3
    test_fd_limit 15
    
    log_info "Sandbox verification completed"
}

# Show help message
show_help() {
    cat << 'EOF'
OpenCode Plugin Sandbox Utilities

Usage: sandbox_utils.sh <command> [options]

Commands:
    verify              Run comprehensive verification
    check-limits        Show current ulimit settings
    apply-limits        Apply default resource limits
    test-memory [MB]    Test memory limit enforcement
    test-cpu [seconds]  Test CPU limit enforcement
    test-fd [count]     Test file descriptor limit enforcement
    platform            Show platform information
    help                Show this help message

Examples:
    ./sandbox_utils.sh verify
    ./sandbox_utils.sh apply-limits
    ./sandbox_utils.sh test-memory 64
    ./sandbox_utils.sh test-cpu 5

Environment Variables:
    DEBUG=1             Enable debug output
    MEMORY_MB=128       Default memory limit (MB)
    CPU_SECONDS=10      Default CPU time limit (seconds)
    FD_COUNT=50         Default file descriptor limit

Exit Codes:
    0    Success
    1    Failure or unsupported feature
    2    Invalid arguments
EOF
}

# Main command dispatcher
main() {
    case "${1:-help}" in
        "verify")
            verify_all
            ;;
        "check-limits")
            check_limits
            ;;
        "apply-limits")
            apply_all_limits "${MEMORY_MB:-$DEFAULT_MEMORY_MB}" \
                           "${CPU_SECONDS:-$DEFAULT_CPU_SECONDS}" \
                           "${FD_COUNT:-$DEFAULT_FILE_DESCRIPTORS}"
            ;;
        "test-memory")
            test_memory_limit "${2:-32}"
            ;;
        "test-cpu")
            test_cpu_limit "${2:-3}"
            ;;
        "test-fd")
            test_fd_limit "${2:-15}"
            ;;
        "platform")
            verify_platform
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            log_error "Unknown command: $1"
            show_help
            exit 2
            ;;
    esac
}

# Run main function with all arguments
main "$@"