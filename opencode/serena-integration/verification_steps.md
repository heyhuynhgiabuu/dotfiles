# Verification Steps (manual)

Follow these steps after adding the Serena MCP integration files.

1. File presence
   - Verify files exist under opencode/serena-integration/ and .serena/ directory.

2. Config values
   - Confirm token_budgets.scs_aws = 2000
   - Confirm token_budgets.auto_compress_threshold = 1500

3. Permissions
   - Confirm permissions mapping:
     - analyst: allow
     - general: ask
     - devops: ask
     - security: allow
     - alpha: allow

4. Commit policy check
   - Use templates/commit-message-template.txt for commit messages.
   - Ensure no commit contains AI attribution phrases.

5. Loader runtime (optional)
   - Run loader-snippets/loader-runtime-stub.py (python3) and confirm it prints audit JSON lines:
     python3 opencode/serena-integration/loader-snippets/loader-runtime-stub.py

6. Audit schema
   - Validate loader-snippets/audit-schema.json against a JSON schema validator if available.

7. Cross-platform sanity
   - Paths in YAML and README use POSIX-style. Ensure scripts run on macOS and Linux.

8. MCP checks
   - Confirm all three Serena MCP calls are present in loader stub:
     - think_about_collected_information
     - think_about_task_adherence
     - think_about_whether_you_are_done

Manual verification complete: if all steps pass, integration is ready.