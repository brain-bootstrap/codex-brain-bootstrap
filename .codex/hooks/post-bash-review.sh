#!/usr/bin/env bash
# .codex/hooks/post-bash-review.sh — PostToolUse hook (Bash matcher)
# Reviews Bash output for signs of issues (test failures, errors, unsafe patterns).
# Returns additionalContext to help Codex self-correct.
# Docs: https://developers.openai.com/codex/hooks#posttooluse

set -euo pipefail

PAYLOAD="$(cat)"

# Extract tool response / output
TOOL_RESPONSE=""
if command -v jq &>/dev/null; then
  TOOL_RESPONSE="$(echo "${PAYLOAD}" | jq -r '.tool_response // ""' 2>/dev/null | head -c 4000 || true)"
fi

if [ -z "${TOOL_RESPONSE}" ]; then
  exit 0
fi

# ── Check for test failures ────────────────────────────────────────
if echo "${TOOL_RESPONSE}" | grep -qiE '(FAIL|FAILED|ERROR|✗|✖|× )' 2>/dev/null; then
  cat <<'EOF'
{
  "decision": "block",
  "reason": "⚠️  Tests or commands failed. Do not mark complete. Fix the root cause and re-run until green.",
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "The command output contains test failures or errors. Do not mark the task as complete. Analyze the failure output, fix the root cause, and re-run until green. Do NOT skip or suppress failing tests."
  }
}
EOF
  exit 0
fi

# ── Check for merge conflicts left in files ────────────────────────
if echo "${TOOL_RESPONSE}" | grep -qE '(<<<<<<<|=======|>>>>>>>)' 2>/dev/null; then
  cat <<'EOF'
{
  "decision": "block",
  "reason": "⚠️  Merge conflict markers detected. Resolve ALL conflicts before proceeding.",
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Merge conflict markers detected. Resolve ALL conflicts before proceeding. Run: grep -rn '<<<<<<<' . to find remaining conflicts."
  }
}
EOF
  exit 0
fi

exit 0
