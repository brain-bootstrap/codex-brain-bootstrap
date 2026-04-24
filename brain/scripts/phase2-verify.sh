#!/bin/bash
# phase2-verify.sh — Post-upgrade verification
# Single-line output: compact result, easy to check in CI.
# Usage: bash brain/scripts/phase2-verify.sh [project-dir]
# Exit:  0 = all critical checks pass, 1 = data loss detected

# ─── Source guard — prevent env corruption if sourced ─────────────
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  echo "❌ phase2-verify.sh must be EXECUTED, not sourced." >&2
  return 1 2>/dev/null || exit 1
fi

PROJECT_DIR="${1:-.}"
ERRORS=0
ISSUES=""

test -f "$PROJECT_DIR/brain/tasks/lessons.md" \
  || { ISSUES="${ISSUES}lessons.md MISSING · "; ERRORS=$((ERRORS + 1)); }

test -f "$PROJECT_DIR/brain/tasks/todo.md" \
  || { ISSUES="${ISSUES}todo.md MISSING · "; ERRORS=$((ERRORS + 1)); }

test -f "$PROJECT_DIR/brain/tasks/CODEX_ERRORS.md" \
  || { ISSUES="${ISSUES}CODEX_ERRORS.md MISSING · "; ERRORS=$((ERRORS + 1)); }

if command -v python3 &>/dev/null; then
  python3 -c "import json; json.load(open('$PROJECT_DIR/.codex/hooks.json'))" >/dev/null 2>&1 \
    || { ISSUES="${ISSUES}hooks.json BROKEN · "; ERRORS=$((ERRORS + 1)); }
fi

BACKUP=""
test -f "$PROJECT_DIR/brain/tasks/.pre-upgrade-backup.tar.gz" \
  && BACKUP=" · backup ✓" \
  || BACKUP=" · no backup (first install or cleaned)"

if [ "$ERRORS" -eq 0 ]; then
  echo "✅ Phase 2 OK: lessons.md ✓ · todo.md ✓ · CODEX_ERRORS.md ✓ · hooks.json ✓${BACKUP}"
else
  echo "❌ Phase 2 FAILED: ${ISSUES%· }"
  echo "   Restore from backup if available: tar xzf brain/tasks/.pre-upgrade-backup.tar.gz"
  exit 1
fi
