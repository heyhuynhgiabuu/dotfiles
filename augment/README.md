# Augment: Context-Aware AI for Neovim

This directory contains the configuration for **AugmentCode**, a powerful AI tool that provides context-aware chat and deep workspace understanding directly within Neovim. This setup is managed by GNU Stow to ensure consistency across all development environments (macOS and Linux).

## Core Philosophy

This configuration is part of a "Dual AI" or "Hybrid AI" setup, where different tools are used for their specific strengths:

1.  **OpenCode (Terminal):** Best for long-form conversations, complex task management, and multi-step operations that involve file modifications and terminal commands.
2.  **GitHub Copilot (In-Editor):** Optimized for real-time, line-by-line code completions and suggestions as you type.
3.  **AugmentCode (In-Editor):** Excels at understanding the entire workspace context to provide intelligent chat, code explanations, and refactoring suggestions based on your project's structure.

## Key Configuration Files

-   `settings.conf`: Defines global behavior, such as completion triggers, chat history, and security settings.
-   `keymaps.conf`: Establishes consistent `<leader>a*` keyboard shortcuts for all AugmentCode actions.
-   `workspace_folders.conf`: Specifies default directories (like `~/projects`, `~/dotfiles`) to be automatically included in the workspace context.
-   `.augmentignore`: Contains global patterns (`node_modules/`, `.env`, etc.) to exclude from indexing, improving performance and security.

## Setup and Management

The configuration is managed via symlinks created by the `scripts/setup-augment-config.sh` script, which uses `stow` under the hood. Any changes made in this directory are instantly reflected in your live environment after restarting Neovim.

To troubleshoot or verify the setup, use the `:Augment status` and `:Augment log` commands within Neovim.

## Security

Authentication tokens are stored securely in `~/.local/share/vim-augment/secrets.json` and are explicitly excluded from this repository via `.gitignore`. The configuration is designed to be secure by default.

---

*Part of the cross-platform dotfiles repository. Maintained with stow for consistent configuration across macOS and Linux.*
