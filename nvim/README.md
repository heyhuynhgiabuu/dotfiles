# Neovim & NvChad Integration

This directory explains the integration of the NvChad v2.0 framework into this dotfiles repository. The goal is to leverage NvChad's robust baseline while maintaining a portable, version-controlled, and highly customized set of personal configurations.

## 📁 Core Architecture: Separation of Concerns

The setup is designed to keep the NvChad framework itself separate from your personal customizations. This makes updating NvChad safe and easy.

1.  **NvChad Base (`~/.config/nvim`):** The core NvChad framework is installed here. This directory is **not** tracked by Git.
2.  **Custom Configurations (`~/dotfiles/nvim/.config/nvim/lua/custom`):** All of your personal settings, plugins, and keymaps are stored here. This directory **is** tracked by Git.
3.  **Symlinking:** The `install.sh` script creates a symbolic link from `~/.config/nvim/lua/custom` to the `custom` directory within your dotfiles. This is the crucial step that injects your personal configuration into NvChad.

This architecture allows you to update, modify, or even replace the NvChad base without losing your personalized setup.

## 🚀 Key Features & Customizations

This configuration enhances the base NvChad experience with a focus on a productive, IDE-like workflow.

-   **IDE-like Debugging:** A sophisticated multi-panel debug UI for Java and Go, powered by `nvim-dap-ui`.
-   **Standardized F-Key Hotkeys:** A full suite of F-keys (F3-F12) provides a consistent and intuitive interface for debugging, testing, and navigation across different languages.
-   **Optimized for Java & Spring Boot:** Deep integration with `jdtls` provides intelligent completions, automatic project detection (Maven/Gradle), and seamless debugging for Spring Boot applications.
-   **Simplified UI (KISS):** The configuration intentionally uses `NvimTree` for its speed and simplicity, avoiding the complexity of other file explorers.

## 📦 Management Scripts

To make maintenance painless, this repository includes several helper scripts:

-   `./scripts/setup/install.sh`: The main setup script that installs NvChad and creates the necessary symlinks.
-   `./scripts/setup/update-nvchad.sh`: Safely updates the NvChad base to the latest version while preserving your custom configurations.
-   `./scripts/nvchad-health.sh`: A diagnostic tool to verify that NvChad is installed correctly and that all symlinks are intact.

## 🔧 Customization Guide

To modify the configuration, edit the files within the `nvim/.config/nvim/lua/custom/` directory:

-   **Plugins:** Add or remove plugins in `plugins.lua`.
-   **Keymaps:** Add custom shortcuts in `mappings.lua` or `keymaps.lua`.
-   **LSP:** Configure language server behavior in `lsp-config.lua`.
-   **NvChad Settings:** Tweak core NvChad options in `chadrc.lua`.

After making changes, restart Neovim and run `:Lazy sync` to apply them.

## 📚 Essential Resources

-   [NvChad Documentation](https://nvchad.com/)
-   [Lazy.nvim Plugin Manager](https://github.com/folke/lazy.nvim)
-   [nvim-dap-ui (Debugging)](https://github.com/rcarriga/nvim-dap-ui)
-   [nvim-jdtls (Java)](https://github.com/mfussenegger/nvim-jdtls)
