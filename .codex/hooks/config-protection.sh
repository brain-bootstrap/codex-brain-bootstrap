#!/usr/bin/env bash
# .codex/hooks/config-protection.sh — PreToolUse hook (Bash matcher)
# Blocks edits to protected configuration files.
# Receives JSON on stdin; outputs JSON block decision or exits 0 to allow.
# Docs: https://developers.openai.com/codex/hooks#pretooluse

set -euo pipefail

# ── Read stdin (JSON payload from Codex) ──────────────────────────
PAYLOAD="$(cat)"

# Extract the command Codex is about to run
COMMAND=""
if command -v jq &>/dev/null; then
  COMMAND="$(echo "${PAYLOAD}" | jq -r '.tool_input.command // ""' 2>/dev/null || true)"
fi

# If we can't parse, allow (fail open — don't break the workflow)
if [ -z "${COMMAND}" ]; then
  exit 0
fi

# ── Protected files — NEVER edit these via shell commands ─────────
# Expand as needed. Use glob-style matching.
PROTECTED_PATTERNS=(
  ".idea/"
  ".vscode/settings.json"
  ".vscode/extensions.json"
  ".git/config"
  ".git/hooks"
  "tsconfig.json"
  "pyproject.toml"
  "package.json"
  "Pipfile"
  "go.mod"
  ".eslintrc"
  ".prettierrc"
  "biome.json"
  ".editorconfig"
  "Makefile"
  "Dockerfile"
  "docker-compose"
)

for PATTERN in "${PROTECTED_PATTERNS[@]}"; do
  if echo "${COMMAND}" | grep -qF "${PATTERN}" 2>/dev/null; then
    # Block the command — use preferred permissionDecision format
    cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Config protection: This command attempts to modify a protected configuration file. Fix the source code instead of silencing the toolchain. If you genuinely need to update this config, ask the user explicitly."
  }
}
EOF
    exit 0
  fi
done

# Allow
exit 0
