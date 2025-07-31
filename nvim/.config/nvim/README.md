# Neovim Configuration for an Enhanced Development Experience

This directory contains a Neovim setup based on NvChad, heavily customized to provide a streamlined, powerful, and IDE-like development workflow, especially for Java and Go.

## Core Philosophy: KISS (Keep It Simple, Stupid)

This configuration prioritizes simplicity and powerful, essential features over excessive complexity. Key decisions include:
-   Using **NvimTree** for its simplicity and speed over more complex file explorers.
-   A strong focus on a clean, intuitive **debugging experience** that mirrors modern IDEs.
-   Ensuring all configurations are **cross-platform** (macOS & Linux).

## Key Features

### 1. IDE-like Debugging (DAP UI)
The central feature is a sophisticated debugging interface powered by `nvim-dap-ui`. It provides a multi-panel layout that separates concerns logically:
-   **Scopes & Variables:** Inspect the state of your application.
-   **Call Stack:** Trace the execution flow.
-   **Breakpoints & Watchers:** Manage breakpoints and watch expressions.
-   **REPL & Console:** A dedicated area for logs and interactive commands.

### 2. Standardized F-Key Hotkeys
A full set of F-keys (F3-F12) provides a familiar, muscle-memory-friendly workflow for common actions:
-   **F3:** Toggle File Explorer (`NvimTree`)
-   **F4:** Toggle the entire Debug UI
-   **F5:** Start / Continue Debugging
-   **F9:** Toggle Breakpoint
-   **F10:** Step Over
-   **F11:** Step Into
-   **F12:** Quick Debug for Java/Go

### 3. Powerful Java & Spring Boot Support
Leverages `jdtls` to provide a first-class Java development experience, including:
-   Automatic detection of Maven and Gradle projects.
-   Advanced debugging and testing support for Spring Boot applications.
-   Intelligent auto-completion and code navigation.

## Core Plugins

-   **UI & Navigation:** `NvimTree`, `nvim-dap-ui`, `lualine`, `bufferline`, `which-key`.
-   **Development:** `nvim-jdtls` (Java), `nvim-dap` (Debug Adapter Protocol), `nvim-cmp` (autocompletion), `nvim-treesitter` (syntax highlighting).
-   **LSP Management:** `mason.nvim` for easy installation and management of language servers.
-   **Git Integration:** `gitsigns.nvim` and `fugitive.vim` for seamless Git operations within the editor.


- **Đơn giản hóa**: Loại bỏ Neo-tree phức tạp, giữ NvimTree
- **Essential features**: Tập trung vào debugging và development
- **Cross-platform**: Hoạt động trên cả macOS và Linux