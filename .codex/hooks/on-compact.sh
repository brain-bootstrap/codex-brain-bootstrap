#!/usr/bin/env bash
# Hook: SessionStart (post-compact / OnCompact)
# Purpose: Re-inject context after compaction — branch, task, uncommitted, reminders.
# Exit: Always 0. Stdout is injected into Codex's context.

PROJECT_DIR="${CODEX_PROJECT_DIR:-.}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 Context compacted — re-injecting project state"
echo "📅 $(date '+%Y-%m-%d %H:%M')"

BRANCH=$(cd "$PROJECT_DIR" && git branch --show-current 2>/dev/null || echo "unknown")
echo "🌿 Branch: $BRANCH"

if [ -f "$PROJECT_DIR/brain/tasks/todo.md" ]; then
  TASK=$(head -5 "$PROJECT_DIR/brain/tasks/todo.md" 2>/dev/null | grep -E '^##' | head -1 || true)
  [ -n "$TASK" ] && echo "📋 Task: $TASK"
  NEXT=$(grep -m1 'NEXT →' "$PROJECT_DIR/brain/tasks/todo.md" 2>/dev/null || true)
  [ -n "$NEXT" ] && echo "➡️  $NEXT"
fi

UNCOMMITTED=$(cd "$PROJECT_DIR" && git status --short 2>/dev/null | wc -l | tr -d ' ')
if [ "$UNCOMMITTED" -gt 0 ]; then
  echo "⚠️  $UNCOMMITTED uncommitted file(s) — check git status"
fi

echo ""
echo "📖 Re-read AGENTS.md + brain/tasks/todo.md before continuing."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit 0
