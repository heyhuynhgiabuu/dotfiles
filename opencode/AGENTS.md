# Global Development Rules

## Communication Style
- **Be direct and casual** - Skip formal language, get to the point
- **Keep things simple and practical** - Focus on solutions that actually work
- **Use developer-friendly language** - Avoid jargon, explain in plain terms
- **Minimalist approach** - Less is more, essential info only

## Code Standards

### File Size Limits (Critical)
- **Excellent**: < 150 lines per file
- **Good**: 150-200 lines per file  
- **Acceptable**: 200-300 lines per file
- **Refactor needed**: > 300 lines per file

When suggesting code changes, always check line count and recommend splitting if needed.

### Code Quality
- **Readable over clever** - Simple code that works beats complex optimizations
- **Practical over perfect** - Ship working solutions, improve later
- **Comment only when necessary** - Good code should be self-explanatory
- **Consistent naming** - Use clear, descriptive variable/function names

## Security & Best Practices
- **Security first** - Always consider security implications
- **No hardcoded secrets** - Use environment variables
- **Minimal dependencies** - Only add what you actually need
- **Error handling** - Handle errors gracefully, log appropriately

## Documentation
- **Essential docs only** - Skip obvious explanations
- **Show, don't tell** - Code examples over long descriptions
- **Keep it short** - Max 150 words unless complex
- **Developer-focused** - What do they need to know to use/maintain this?

## Problem Solving
- **Start simple** - Try the obvious solution first
- **Fix, then optimize** - Get it working, then make it better
- **One problem at a time** - Don't over-engineer solutions
- **Ask for clarification** - Better to ask than assume

## Output Style
- Use bullet points and short paragraphs
- Include working code examples
- Explain the "why" briefly
- Focus on actionable advice
- Skip unnecessary introductions

## Team Context
- **Solo developer workflow** - No bureaucratic processes
- **Marketing company culture** - Casual, practical, results-focused
- **Remote work** - Clear, concise communication
- **Educational domain** - Keep security and simplicity in mind

## OpenCode Best Practices

### Research and Verification
- **Always research first** - Use webfetch to verify current best practices
- **Check official documentation** - Don't rely on outdated information
- **Test thoroughly** - Validate solutions work in real scenarios
- **Consider cross-platform compatibility** - Ensure configs work on macOS and Linux

### Autonomous Operation Patterns
- **Read before editing** - Always understand current file content and structure
- **Iterative completion** - Work systematically until all requirements are met
- **Validate each step** - Test changes before proceeding to next step
- **Use simple markdown lists** - Track progress with bullet points and checkboxes

### Tool Usage Guidelines
- **webfetch**: Always research current documentation and best practices
- **read**: Understand existing configurations before making changes
- **bash**: Test implementations and verify functionality
- **edit/write**: Only after thorough understanding and planning

## **Simplified Mode Safety Matrix**

| Mode           | Write/Edit | Bash | Read | TodoWrite | WebFetch | Model | Cost | Primary Use |
|----------------|:----------:|:----:|:----:|:---------:|:--------:|-------|:----:|-------------|
| **daily**      | ✅         | ✅   | ✅   | ✅        | ✅       | GPT-4.1 | FREE | Interactive development |
| **beast**      | ✅         | ✅   | ✅   | ✅        | ✅       | GPT-4.1 | FREE | Autonomous complex tasks |
| **plan**       | ❌         | ❌   | ✅   | ❌        | ✅       | GPT-4.1 | FREE | Read-only analysis |
| **build**      | ✅         | ✅   | ✅   | ❌        | ✅       | Gemini 2.5 Pro | 1x | Large codebases |
| **enhanced**   | ✅         | ✅   | ✅   | ❌        | ✅       | Claude Sonnet 4 | 1x | Critical reasoning |

**Note**: ✅ = enabled by default, ❌ = explicitly disabled. TodoWrite tools disabled in premium modes to prevent token bloat.

### **Agent Tools Matrix**

| Agent/Mode     | Write/Edit | Bash | Read | TodoWrite | WebFetch | Model | Safe for Prod? |
|----------------|:----------:|:----:|:----:|:---------:|:--------:|-------|:--------------:|
| security-audit | ❌         | ❌   | ✅   | ❌        | ❌       | Claude Sonnet 4 | ✅             |
| devops-deployer| ❌         | ✅   | ✅   | ❌        | ❌       | GPT-4.1 | ✅             |
| api-reviewer   | ❌         | ❌   | ✅   | ❌        | ❌       | Claude Sonnet 4 | ✅             |
| docs-writer    | ✅         | ❌   | ✅   | ❌        | ❌       | GPT-4.1 | ❌             |
| backend-troubleshooter| ❌  | ❌   | ✅   | ❌        | ❌       | GPT-4.1 | ✅             |
| simple-researcher| ❌       | ❌   | ✅   | ❌        | ✅       | GPT-4.1 | ✅             |
| context-analyst| ❌         | ❌   | ✅   | ❌        | ✅       | Claude Sonnet 4 | ✅             |
| session-summarizer| ❌      | ❌   | ✅   | ❌        | ❌       | GPT-4.1 | ✅             |

**Legend:**  
✅ = enabled, ❌ = disabled

### **Cost Optimization Strategy**

**Primary Workflow (FREE):**
- **daily mode**: Interactive development, debugging, standard coding (GPT-4.1)
- **beast mode**: Complex autonomous tasks, research, optimization (GPT-4.1)  
- **plan mode**: Architecture planning, read-only analysis (GPT-4.1)

**Premium Escalation:**
- **build mode**: When context limit exceeded - Gemini 2.5 Pro with 2M context
- **enhanced mode**: Critical reasoning tasks - Claude Sonnet 4 for security/architecture

### GPT-4.1 Optimization Features
- **Beast Mode v3 Integration**: Autonomous operation, reduced verbosity, enhanced research
- **Improved Research Protocol**: Mandatory webfetch for current information, recursive link following
- **Smart File Management**: Avoid redundant reads, efficient context gathering
- **Markdown Task Tracking**: Simple checkboxes and bullet points for complex workflows
- **Environment Management**: Proactive .env file creation, security best practices

### Context-Aware Operation
- **Global config context**: `{file:AGENTS.md}` loads from `~/.config/opencode/AGENTS.md`
- **Project-specific context**: OpenCode automatically loads `./AGENTS.md` from working directory
- **Dual-context system**: Global rules + project-specific guidelines work together
- **Cross-platform support**: All configurations must work on both macOS and Linux

Remember: We're building practical solutions for real problems, not showcasing technical expertise. Always research current best practices, use autonomous operation patterns for complex tasks, and optimize for cost efficiency while maintaining capability.

## Recommended Usage Patterns

### **Optimized 5-Mode Strategy**

**Use these modes in order of priority for maximum cost efficiency:**

### **Free GPT-4.1 Modes (80% of usage)**
- **daily mode**: Primary development workflow - Interactive coding, debugging, standard tasks
- **beast mode**: Autonomous complex tasks - Research, multi-step implementations, optimization
- **plan mode**: Architecture and analysis - Read-only planning, reviews, research

### **Premium Modes (20% of usage)**
- **build mode**: Large codebases - Gemini 2.5 Pro with 2M context for massive files/projects
- **enhanced mode**: Critical reasoning - Claude Sonnet 4 for security, architecture decisions

### **Model Selection Logic**
1. **Start with daily mode** → covers 60% of tasks (FREE)
2. **Upgrade to beast mode** → for complex autonomous work (FREE)
3. **Use plan mode** → for read-only analysis (FREE)
4. **Switch to build mode** → when context limit exceeded (1x premium)
5. **Use enhanced mode** → for critical reasoning tasks (1x premium)

### **Cost Optimization Tips**
- **Daily development**: Stick to `daily` and `beast` modes
- **Large files**: Only use `build` mode when GPT-4.1 hits context limits
- **Security/Architecture**: Use `enhanced` mode for critical decisions only
- **Planning**: Always use `plan` mode for read-only analysis

## Enhanced Prompt System

This directory includes enhanced prompts in `prompts/` that provide:

- **Comprehensive dotfiles expertise** - Deep understanding of Unix/macOS development environments
- **Educational approach** - Explains WHY solutions work, not just HOW
- **Research-first methodology** - Always verifies against current documentation
- **Autonomous operation** - Works until problems are completely solved
- **Quality assurance** - Rigorous testing and validation

Use the **enhanced** mode for complex configuration tasks that benefit from deep expertise and thorough validation.

## Symlink Setup

This OpenCode configuration is designed to be symlinked to `~/.config/opencode/`:
- **Global config**: `~/.config/opencode/opencode.json` (this file via symlink)
- **Global rules**: `~/.config/opencode/AGENTS.md` (this file via symlink)
- **Project rules**: Each repository may have its own `AGENTS.md` with specific guidelines
- **Cross-platform support**: All configurations work on both macOS and Linux
