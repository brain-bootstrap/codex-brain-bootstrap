#!/usr/bin/env bash
# .codex/hooks/terminal-safety-gate.sh — PreToolUse hook (Bash matcher)
# Intercepts dangerous shell patterns before they execute.
# Receives JSON on stdin; outputs JSON block decision or exits 0 to allow.
# Docs: https://developers.openai.com/codex/hooks#pretooluse

set -euo pipefail

# ── Read stdin (JSON payload from Codex) ──────────────────────────
PAYLOAD="$(cat)"

COMMAND=""
if command -v jq &>/dev/null; then
  COMMAND="$(echo "${PAYLOAD}" | jq -r '.tool_input.command // ""' 2>/dev/null || true)"
fi

if [ -z "${COMMAND}" ]; then
  exit 0
fi

# ── Dangerous pattern checks ──────────────────────────────────────
# Each check: if matched, emit block JSON and exit 0

# 1. Pager-triggering git commands without --no-pager
if echo "${COMMAND}" | grep -qE '^git (log|show|diff|stash|branch)' 2>/dev/null; then
  if ! echo "${COMMAND}" | grep -q '\-\-no-pager' 2>/dev/null; then
    cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Terminal safety: git log/show/diff/stash/branch without --no-pager will trigger a pager and hang the session. Use: git --no-pager log ... | head -N"
  }
}
EOF
    exit 0
  fi
fi

# 2. Interactive editors
if echo "${COMMAND}" | grep -qE '(^|\s)(vi|vim|nano|emacs|less|more)(\s|$)' 2>/dev/null; then
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Terminal safety: Interactive programs (vi, vim, nano, less, more) will hang the session. Use file-editing tools instead of terminal editors."
  }
}
EOF
  exit 0
fi

# 3. git push without --dry-run or user-facing flag (belt + suspenders alongside rules)
if echo "${COMMAND}" | grep -qE '^git push' 2>/dev/null; then
  if ! echo "${COMMAND}" | grep -qE '(\-\-dry-run|\-n)' 2>/dev/null; then
    cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Safety: NEVER git push autonomously. Present a summary + proposed command to the user and wait for explicit confirmation."
  }
}
EOF
    exit 0
  fi
fi

# 4. rm -rf / (obvious but block it anyway)
if echo "${COMMAND}" | grep -qE 'rm\s+-[a-zA-Z]*r[a-zA-Z]*f?\s+/' 2>/dev/null; then
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Safety: Recursive delete of root-level paths is blocked by policy."
  }
}
EOF
  exit 0
fi

# 5. Unbounded command output (no head/tail/limit) — add context warning, don't block
# (Just emit a system message suggestion, don't fully block)

# Allow
exit 0
