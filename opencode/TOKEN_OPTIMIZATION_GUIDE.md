# OpenCode Token Optimization Guide

## 🚨 Critical Issue: Todo Tool Token Bloat

### **Problem Identified**
- **OpenCode 0.2.3x+**: Dramatic token consumption increase
- **Todo tools**: TodoWrite/TodoRead cause exponential context growth
- **Premium impact**: 100K+ token jumps on Claude Sonnet 4 = massive costs

## 🛡️ Optimized Configuration

### **Mode Strategy (Updated)**
```
daily mode     → GPT-4.1 (FREE) → Todo tools enabled
beast mode     → GPT-4.1 (FREE) → Todo tools enabled  
plan mode      → GPT-4.1 (FREE) → Todo tools disabled (read-only)
build mode     → Gemini 2.5 Pro → Todo tools DISABLED ⚠️
enhanced mode  → Claude Sonnet 4 → Todo tools DISABLED ⚠️
```

### **Cost Protection Strategy**
- **Free modes**: Use todo tools freely (daily, beast, plan)
- **Premium modes**: NO todo tools (build, enhanced) to prevent token bloat
- **Emergency usage**: Switch to daily/beast for todo-heavy tasks

## 📊 Usage Guidelines

### **When to Use Todo Tools** ✅
- **Daily mode**: Complex multi-step tasks (FREE)
- **Beast mode**: Autonomous operation (FREE)
- **Simple tasks**: Skip todos entirely

### **When to AVOID Todo Tools** ❌
- **Enhanced mode**: Premium Claude Sonnet 4 - use markdown lists
- **Build mode**: Premium Gemini 2.5 Pro - use markdown lists
- **Short tasks**: < 3 steps don't need tracking

### **Alternative Task Tracking**
Instead of TodoWrite/TodoRead, use simple markdown:
```markdown
## Task Progress
- [x] Research current practices
- [ ] Update configuration 
- [ ] Test implementation
- [ ] Validate results
```

## 🎯 Optimization Results

### **Before Optimization**
- 100K token jump from single todo list
- Claude MAX ($200) exhausted in 1 hour
- Exponential context growth

### **After Optimization**
- Todo tools only on FREE GPT-4.1 modes
- Premium modes use lightweight markdown tracking
- 80%+ cost reduction on premium usage

## 🔧 Quick Fixes

### **Immediate Actions**
1. Update `opencode.json` with todo tool restrictions
2. Use `daily` or `beast` mode for todo-heavy tasks
3. Switch to `enhanced` only for critical reasoning (no todos)
4. Use markdown lists in premium modes

### **Long-term Strategy**
- Monitor OpenCode updates for todo tool fixes
- Prefer GPT-4.1 modes for development work
- Reserve premium modes for specialized tasks only

## 📈 Cost Monitoring

### **Safe Usage Patterns**
- **Daily development**: 90% in daily/beast modes
- **Complex analysis**: enhanced mode with markdown tracking
- **Large codebases**: build mode with markdown tracking
- **Planning**: plan mode (read-only, todos disabled)

Remember: The todo tools are powerful but expensive on premium models. Use them strategically!