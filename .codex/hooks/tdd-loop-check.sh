#!/usr/bin/env bash
# .codex/hooks/tdd-loop-check.sh — Stop hook
# Checks for failing tests in the last run. If tests are failing, blocks
# the turn and asks Codex to fix them before stopping.
# Docs: https://developers.openai.com/codex/hooks#stop

set -euo pipefail

PAYLOAD="$(cat)"

# Extract the last assistant message to check if tests ran
LAST_MSG=""
if command -v jq &>/dev/null; then
  LAST_MSG="$(echo "${PAYLOAD}" | jq -r '.last_assistant_message // ""' 2>/dev/null | head -c 4000 || true)"
fi

# ── Already continued by Stop hook — don't loop infinitely ────────
STOP_HOOK_ACTIVE=false
if command -v jq &>/dev/null; then
  STOP_HOOK_ACTIVE="$(echo "${PAYLOAD}" | jq -r '.stop_hook_active // false' 2>/dev/null || echo false)"
fi

if [ "${STOP_HOOK_ACTIVE}" = "true" ]; then
  # Already continued once — exit cleanly to avoid infinite loop
  echo '{}' 
  exit 0
fi

# ── Look for test failure signals in the last message ─────────────
if echo "${LAST_MSG}" | grep -qiE '(test.*fail|fail.*test|FAILED|✗|✖|× |assertion.*error|jest.*fail|pytest.*fail|go test.*FAIL)' 2>/dev/null; then
  cat <<'EOF'
{
  "decision": "block",
  "reason": "TDD loop: Tests are failing. Fix the failing tests before stopping. Identify the exact assertion failures, trace the root cause, apply the minimal fix, and re-run until all tests pass."
}
EOF
  exit 0
fi

# Allow stop
echo '{}'
exit 0
