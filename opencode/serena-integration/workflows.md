# Workflows (Phase 4 -> Phase 5 integration)

What it does:
- Presents concrete sequence to integrate Serena MCP into an agent runtime for OpenCode.

Usage (quick):
1. Place serena-agent-config.yaml in repo.
2. Add loader/runtime stub and register it with your agent.
3. Wire middleware layers (see middleware.md).
4. Use templates for user prompts and commit messages.
5. Run verification steps in verification_steps.md.

Steps (concise):
- Phase A: Prep
  - Add config and loader snippets
  - Ensure no secrets in repo
- Phase B: Integration
  - Integrate loader-runtime-stub.py into agent startup
  - Ensure checkpoint calls placed accordingly
- Phase C: Verify
  - Run manual verification checklist (verification_steps.md)
  - Confirm commit-message enforcement

That's it:
- Keep changes small and reversible. Follow the three MCP checkpoints in all workflows.