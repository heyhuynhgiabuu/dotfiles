# OpenCode Agent Refactor: Migration Plan

## 1. Mapping Table: Old Agents → New Minimal Agents

| Old Agent(s)                                                                 | New Minimal Agent         | Notes/Parameter           |
|------------------------------------------------------------------------------|---------------------------|---------------------------|
| java-pro, typescript-pro, golang-pro, php-pro, javascript-pro, sql-pro        | language-pro              | language param            |
| sql-pro, database-optimizer, database-admin                                  | database-expert           | sub-role param            |
| code-reviewer, architect-reviewer, backend-architect, api-reviewer           | reviewer                  | focus param               |
| search-specialist, simple-researcher                                         | researcher                | fallback logic            |
| frontend-developer, ui-ux-designer                                           | frontend-uiux             |                           |
| performance-engineer, debugger, incident-responder, backend-troubleshooter   | troubleshooter            | focus param               |
| codebase-locator, codebase-analyzer, codebase-pattern-finder, thoughts-locator| codebase-navigator        | sub-command param         |
| devops-deployer                                                              | devops-deployer           | unique, keep              |
| context-manager                                                              | context-manager           | unique, keep              |
| analyst                                                                      | analyst                   | unique, keep              |
| session-summarizer                                                           | session-summarizer        | unique, keep              |
| docs-writer                                                                  | docs-writer               | unique, keep              |
| optimizer                                                                    | optimizer                 | unique, keep              |
| legacy-modernizer                                                            | legacy-modernizer         | unique, keep              |
| security-audit                                                               | security-audit            | unique, keep              |
| network-engineer                                                             | network-engineer          | unique, keep              |
| alpha                                                                         | alpha                    | orchestrator, keep        |
| prompt-engineer                                                              | prompt-engineer           | unique, keep              |

## 2. New Minimal Agent File List

- language-pro.md
- database-expert.md
- reviewer.md
- researcher.md
- frontend-uiux.md
- troubleshooter.md
- codebase-navigator.md
- devops-deployer.md
- context-manager.md
- analyst.md
- session-summarizer.md
- docs-writer.md
- optimizer.md
- legacy-modernizer.md
- security-audit.md
- network-engineer.md
- alpha.md
- prompt-engineer.md

## 3. Migration Steps

1. For each new minimal agent, create a new .md file in opencode/agent/.
2. Merge content from all mapped old agents into the new file, preserving key descriptions, examples, and tool configs.
3. Add a `role`, `focus`, or `language` parameter where needed.
4. Remove all old, now-redundant agent files.
5. Update documentation and references to use the new agent names.
6. Provide a verification checklist and mapping table for user review.

---

*This file is auto-generated as the first step of the migration. Next: begin merging agent files as per this plan.*
