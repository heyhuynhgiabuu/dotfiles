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

## Agent and Mode Safety Matrix

| Agent/Mode           | Write/Edit | Bash | Read | Safe for Prod? | Notes                                    |
|----------------------|:----------:|:----:|:----:|:--------------:|------------------------------------------|
| build                | ✅         | ✅   | ✅   | ❌             | Full access, not safe for prod           |
| daily                | ✅         | ✅   | ✅   | ❌             | Full access, not safe for prod           |
| plan                 | ❌         | ❌   | ❌   | ✅             | Read-only, safe for prod                 |
| review               | ❌         | ❌   | ✅   | ✅             | Read/grep/glob/list only                 |
| security             | ❌         | ✅   | ✅   | ✅             | No write/edit, safe for prod             |
| debug                | ❌         | ✅   | ✅   | ✅             | No write/edit, safe for prod             |
| docs                 | ✅         | ❌   | ✅   | ❌             | Write/edit enabled, not safe for prod    |
| devops-deployer      | ❌         | ✅   | ✅   | ✅*            | *If only bash/read enabled, see config   |
| api-reviewer         | ❌         | ❌   | ❌   | ✅             | No write/edit, safe for prod             |
| backend-troubleshooter| ❌        | ❌   | ❌   | ✅             | No write/edit, safe for prod             |
| security-audit       | ❌         | ❌   | ❌   | ✅             | No write/edit, safe for prod             |
| docs-writer          | ❌         | ❌   | ❌   | ✅             | No write/edit, safe for prod             |
| simple-researcher    | ❌         | ❌   | ❌   | ✅             | No write/edit, safe for prod             |

**Legend:**  
✅ = enabled, ❌ = disabled

> Only use "build" or "docs" modes in non-production environments.  
> "devops-deployer" is safe for production if only read/bash are enabled and no write/edit/patch access is granted.

Remember: We're building practical solutions for real problems, not showcasing technical expertise.
