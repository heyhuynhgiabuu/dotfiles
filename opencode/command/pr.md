---
description: Create and submit pull request with proper formatting
agent: beta
---

## Create Pull Request

**Current Branch:** `!git branch --show-current`
**Changes Summary:** `!git diff main...HEAD --stat`
**Commits:** `!git log main...HEAD --oneline`

Create a pull request following these steps:

1. **Format code** (if formatters available): `!command -v prettier > /dev/null && npm run format || echo "No formatter configured"`

2. **Push branch**: `!git push -u origin $(git branch --show-current)`

3. **Generate PR content:**
   - Title: Clear, descriptive (under 60 chars)
   - Summary: What and why this change matters
   - Testing: How to verify the changes
   - Breaking changes: Note any API/behavior changes

4. **Create PR**: `!gh pr create --title "Generated Title" --body "Generated Description"`

**Template format:**
```
## Summary
- Brief description of changes

## Testing
- How to test these changes

## Breaking Changes
- None / List any breaking changes
```