## Agent Guidelines for Dotfiles

This repository contains personal dotfiles for cross-platform development environments. Please adhere to the following guidelines, which take precedence over global rules.

-   **Purpose:** This is a collection of configuration files for tools like Neovim, tmux, and zsh. There are no build, lint, or automated test commands.

-   **Cross-platform Mandate:** All configurations **must** work on both macOS and Linux.
    -   Use the `<env>` context provided to identify the current `Platform` and ensure compatibility.

-   **Structure:** Maintain the existing directory structure as shown in the `<project>` context.
    -   Place new configurations in the appropriate tool's directory (e.g., `nvim/`, `zsh/`).

-   **Style:** Match the existing style and conventions of the file you are editing.
    -   **Example:** Use Lua for Neovim configs (`.lua`), shell script for shell configs (`.zsh`), and TOML for Aerospace (`.toml`).

-   **Modification:** Before modifying a file, use the `read` tool to understand its purpose and context within the larger setup.

-   **Commits:** Write clear and concise commit messages explaining the *why* behind the change.
    -   **Crucially:** Do not include "Generated with opencode" or any other AI attribution in commit messages for this repository.

-   **Dependencies:** Do not add any new software dependencies without explicit permission.

-   **Verification:** Since there are no automated tests, you must provide the user with simple, manual verification steps.
    -   **Example:** For a zsh alias change, provide the alias and a command to test it. For a Neovim keymap, state the keymap and how to trigger it.

---

### **Global Development Rules**

The rules in this file are specific to the `dotfiles` project and override any conflicting global rules. For general operating principles, refer to the global `opencode/AGENTS.md` file.
