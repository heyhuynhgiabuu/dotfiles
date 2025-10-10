# Quick Fix Applier Examples

## Basic Usage Patterns

### Import Organization

#### Before: Manual Process

```bash
# Current inefficient workflow
grep "import.*from" --include="*.ts" -r src/
# Output: 47 files with import statements

read src/components/UserProfile.tsx
# Manually identify unused imports

edit src/components/UserProfile.tsx "import { unused }" ""
# Repeat for each file... 30-60 minutes
```

#### After: Single Command

```bash
# New efficient workflow
fix --type imports --dryRun
```

**Output:**

```
Import fixes applied to 12 files

Files processed: 47
Files changed: 12
Changes applied: 23
Duration: 3.2s

Changes:
  src/components/UserProfile.tsx
    - Removed unused import: { formatDate }
    - Sorted imports alphabetically
    - Grouped external imports

  src/hooks/useAuth.ts
    - Removed duplicate import: React
    - Fixed relative import path: ../utils/api

Summary: Organized 156 imports, removed 23 unused, fixed 8 paths
```

### Code Formatting

#### TypeScript Project Formatting

```bash
# Format all TypeScript files
fix --type formatting --files "src/**/*.{ts,tsx}"
```

**Output:**

```
Formatting fixes applied to 34 files

Files processed: 34
Files changed: 28
Changes applied: 28
Duration: 4.1s

Tools used:
  - Prettier: 28 files formatted
  - ESLint --fix: 15 additional fixes

Summary: Applied consistent formatting to 28 files
```

#### Python Project Formatting

```bash
# Format Python files with Black
fix --type formatting --files "**/*.py"
```

### Lint Fixes

#### Auto-fix ESLint Issues

```bash
# Fix all auto-fixable lint issues
fix --type lint
```

**Output:**

```
Lint fixes applied to 19 files

Files processed: 67
Files changed: 19
Changes applied: 45
Duration: 2.8s

Fixed issues:
  - Missing semicolons: 12 fixes
  - Quote consistency: 8 fixes
  - Spacing issues: 15 fixes
  - Prefer const over let: 10 fixes

Summary: Fixed 45 lint issues across 19 files
```

## Advanced Usage

### Dry Run Mode (Default)

```bash
# Preview changes without applying
fix --type imports --dryRun
```

**Output:**

```
DRY RUN: Import fixes preview

Would change 8 files:
  src/App.tsx
    - Would remove: import { unused } from 'lodash'
    - Would sort: 5 imports

  src/utils/helpers.ts
    - Would remove: import React from 'react' (unused)
    - Would group: external vs internal imports

No changes applied (dry run mode)
```

### Backup Mode

```bash
# Apply changes with backup files
fix --type formatting --backup
```

**Output:**

```
Formatting fixes applied to 15 files

Backups created:
  src/App.tsx.bak
  src/components/Header.tsx.bak
  src/utils/api.ts.bak
  ... (12 more)

Files processed: 15
Files changed: 15
Duration: 2.1s

Summary: Formatted 15 files, backups available
```

### Specific File Targeting

```bash
# Fix imports in specific files
fix --type imports --files "src/components/*.tsx" "src/hooks/*.ts"
```

**Output:**

```
Import fixes applied to 6 files

Target files: 6 (from patterns)
Files changed: 4
Changes applied: 11
Duration: 1.2s

Changes:
  src/components/UserCard.tsx: 3 imports organized
  src/components/Modal.tsx: 2 unused imports removed
  src/hooks/useApi.ts: 4 imports sorted
  src/hooks/useAuth.ts: 2 import paths fixed

Summary: Organized imports in 4 component/hook files
```

## Error Handling Examples

### Permission Errors

```bash
fix --type formatting --files "readonly-file.ts"
```

**Output:**

```
Formatting fixes completed with errors

Files processed: 1
Files changed: 0
Errors: 1
Duration: 0.3s

Errors:
  readonly-file.ts: Permission denied
    Suggestion: Check file permissions and ownership

Summary: 0 files formatted, 1 error encountered
```

### Syntax Errors

```bash
fix --type imports --files "broken-syntax.ts"
```

**Output:**

```
Import fixes completed with errors

Files processed: 1
Files changed: 0
Errors: 1
Duration: 0.5s

Errors:
  broken-syntax.ts: Syntax error - Unexpected token '}'
    Suggestion: Fix syntax errors before applying import fixes

Summary: 0 files processed due to syntax errors
```

### Tool Not Available

```bash
fix --type formatting
```

**Output:**

```
Formatting fixes completed with warnings

Files processed: 23
Files changed: 0
Warnings: 1
Duration: 1.1s

Warnings:
  Prettier not found in PATH
    Suggestion: Install prettier with 'npm install -g prettier'

Summary: No formatting applied, install required tools
```

## Workflow Integration Examples

### Pre-commit Hook Integration

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running quick fixes..."

# Fix imports and formatting
fix --type imports
fix --type formatting

# Check if any files were changed
if git diff --quiet; then
  echo "No fixes needed"
else
  echo "Applied automatic fixes, please review and commit"
  exit 1
fi
```

### CI/CD Pipeline Integration

```yaml
# .github/workflows/code-quality.yml
name: Code Quality

on: [push, pull_request]

jobs:
  fix-and-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Apply automatic fixes
        run: |
          fix --type imports --dryRun
          fix --type lint --dryRun

      - name: Check if fixes needed
        run: |
          if fix --type imports --dryRun | grep -q "Would change"; then
            echo "Import fixes needed"
            exit 1
          fi
```

### Development Workflow

```bash
# Daily development routine

# 1. Start of day - clean up imports
fix --type imports --backup

# 2. Before lunch - format code
fix --type formatting

# 3. Before commit - fix lint issues
fix --type lint --dryRun
fix --type lint  # Apply if preview looks good
```

## Performance Examples

### Large Codebase

```bash
# Fix imports in large TypeScript project
fix --type imports --files "src/**/*.{ts,tsx}"
```

**Output:**

```
Import fixes applied to 89 files

Files processed: 234 (89 matched patterns)
Files changed: 67
Changes applied: 156
Duration: 8.7s

Performance:
  - Files/second: 27
  - Changes/second: 18
  - Memory usage: 45MB peak

Summary: Processed large codebase efficiently
```

### Timeout Handling

```bash
# Very large operation that hits timeout
fix --type unused --files "**/*.js"
```

**Output:**

```
Unused code removal timed out

Files processed: 78 (of 156 total)
Files changed: 23
Changes applied: 45
Duration: 30.0s (timeout)

Partial results:
  Successfully processed first 78 files
  Remaining 78 files not processed

Suggestion: Process files in smaller batches
```

## Comparison: Before vs After

### Import Organization Task

**Before (Manual):**

```bash
# Step 1: Find files with imports (2 minutes)
grep -r "import.*from" src/ --include="*.ts"

# Step 2: Check each file (15 minutes)
read src/components/UserProfile.tsx
read src/components/Header.tsx
# ... repeat for 20+ files

# Step 3: Fix each file (20 minutes)
edit src/components/UserProfile.tsx "import { unused }" ""
edit src/components/Header.tsx "import React" "import React from 'react'"
# ... repeat for each fix

# Total time: 37 minutes
# Error prone: Manual identification of unused imports
# Inconsistent: Different developers, different styles
```

**After (Automated):**

```bash
# Single command (30 seconds)
fix --type imports

# Total time: 30 seconds
# Consistent: Same rules applied everywhere
# Safe: Dry-run preview, backup option
# Comprehensive: Handles all import issues at once
```

### Code Formatting Task

**Before (Manual):**

```bash
# Step 1: Run prettier on each file (10 minutes)
prettier --write src/App.tsx
prettier --write src/components/Header.tsx
# ... repeat for 50+ files

# Step 2: Run ESLint fixes (5 minutes)
eslint --fix src/App.tsx
eslint --fix src/components/Header.tsx
# ... repeat for 50+ files

# Total time: 15 minutes
# Risk: Forgetting files, inconsistent application
```

**After (Automated):**

```bash
# Single command (2 minutes)
fix --type formatting

# Total time: 2 minutes
# Comprehensive: All files processed
# Consistent: Same tools, same settings
# Safe: Backup option available
```

## Best Practices

### Effective Usage Patterns

1. **Always dry-run first**

   ```bash
   fix --type imports --dryRun  # Preview changes
   fix --type imports           # Apply if satisfied
   ```

2. **Use backups for risky operations**

   ```bash
   fix --type unused --backup   # Create .bak files
   ```

3. **Target specific areas**

   ```bash
   fix --type formatting --files "src/components/**"  # Focus on components
   ```

4. **Combine with version control**
   ```bash
   git add .                    # Stage current work
   fix --type imports           # Apply fixes
   git diff                     # Review changes
   git commit -m "Fix imports"  # Commit fixes separately
   ```

### Common Pitfalls

1. **Don't run on uncommitted changes**

   ```bash
   # BAD: Mixed changes
   # ... working on feature ...
   fix --type formatting  # Now feature + formatting mixed

   # GOOD: Separate concerns
   git commit -m "Feature work"
   fix --type formatting
   git commit -m "Format code"
   ```

2. **Don't skip dry-run for unused fixes**

   ```bash
   # BAD: Risky
   fix --type unused

   # GOOD: Safe
   fix --type unused --dryRun  # Review what will be removed
   fix --type unused           # Apply if confident
   ```

3. **Don't ignore errors**
   ```bash
   # If tool reports errors, investigate
   fix --type lint
   # "Error: ESLint not found"
   # Install ESLint before proceeding
   ```
