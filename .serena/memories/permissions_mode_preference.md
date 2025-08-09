[Dotfiles Repo Preference: Defer-Until-Approval Mode]

Date: 2025-08-10
Scope: /Users/killerkidbo/dotfiles repository (all sessions)

Preference:
- Do not read opencode/opencode.json until after the user explicitly approves the first privileged action (file edit or bash command).
- Planning phase: skip implicit permission checks entirely.
- Execution phase: when a privileged step is proposed, request explicit approval (y/yes). After approval, read opencode/opencode.json once and cache results.
- Continue to cache for the rest of the session; re-check only on permissions error or explicit user request.

Notes:
- This overrides the default token-efficient check timing for this repo only.
- Non-privileged read/search actions proceed without permission checks.