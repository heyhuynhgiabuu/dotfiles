# OpenCode Optimized Configuration - Minimalist Setup

## 🎯 Philosophy: KISS (Keep It Simple, Stupid)

Cấu hình tối giản với **1 free model + 3 modes** tối ưu cho hiệu quả cost và performance.

## 📊 Simplified Strategy

### **🆓 Primary Model (FREE)**
- **Qwen3-Coder:free** - Best coding model miễn phí với context 262K
  - Specialized reasoning capabilities
  - Excellent for development và debugging  
  - Performance tốt cho coding tasks hàng ngày

### **💎 Premium Models (Strategic)**
- **Claude Sonnet 4** - Critical analysis, security review
- **Qwen3-Coder (Trả phí)** - Large codebase (262K context, mạnh hơn free)

## 🛠️ 3-Mode Configuration

### **Core Setup**
```json
{
  "provider": {
    "openrouter": {
      "models": {
        "qwen/qwen3-coder:free": {},
        "qwen/qwen3-coder": {}
      }
    }
  },
  "model": "openrouter/qwen/qwen3-coder:free"
}
```

### **Mode Distribution**
```bash
# 🆓 DEFAULT - Daily Development (FREE)
opencode                    # → qwen3-coder:free

# 🔥 BEAST - Critical Analysis (Premium)  
opencode --mode beast       # → claude-sonnet-4

# 💎 BUILD - Large Codebase (Premium)
opencode --mode build       # → qwen/qwen3-coder (trả phí)
```

## 🎮 Usage Patterns

### **90% Daily Usage (FREE)**
```bash
# Development tasks
opencode "Fix this bug"
opencode "Write a function to..."
opencode "Debug this error"
opencode "Refactor this code"

# All agents using free model
opencode agent docs-writer "Document this API"
opencode agent backend-troubleshooter "Analyze these logs"
opencode agent simple-researcher "Find examples of..."
```

### **10% Strategic Usage (Premium)**
```bash
# Security analysis (1 premium request)
opencode --mode beast "Security review this authentication code"

# Architecture decisions (1 premium request)  
opencode --mode beast "Design microservices architecture for..."

# Large codebase analysis (1 premium request)
opencode --mode build "Analyze this entire backend for optimization"
```

## 📈 Benefits Achieved

### **✅ Cost Optimization**
- **90% cost reduction**: Daily work sử dụng DeepSeek-R1:free
- **300 premium requests/month preserved** cho critical tasks
- **Unlimited coding capacity** với free model chất lượng cao

### **✅ Performance Excellence**  
- **DeepSeek-R1**: Top-tier reasoning cho coding tasks
- **Claude Sonnet 4**: Best-in-class cho security/architecture
- **Gemini 2.5 Pro**: Unmatched large context analysis

### **✅ Operational Simplicity**
- **1 free model**: Dễ nhớ, consistent experience
- **3 modes**: Clear decision making (daily/critical/large)
- **Minimal complexity**: Ít confusion, faster workflow

## 🔧 Agent Assignment

### **Free Agents (DeepSeek-R1)**
- `docs-writer` - Documentation generation
- `backend-troubleshooter` - Debug và error analysis
- `simple-researcher` - Code examples và research
- `session-summarizer` - Conversation summaries

### **Premium Agents (Claude Sonnet 4)**
- `security-audit` - Security vulnerability assessment
- `api-reviewer` - Performance và architecture review  
- `context-analyst` - OpenCode billing analysis

### **Hybrid Agent (GPT-4.1)**
- `devops-deployer` - Docker và infrastructure (balanced cost/capability)

## 📋 Quick Reference

### **Daily Commands**
```bash
# Default (free)
opencode "your prompt"

# Premium modes  
opencode --mode beast "critical analysis"
opencode --mode build "large codebase task"

# Model verification
opencode models | grep qwen
opencode auth list
```

### **Model Comparison**
| Model | Cost | Best For | Quality |
|-------|------|----------|---------|
| Qwen3-Coder:free | FREE | Coding, debugging, development | Excellent |
| Claude Sonnet 4 | Premium | Security, architecture, critical analysis | Best |
| Qwen3-Coder (Trả phí) | Premium | Large context (262K), codebase analysis | Best for code |

## 🧪 Verification Steps

```bash
# 1. Test default free model
opencode "What is 8 + 7?"

# 2. Test coding capability
opencode "Write a Python function for binary search"

# 3. Test premium mode (uses 1 request)
opencode --mode beast "What are the security risks in this auth flow?"

# 4. Verify configuration
cat ~/.config/opencode/opencode.json
```

## 🎯 Decision Framework

### **Use FREE (Qwen3-Coder:free) for:**
- Daily coding tasks (90% of work)
- Bug fixes và debugging
- Code refactoring và optimization
- Documentation writing
- API development
- General problem solving

### **Use PREMIUM for:**
- Security reviews và vulnerability assessment
- Complex architecture decisions
- Large codebase analysis (>100k lines)
- Critical business logic design
- Compliance và audit requirements

### **Beast Mode Command Examples**
```bash
# Critical security analysis
opencode --mode beast "Audit this authentication system for vulnerabilities"

# Complex architecture decisions
opencode --mode beast "Design a scalable microservices architecture"

# High-stakes debugging  
opencode --mode beast "Analyze this production issue and recommend fixes"
```

## 💡 Pro Tips

### **Maximizing FREE Model Value**
- Qwen3-Coder:free excels at step-by-step reasoning
- Perfect for TDD và systematic development
- Great for explaining complex code patterns
- Reliable for cross-platform compatibility advice

### **Strategic Premium Usage**
- Group related premium tasks in same session
- Use beast mode for high-stakes decisions
- Leverage build mode for major refactoring projects
- Reserve premium for tasks requiring absolute accuracy

---

**Result**: Simplified, cost-effective configuration với unlimited daily development capacity sử dụng premium-quality free model. Perfect balance của simplicity và capability.