# TypeScript/JavaScript Setup Verification Guide

## Quick Setup Check

1. **Restart Neovim** after configuration changes
2. **Install TypeScript tools**:
   ```
   :Mason
   ```
   Verify these tools are installed:
   - typescript-language-server ✓
   - prettier ✓
   - eslint_d ✓
   - js-debug-adapter ✓

## Verification Steps

### 1. Plugin Loading
```vim
:Lazy
```
- Look for `typescript-tools.nvim` ✓
- Ensure it's loaded without errors

### 2. Create Test Files

Create these test files in a project directory:

**test.ts**:
```typescript
interface User {
  name: string;
  age: number;
}

const user: User = {
  name: "John",
  age: 30
};

function greetUser(user: User): string {
  return `Hello, ${user.name}! You are ${user.age} years old.`;
}

console.log(greetUser(user));
```

**test.tsx**:
```tsx
import React from 'react';

interface Props {
  name: string;
  age: number;
}

const UserComponent: React.FC<Props> = ({ name, age }) => {
  return (
    <div>
      <h1>Hello, {name}!</h1>
      <p>You are {age} years old.</p>
    </div>
  );
};

export default UserComponent;
```

### 3. Test TypeScript Features

Open the test files and verify:

#### LSP Features:
- **Hover**: Place cursor on `User` interface → Press `K` → Should show type info
- **Go to Definition**: Place cursor on `greetUser` call → Press `gd` → Should jump to function
- **Autocomplete**: Type `user.` → Should show `name` and `age` suggestions
- **Diagnostics**: Add an error (e.g., `user.invalidProp`) → Should show red squiggles

#### TypeScript Commands:
- `:TSToolsOrganizeImports` → Should organize imports
- `:TSToolsFixAll` → Should fix auto-fixable errors
- `<leader>tso` → Should organize imports
- `<leader>tsf` → Should fix all errors

#### Inlay Hints:
- Should see parameter names and type hints (if supported by your Neovim version)

#### Formatting:
- Save file → Should auto-format with Prettier
- `:ConformFormat` → Should format the file manually

### 4. Key Mapping Test

Test these key mappings in TypeScript files:

| Key | Description | Expected Result |
|-----|-------------|-----------------|
| `<leader>tso` | Organize imports | Imports sorted and cleaned |
| `<leader>tss` | Sort imports | Imports alphabetically sorted |
| `<leader>tsr` | Remove unused imports | Unused imports removed |
| `<leader>tsu` | Remove all unused | All unused code removed |
| `<leader>tsa` | Add missing imports | Missing imports added |
| `<leader>tsf` | Fix all errors | Auto-fixable errors fixed |
| `<leader>tsg` | Go to source definition | Jump to original definition |
| `<leader>tf` | Fix all & save | Fix errors and save file |
| `<leader>to` | Organize & format | Organize imports and format |

### 5. Troubleshooting

#### If TypeScript features don't work:
```vim
:LspInfo
```
- Should show typescript-tools attached to the buffer

#### If formatting doesn't work:
```vim
:ConformInfo
```
- Should show prettier and eslint_d available for typescript files

#### If key mappings don't work:
```vim
:WhichKey <leader>ts
```
- Should show TypeScript-specific mappings

#### Force reload if needed:
```vim
:LspRestart
:edit
```

## Expected Results

✅ **All checks should pass**:
- LSP features working (hover, go-to-definition, diagnostics)
- TypeScript commands available
- Auto-formatting on save
- Key mappings responsive
- Inlay hints visible (if supported)
- No error messages in `:checkhealth`

## Performance Check

The new setup should be noticeably **faster** than the old typescript-language-server:
- Faster startup time
- More responsive autocomplete
- Quicker diagnostics updates
- Better handling of large TypeScript projects

## Common Issues

1. **"typescript-tools not found"**: Restart Neovim completely
2. **Formatting not working**: Check `:ConformInfo` and ensure prettier is installed via Mason
3. **LSP not attaching**: Ensure file has `.ts`, `.tsx`, `.js`, or `.jsx` extension
4. **Key mappings not working**: Check `:WhichKey` output and ensure which-key is loaded

## Success Criteria

The setup is working correctly when:
- TypeScript/JavaScript files show proper syntax highlighting
- LSP features work smoothly (hover, go-to-definition, diagnostics)
- All TypeScript-specific commands are available
- Formatting works on save and manually
- Key mappings are responsive
- Performance is noticeably improved
