#!/usr/bin/env bash
# .codex/hooks/session-start.sh — SessionStart hook
# Fires at session startup and resume. Injects brain context as developer context.
# Output (stdout plain text) is added as developer context by Codex.
# Docs: https://developers.openai.com/codex/hooks#sessionstart

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"
TODO_FILE="${REPO_ROOT}/brain/tasks/todo.md"
LESSONS_FILE="${REPO_ROOT}/brain/tasks/lessons.md"

echo "=== Brain Bootstrap — Session Context ==="
echo ""

# ── Current branch ────────────────────────────────────────────────
BRANCH="$(git branch --show-current 2>/dev/null || echo 'detached')"
echo "Branch: ${BRANCH}"

# ── Uncommitted files ─────────────────────────────────────────────
DIRTY="$(git status --short 2>/dev/null | wc -l | tr -d ' ' || echo '0')"
if [ "${DIRTY}" -gt 0 ]; then
  echo "Uncommitted changes: ${DIRTY} file(s)"
  git status --short 2>/dev/null | head -10 || true
fi

echo ""

# ── Current task state ────────────────────────────────────────────
if [ -f "${TODO_FILE}" ]; then
  echo "=== Current Tasks (brain/tasks/todo.md) ==="
  head -40 "${TODO_FILE}" 2>/dev/null || true
  echo ""
fi

# ── Key lessons ───────────────────────────────────────────────────
if [ -f "${LESSONS_FILE}" ]; then
  echo "=== Recent Lessons (brain/tasks/lessons.md) ==="
  tail -30 "${LESSONS_FILE}" 2>/dev/null || true
  echo ""
fi

# ── Mandatory reminders ───────────────────────────────────────────
echo "=== Mandatory Reminders ==="
echo "1. Read brain/tasks/todo.md + lessons.md + CODEX_ERRORS.md before acting."
echo "2. NEVER git push without user confirmation."
echo "3. Exit Checklist is MANDATORY before every response."
echo "4. Temp files: brain/tasks/ only — never /tmp/"
echo "5. Plan before non-trivial tasks — write to brain/tasks/todo.md."

exit 0
