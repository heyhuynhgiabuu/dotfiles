---
description: Load project context and prime for development
agent: build
---

## Load Project Context

**Project structure:** `!find . -type f -name "*.md" -o -name "package.json" -o -name "*.toml" -o -name "*.yaml" -o -name "*.yml" | head -20`
**Git info:** `!git log --oneline -3 && echo "Branch: $(git branch --show-current)"`

**Key files:**
- **README:** @README.md
- **Config:** @package.json (if exists)
- **OpenCode:** @opencode.json (if exists) 
- **Agents:** @AGENTS.md (if exists)

**Development context:**
1. **Project type:** Analyze package.json/configs to determine stack
2. **Recent activity:** Review recent commits for current focus
3. **Available commands:** List custom commands and scripts
4. **Dependencies:** Note major frameworks/libraries in use

**Priming complete.** Ready for development tasks.

**Available patterns:**
- Configuration files loaded
- Project structure understood  
- Development environment assessed
- Ready to assist with coding tasks