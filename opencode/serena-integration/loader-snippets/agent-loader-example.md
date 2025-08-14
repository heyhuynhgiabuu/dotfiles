# Agent Loader Example

What it does:
- Minimal example showing how an agent loader can call Serena MCP checkpoints.

Usage (pseudocode):
```py
from serena import think_about_collected_information, think_about_task_adherence, think_about_whether_you_are_done

# After collecting required data (searches, reads)
think_about_collected_information()

# Before performing changes/action
think_about_task_adherence()

# Perform action (e.g., write files)

# At end, before marking task complete
think_about_whether_you_are_done()
```

Key info:
- Replace import lines with your environment's Serena client bindings.
- All checkpoint calls are no-ops if not available; still call them for clarity.