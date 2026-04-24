#!/usr/bin/env bash
# .codex/hooks/exit-nudge.sh — Stop hook
# Emits the mandatory Exit Checklist as developer context before every turn stop.
# Docs: https://developers.openai.com/codex/hooks#stop

set -euo pipefail

PAYLOAD="$(cat)"

# Don't emit if Stop hook already active (avoid double nudge)
STOP_HOOK_ACTIVE=false
if command -v jq &>/dev/null; then
  STOP_HOOK_ACTIVE="$(echo "${PAYLOAD}" | jq -r '.stop_hook_active // false' 2>/dev/null || echo false)"
fi

if [ "${STOP_HOOK_ACTIVE}" = "true" ]; then
  echo '{}'
  exit 0
fi

# ── Emit exit checklist as system message ─────────────────────────
cat <<'EOF'
{
  "systemMessage": "🚨 EXIT CHECKLIST — Check ALL before yielding:\n1. User corrected you? → Update brain/tasks/lessons.md NOW\n2. Learned something new? → Update brain/tasks/lessons.md NOW\n3. Open task in brain/tasks/todo.md? → Mark progress\n4. Touched a domain? → Verify brain/*.md still accurate\n5. New pattern discovered? → Add to lessons.md\n6. Terminal commands used? → Verify no pagers, interactive mode, or unbounded output"
}
EOF
exit 0
