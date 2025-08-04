# Effective Guide to Integrating and Using Serena with OpenCode

## Core Philosophy: You are the Architect, Serena is the Skilled Builder

Your role is to **direct, make decisions, and verify**. You provide high-level requirements, and Serena, with its ability to understand code semantically, executes the tasks. The workflow is a continuous dialogue.

---

## The 4-Phase Workflow for Effective Serena Usage

This is a standard process for any task, from adding a small alias to refactoring a complex module.

### Phase 1: Onboarding & Context Loading

The goal of this phase is to ensure Serena has sufficient background information about your project.

1.  **Activate Project:** Always start with `@serena activate_project /path/to/your/project`.
2.  **Perform Onboarding:** Run `@serena onboarding` to have Serena automatically scan the project and understand its basic structure.
3.  **Create "Memories":** Use `@serena write_memory 'memory_name' content:'...'` to create important notes that Serena can refer to in future sessions.

### Phase 2: Exploration & Planning

This is where Serena shines. **Don't rush to edit code.**

1.  **High-Level Overview:** Use `@serena get_symbols_overview path/to/directory`.
2.  **Specific Search:** Use `@serena find_symbol "function_name_to_find"` for precise definitions.
3.  **Impact Analysis:** Use `@serena find_referencing_symbols "function_name" ...` to see where a function is used.
4.  **Pattern Search:** Use `@serena search_for_pattern "..."` for config files, shell scripts, etc.

### Phase 3: Execution & Modification

Prioritize symbol-based editing tools for higher accuracy.

1.  **Add New Code:** Use `@serena insert_after_symbol ...`.
2.  **Replace Old Code:** Use `@serena replace_symbol_body ...`.
3.  **Regex Replace:** Use `@serena replace_regex ...` for complex changes.

### Phase 4: Verification & Finalization

The final verification role is yours.

1.  **Review the File:** Use `@read path/to/changed/file.ext`.
2.  **Manual Testing:** Run the new functionality yourself.
3.  **Summarize Changes:** Use `@serena summarize_changes` to get content for your commit message.
