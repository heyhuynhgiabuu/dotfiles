#!/bin/bash
# Zsh Performance Benchmark Script

echo "🚀 Zsh Performance Benchmark"
echo "=============================="
echo ""

# Function to measure startup time
measure_startup() {
    local total=0
    local iterations=10
    
    echo "📊 Running $iterations iterations..."
    
    for i in $(seq 1 $iterations); do
        # Measure time in milliseconds
        local start
        local end
        local duration
        start=$(gdate +%s%3N 2>/dev/null || date +%s%3N)
        zsh -i -c exit
        end=$(gdate +%s%3N 2>/dev/null || date +%s%3N)
        duration=$((end - start))
        
        echo "  Run $i: ${duration}ms"
        total=$((total + duration))
    done
    
    local average=$((total / iterations))
    
    echo ""
    echo "📈 Results:"
    echo "  Total time: ${total}ms"
    echo "  Average startup: ${average}ms"
    echo ""
    
    # Performance rating
    if [ "$average" -lt 100 ]; then
        echo "🔥 BLAZING FAST! (< 100ms)"
    elif [ "$average" -lt 250 ]; then
        echo "✅ FAST (100-250ms)"
    elif [ "$average" -lt 500 ]; then
        echo "⚠️  ACCEPTABLE (250-500ms)"
    else
        echo "🐌 SLOW (> 500ms) - needs optimization"
    fi
}

# Function to profile zsh startup
profile_startup() {
    echo ""
    echo "🔍 Profiling startup components..."
    echo ""
    
    # Create temporary profile script
    cat > /tmp/zsh_profile.zsh << 'EOF'
zmodload zsh/zprof
source ~/.zshrc
zprof
EOF
    
    zsh /tmp/zsh_profile.zsh
    rm /tmp/zsh_profile.zsh
}

# Function to check for common issues
check_issues() {
    echo ""
    echo "🔧 Checking for performance issues..."
    echo ""
    
    # Check for Oh My Zsh
    if grep -q "source.*oh-my-zsh.sh" ~/.zshrc 2>/dev/null; then
        echo "⚠️  Oh My Zsh detected - consider removing for 2-3x speed boost"
    else
        echo "✅ No Oh My Zsh bloat detected"
    fi
    
    # Check for compinit optimization
    if grep -q "compinit -C" ~/.zsh/performance.zsh 2>/dev/null; then
        echo "✅ Optimized compinit detected"
    else
        echo "💡 Consider using 'compinit -C' for faster startup"
    fi
    
    # Check zcompdump age
    if [ -f ~/.zcompdump ]; then
        local age
        age=$(($(date +%s) - $(stat -f %m ~/.zcompdump 2>/dev/null || stat -c %Y ~/.zcompdump)))
        if [ "$age" -gt 86400 ]; then
            echo "✅ zcompdump cache is recent ($((age / 3600))h old)"
        else
            echo "💡 zcompdump cache is fresh"
        fi
    fi
    
    # Check for zinit
    if [ -d "$HOME/.local/share/zinit" ]; then
        echo "✅ Zinit plugin manager detected"
    else
        echo "💡 Consider using Zinit for faster plugin loading"
    fi
}

# Main execution
case "${1:-all}" in
    startup)
        measure_startup
        ;;
    profile)
        profile_startup
        ;;
    check)
        check_issues
        ;;
    all)
        measure_startup
        check_issues
        echo ""
        echo "💡 Run './benchmark.sh profile' for detailed profiling"
        ;;
    *)
        echo "Usage: $0 [startup|profile|check|all]"
        exit 1
        ;;
esac
