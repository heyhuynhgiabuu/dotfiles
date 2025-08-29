---
description: Generate conventional commit message and create commit
agent: build
---

## Generate Conventional Commit Message

**Analysis:** `!git status && git diff --cached --stat`
**Recent Commits:** `!git log --oneline -5`

Generate a conventional commit message following this format:
- `feat:` for new features
- `fix:` for bug fixes  
- `docs:` for documentation changes
- `style:` for formatting/styling
- `refactor:` for code restructuring
- `test:` for adding/updating tests
- `chore:` for maintenance tasks

**Requirements:**
1. Analyze the staged changes above
2. Write a clear, concise commit message under 50 characters
3. Add detailed description if needed (separate line)
4. Execute the commit with the generated message

**Example format:**
```
feat: add user authentication system

- Implement JWT token validation
- Add login/logout endpoints
- Update user model with auth fields
```

Create the commit after generating the message.