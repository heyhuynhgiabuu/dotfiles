# Serena Tools Reference Guide

This document provides a detailed explanation of all the tools available through the Serena MCP sub-agent.

## 1. Project & State Management

Tools for managing the project context and Serena's state.

-   `activate_project`: Points Serena to a specific project directory. This is the first command to start working on a project.
-   `get_current_config`: Displays the current configuration, including the active project, active modes, and available tools. Useful for status checks.
-   `remove_project`: Removes a project from Serena's known projects list.
-   `switch_modes`: Switches between operational modes (e.g., `planning`, `editing`).
-   `restart_language_server`: Restarts Serena's code analysis engine (Language Server). Use this if code intelligence seems stuck or outdated.

## 2. Code Exploration & Semantic Analysis (Core Strength)

These tools understand the structure and meaning of your code.

-   `get_symbols_overview`: Provides a high-level overview of all symbols (functions, classes, variables) in a file or directory.
-   `find_symbol`: **Core Tool.** Finds the exact definition of a specific symbol.
-   `find_referencing_symbols`: Finds all places where a symbol is used or called. Crucial for impact analysis before making changes.

## 3. Text-Based Search

For files where semantic analysis doesn't apply (e.g., config files, shell scripts).

-   `search_for_pattern`: Searches for a literal string or a regular expression (regex) pattern in files.
-   `list_dir`: Lists files and directories.
-   `find_file`: Finds a file by its name.

## 4. Code Modification (Editing)

These tools allow Serena to modify your code. **Requires `SERENA_READ_ONLY` to be `false`.**

-   `insert_after_symbol`: Inserts a block of code immediately after a known symbol.
-   `insert_before_symbol`: Inserts a block of code immediately before a known symbol.
-   `replace_symbol_body`: Replaces the entire body of a function or class.
-   `replace_regex`: Finds and replaces content based on a powerful regular expression.
-   Other tools include `create_text_file`, `delete_lines`, `replace_lines`.

## 5. Memory & Onboarding Management

Tools for helping Serena learn and remember things about your project.

-   `onboarding`: Starts the automated process for Serena to learn about a new project.
-   `write_memory`: Saves a critical piece of information to Serena's "memory" for future use.
-   `read_memory`: Reads a previously saved "memory".
-   `list_memories`: Lists all available "memories".
-   `delete_memory`: Deletes a "memory".

## 6. Internal "Thinking" Tools

These are typically used by Serena itself to manage its workflow.

-   `think_about_*`: A set of tools for self-reflection: "Do I have enough information?", "Am I on the right track?", "Am I done yet?".
-   `summarize_changes`: Summarizes the modifications made during a session.
