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
- **Use TodoWrite/TodoRead** - Track progress on complex multi-step tasks
- **Read before editing** - Always understand current file content and structure
- **Iterative completion** - Work systematically until all requirements are met
- **Validate each step** - Test changes before proceeding to next step

### Tool Usage Guidelines
- **webfetch**: Always research current documentation and best practices
- **todowrite/todoread**: Essential for complex tasks requiring multiple steps
- **read**: Understand existing configurations before making changes
- **bash**: Test implementations and verify functionality
- **edit/write**: Only after thorough understanding and planning

## Mode and Agent Safety Matrix

| Mode/Agent           | Write/Edit | Bash | Read | TodoWrite | WebFetch | Model | Safe for Prod? |
|----------------------|:----------:|:----:|:----:|:---------:|:--------:|-------|:--------------:|
| daily                | ✅         | ✅   | ✅   | ✅        | ✅       | GPT-4.1 | ❌             |
| build                | ✅         | ✅   | ✅   | ✅        | ✅       | Gemini 2.5 Pro | ❌             |
| enhanced             | ✅         | ✅   | ✅   | ✅        | ✅       | Claude Sonnet 4 | ❌             |
| plan                 | ❌         | ❌   | ✅   | ✅        | ✅       | GPT-4.1 | ✅             |
| review               | ❌         | ❌   | ✅   | ❌        | ✅       | Claude Sonnet 4 | ✅             |
| security             | ❌         | ❌   | ✅   | ❌        | ✅       | Claude Sonnet 4 | ✅             |
| debug                | ❌         | ✅   | ✅   | ✅        | ✅       | GPT-4.1 | ✅             |
| docs                 | ✅         | ❌   | ✅   | ✅        | ✅       | GPT-4.1 | ❌             |
| security-audit       | ❌         | ❌   | ✅   | ❌        | ❌       | Claude Sonnet 4 | ✅             |
| devops-deployer      | ❌         | ✅   | ✅   | ❌        | ❌       | Gemini 2.5 Pro | ✅             |
| api-reviewer         | ❌         | ❌   | ✅   | ❌        | ❌       | Claude Sonnet 4 | ✅             |
| docs-writer          | ✅         | ❌   | ✅   | ❌        | ❌       | GPT-4.1 | ❌             |
| backend-troubleshooter| ❌        | ❌   | ✅   | ❌        | ❌       | GPT-4.1 | ✅             |
| simple-researcher    | ❌         | ❌   | ✅   | ❌        | ✅       | Gemini 2.5 Pro | ✅             |
| context-analyst      | ❌         | ❌   | ✅   | ❌        | ✅       | Claude Sonnet 4 | ✅             |
| session-summarizer   | ❌         | ❌   | ✅   | ❌        | ❌       | GPT-4.1 | ✅             |

**Legend:**  
✅ = enabled, ❌ = disabled

### Cost Optimization Strategy
- **daily mode**: Primary development using GPT-4.1 (0 premium requests on Copilot Education)
- **plan mode**: Planning and analysis using GPT-4.1 (0 premium requests, read-only)
- **enhanced mode**: Complex tasks using Claude Sonnet 4 (1x premium request per session)
- **build mode**: Alternative full-access using Claude Sonnet 4 (1x premium request per session)

### Context-Aware Operation
- **Global config context**: `{file:AGENTS.md}` loads from `~/.config/opencode/AGENTS.md`
- **Project-specific context**: OpenCode automatically loads `./AGENTS.md` from working directory
- **Dual-context system**: Global rules + project-specific guidelines work together
- **Cross-platform support**: All configurations must work on both macOS and Linux

Remember: We're building practical solutions for real problems, not showcasing technical expertise. Always research current best practices, use autonomous operation patterns for complex tasks, and optimize for cost efficiency while maintaining capability.

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
