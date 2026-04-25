#!/usr/bin/env bash
# Hook: PreCompact
# Purpose: (1) Backup session transcript to brain/tasks/session-logs/
#          (2) Append compaction marker with branch name to brain/tasks/todo.md
#          (3) Emit project-aware preservation instructions to stdout —
#              stdout from PreCompact hook becomes additional compaction summarizer instructions
# Exit: Always 0.

PROJECT_DIR="${CODEX_PROJECT_DIR:-.}"
LOG_DIR="$PROJECT_DIR/brain/tasks/session-logs"
TIMESTAMP=$(date '+%Y%m%d-%H%M%S')

# ─── 1. Backup transcript from stdin ───────────────────────────────

mkdir -p "$LOG_DIR"
TRANSCRIPT=$(cat)
if [ -n "$TRANSCRIPT" ]; then
  echo "$TRANSCRIPT" > "$LOG_DIR/session-$TIMESTAMP.json"
  # Prune old sessions — keep newest 20
  TOTAL=$(find "$LOG_DIR" -maxdepth 1 -name 'session-*.json' 2>/dev/null | wc -l | tr -d ' ')
  KEEP=20
  if [ "$TOTAL" -gt "$KEEP" ]; then
    find "$LOG_DIR" -maxdepth 1 -name 'session-*.json' 2>/dev/null | sort | head -n "$((TOTAL - KEEP))" | xargs rm -f 2>/dev/null
  fi
fi

# ─── 2. Append compaction marker to todo.md ────────────────────────

if [ -f "$PROJECT_DIR/brain/tasks/todo.md" ]; then
  BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo 'unknown')
  {
    echo ""
    echo "---"
    echo "**[Compaction at $(date '+%Y-%m-%d %H:%M') on branch $BRANCH]** — Context was summarized. Run \`/resume\` to reload."
  } >> "$PROJECT_DIR/brain/tasks/todo.md"
fi

# ─── 3. Emit summarizer instructions to stdout ─────────────────────

PROJECT_TYPE="unknown"
if [ -f "$PROJECT_DIR/package.json" ]; then
  PROJECT_TYPE="typescript"
  grep -q '"next"' "$PROJECT_DIR/package.json" 2>/dev/null && PROJECT_TYPE="typescript/nextjs"
  grep -q '"react"' "$PROJECT_DIR/package.json" 2>/dev/null && PROJECT_TYPE="typescript/react"
fi
[ -f "$PROJECT_DIR/pyproject.toml" ] || [ -f "$PROJECT_DIR/setup.py" ] && PROJECT_TYPE="${PROJECT_TYPE:-python}"
[ -f "$PROJECT_DIR/go.mod" ] && PROJECT_TYPE="${PROJECT_TYPE:-go}"

SCHEMA_FILE=""
for f in prisma/schema.prisma drizzle/schema.ts src/db/schema.ts models.py; do
  if [ -e "$PROJECT_DIR/$f" ]; then SCHEMA_FILE="$f"; break; fi
done

GIT_BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo '')
GIT_CHANGED=$(git -C "$PROJECT_DIR" diff --name-only 2>/dev/null | head -15 || echo '')

echo "## Compaction Preservation Priorities — ${PROJECT_TYPE} project"
echo ""
echo "When summarizing, prioritize these in order:"
echo ""
echo "### 1. Decisions and reasoning (HIGHEST PRIORITY)"
echo "Keep the WHY verbatim — not just what was decided."
if [ -n "$SCHEMA_FILE" ]; then
  echo ""
  echo "### 2. Schema/DB context — file: $SCHEMA_FILE"
  echo "Preserve column names, relationships, migration decisions."
fi
echo ""
echo "### 3. Current work"
[ -n "$GIT_BRANCH" ] && echo "Branch: $GIT_BRANCH"
[ -n "$GIT_CHANGED" ] && echo "Uncommitted changes:" && echo "$GIT_CHANGED"
echo ""
echo "### What to compress / drop"
echo "- Dead-end exploration → drop"
echo "- Full file contents → drop (re-readable from disk)"
echo "- Repeated test-fix cycles → compress to: 'Fixed X by Y — tests pass'"

exit 0
