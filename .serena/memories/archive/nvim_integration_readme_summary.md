# NvChad Integration README Summary

This README explains how the Neovim configuration (`nvim/`) integrates the NvChad framework while maintaining custom settings under version control.

## Key Information
- **Structure:** The core idea is to keep the base NvChad installation separate from the user's custom configurations. The `nvim/.config/nvim/lua/custom/` directory is version-controlled within this dotfiles repository.
- **Symlinking:** The `install.sh` script symlinks the `custom/` directory from the dotfiles repo into the live `~/.config/nvim/lua/` directory. This is the key to the integration.
- **Customization:** It provides clear instructions on how to add new plugins, keymaps, and LSP settings by modifying files within the `custom/` directory.
- **Maintenance:** Includes dedicated scripts for updating NvChad (`update-nvchad.sh`) and checking the health of the integration (`nvchad-health.sh`), ensuring that updates don't break custom settings.
- **Java Focus:** The README heavily details the enhanced Java development and debugging workflow, including F-key hotkeys and automatic project detection (Maven/Gradle).
- **KISS Principle:** Reinforces the choice of NvimTree over Neo-tree for simplicity.
