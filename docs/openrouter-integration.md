# OpenRouter Integration with OpenCode

## Overview
Successfully integrated OpenRouter as an additional provider in OpenCode to complement GitHub Copilot, allowing access to free models like Qwen3-Coder for non-critical tasks.

## Configuration

### 1. OpenRouter Provider Setup
Added to `opencode/opencode.json`:
```json
{
  "provider": {
    "openrouter": {
      "models": {
        "qwen/qwen3-coder:free": {}
      }
    }
  }
}
```

### 2. Authentication
Set up using OpenCode's auth system:
```bash
opencode auth login
# Selected OpenRouter from interactive menu
# Entered API key when prompted
```

### 3. Verification
Authentication status can be checked with:
```bash
opencode auth list
```

## Usage

### Running with OpenRouter Model
```bash
# Single command execution
opencode run -m qwen/qwen3-coder:free "Your prompt here"

# Interactive session
opencode -m qwen/qwen3-coder:free
```

### Available Models
Use `opencode models` to see all available models. Some notable free OpenRouter models:
- `openrouter/qwen/qwen3-coder:free` - Coding-focused model
- `openrouter/deepseek/deepseek-r1:free` - General purpose
- `openrouter/meta-llama/llama-3.3-70b-instruct:free` - Large general model
- `openrouter/google/gemini-2.0-flash-exp:free` - Fast response model

## Benefits
1. **Cost Conservation**: Use free models for routine tasks to preserve GitHub Copilot premium requests
2. **Model Diversity**: Access to different model families and capabilities
3. **Educational Access**: GitHub Education provides 300 premium requests/month
4. **Fallback Option**: Alternative when GitHub Copilot is unavailable

## Testing
Both authentication and model functionality have been verified:
- ✅ Authentication properly stored and recognized
- ✅ Model responds to queries correctly
- ✅ Code generation capabilities working
- ✅ File operations functioning

## Configuration Files
- **Config**: `opencode/opencode.json`
- **Auth**: `~/.local/share/opencode/auth.json` (managed by opencode)
- **Environment**: `OPENROUTER_API_KEY` (optional, managed by auth system)

## Notes
- API key is managed by OpenCode's auth system, not stored in config files
- The free tier of qwen3-coder has reasonable rate limits for development use
- Model selection can be done per-session or per-command