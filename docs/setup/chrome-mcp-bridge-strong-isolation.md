# Chrome MCP Bridge: Strong Isolation Setup

Purpose
- Run browser automation in a separate Chrome/Chromium profile (user-data-dir) to avoid exposing your personal sessions and reduce risk.

What you get
- Unsynced, dedicated profile for automation
- mcp-chrome-bridge extension only in that profile
- Least-privilege site access, local-only native host

1) Launch an isolated Chrome profile
- macOS:
  - open -na "Google Chrome" --args --user-data-dir="$HOME/chrome-profiles/automation" --no-first-run --no-default-browser-check
- Linux (Google Chrome):
  - google-chrome --user-data-dir="$HOME/chrome-profiles/automation" --no-first-run --no-default-browser-check &
- Linux (Chromium):
  - chromium --user-data-dir="$HOME/chrome-profiles/automation" --no-first-run --no-default-browser-check &

Optional: pre-create the directory with restricted perms
- mkdir -p "$HOME/chrome-profiles/automation" && chmod 700 "$HOME/chrome-profiles/automation"

2) Install the MCP Chrome Bridge ONLY in this window
- Download latest release (unzip)
- chrome://extensions → enable Developer mode → Load unpacked → select the unzipped folder
- Do not install the extension in your daily profile

3) Install the native host (global)
- npm install -g mcp-chrome-bridge
  - Requires Node.js 18+

4) Restrict extension permissions (least privilege)
- chrome://extensions → mcp-chrome-bridge → Details
  - Site access: On click (or On specific sites)
  - Allow in incognito: OFF
  - Allow access to file URLs: OFF (unless needed)

5) Lock down the native-messaging host manifest
- Manifest locations:
  - macOS: ~/Library/Application Support/Google/Chrome/NativeMessagingHosts/
  - Linux (Chrome): ~/.config/google-chrome/NativeMessagingHosts/
  - Linux (Chromium): ~/.config/chromium/NativeMessagingHosts/
- Verify:
  - allowed_origins contains ONLY your extension ID (chrome://extensions → Details → ID)
  - Directory perms are user-only; file is not world-writable
    - chmod 700 <dir>; chmod 600 <manifest.json>

6) Verification (2–3 minutes)
- Isolation
  - Open the isolated profile; ensure no Google account is signed in
  - Confirm the bridge extension exists only here
- Permissions
  - Site access is On click or specific sites
  - Incognito/file URLs are OFF unless required
- Native host
  - Manifest present at the correct path with your extension ID only
  - Paths are not world-writable
- Functional test
  - Open https://example.com in the isolated window
  - From your MCP client, trigger navigate/screenshot → verify results
  - Confirm your daily Chrome window remains unchanged

Notes & tips
- You can change the directory by setting CHROME_AUTOMATION_DIR before launching
- For maximum isolation, run under a separate OS user or use a different Chrome flavor for automation (Chromium vs Google Chrome)

Troubleshooting
- Native host not found: Reinstall mcp-chrome-bridge globally and confirm the manifest path matches your Chrome flavor
- Wrong profile opening: Ensure you launch with --user-data-dir and that the directory exists
- Extension cannot access site: Use On specific sites and add the domains you need
