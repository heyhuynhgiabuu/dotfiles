# GitHub Copilot CLI Customization Guide

This dotfiles configuration includes customized aliases and functions for GitHub Copilot CLI to enhance your command-line experience.

## Installation

First, install the GitHub Copilot CLI extension:

```bash
gh extension install github/gh-copilot
```

## Available Aliases

### Basic Aliases
- `gcs` → `gh copilot suggest` - Get command suggestions from Copilot
- `gce` → `gh copilot explain` - Explain a command using Copilot  
- `copilot` → `gh copilot` - Direct access to Copilot CLI

### Usage Examples

```bash
# Get a command suggestion
gcs "find all javascript files modified in the last 7 days"

# Explain a complex command
gce "docker run -it --rm -v $(pwd):/app node:16"

# Access copilot directly
copilot suggest -t shell "compress all pdf files in current directory"
```

## Enhanced Functions

### `suggest()` - Interactive Command Suggestions
Get command suggestions with built-in error handling and usage help.

```bash
# Examples:
suggest "find all docker containers using more than 1GB memory"
suggest "create a git alias for interactive rebase"
suggest "compress all images in subdirectories"
```

### `explain()` - Command Explanation
Get detailed explanations of complex commands.

```bash
# Examples:  
explain "find /var/log -name '*.log' -mtime +30 -delete"
explain "awk '{sum += $1} END {print sum}' data.txt"
explain "docker-compose up --build --scale web=3"
```

### `gitsuggest()` - Git-Specific Suggestions
Get Git command suggestions optimized for Git workflows.

```bash
# Examples:
gitsuggest "undo last commit but keep changes"
gitsuggest "merge multiple commits into one"
gitsuggest "find who deleted a specific file"
```

### `k8ssuggest()` - Kubernetes-Specific Suggestions  
Get kubectl command suggestions for Kubernetes operations.

```bash
# Examples:
k8ssuggest "get all pods in kube-system namespace"
k8ssuggest "scale deployment nginx to 5 replicas"
k8ssuggest "find pods using most CPU in default namespace"
```

## Environment Configuration

The following environment variable is automatically set:
- `COPILOT_CLI_EDITOR` - Uses your default `$EDITOR` for Copilot interactions

## Integration with Existing Workflow

These Copilot customizations work seamlessly with existing dotfiles:
- Integrates with existing Git aliases (`ga`, `gcms`, `gs`, etc.)
- Complements Kubernetes aliases (`k`, `h`, `ctx`, `ns`)
- Works with tmux and other terminal tools

## Tips for Best Results

1. **Be specific**: More detailed descriptions yield better suggestions
2. **Include context**: Mention your environment (Docker, Kubernetes, etc.)
3. **Use natural language**: Describe what you want to accomplish
4. **Iterate**: Use `suggest` then `explain` to understand the suggested commands

## Troubleshooting

If you see "⚠️ GitHub Copilot CLI not installed", run:
```bash
gh extension install github/gh-copilot
```

If authentication is needed:
```bash
gh auth login
```

## Examples in Action

```bash
# Finding files
$ suggest "find all Python files with TODO comments"
# Copilot suggests: grep -r "TODO" --include="*.py" .

# Docker operations  
$ suggest "remove all stopped containers and unused images"
# Copilot suggests: docker container prune -f && docker image prune -f

# Git operations
$ gitsuggest "create a patch file from last 3 commits"
# Copilot suggests: git format-patch -3

# Kubernetes troubleshooting
$ k8ssuggest "check logs for failed pods in all namespaces"
# Copilot suggests: kubectl get pods --all-namespaces --field-selector=status.phase=Failed
```

Enjoy your enhanced command-line experience with GitHub Copilot! 🚀