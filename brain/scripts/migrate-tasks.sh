#!/usr/bin/env bash
# migrate-tasks.sh — Deterministic tasks/ directory migration
# Moves ONLY known Codex files from old layout (tasks/ or .tasks/) to brain/tasks/.
# NEVER moves non-Codex files. NEVER deletes source directories.
#
# Usage: bash brain/scripts/migrate-tasks.sh [--discovery-env <path>] [--target <dir>] [--dry-run]
# Exit:  0 = migrated, 1 = error, 2 = nothing to do

# ─── Source guard ─────────────────────────────────────────────────
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  echo "❌ migrate-tasks.sh must be EXECUTED, not sourced." >&2
  return 1 2>/dev/null || exit 1
fi

set -eo pipefail

# ─── Parse arguments ──────────────────────────────────────────────
DISCOVERY_ENV=""
TARGET="."
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --discovery-env) DISCOVERY_ENV="$2"; shift 2 ;;
    --target) TARGET="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    *) shift ;;
  esac
done

cd "$TARGET"

# ─── Platform helpers ─────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_platform.sh"

# ─── Detect migration need ────────────────────────────────────────
LAYOUT_MIGRATION="false"

if [ -n "$DISCOVERY_ENV" ] && [ -f "$DISCOVERY_ENV" ]; then
  LAYOUT_MIGRATION=$(grep '^LAYOUT_MIGRATION_NEEDED=' "$DISCOVERY_ENV" 2>/dev/null | head -1 | cut -d= -f2 || echo "false")
fi

# Fallback: detect directly if no discovery env
if [ "$LAYOUT_MIGRATION" = "false" ]; then
  if [ -d "tasks" ] && [ ! -d "brain/tasks" ]; then
    if [ -f "tasks/lessons.md" ] || [ -f "tasks/todo.md" ]; then
      LAYOUT_MIGRATION="true"
    fi
  elif [ -d "tasks" ] && [ -d "brain/tasks" ]; then
    if [ -f "tasks/lessons.md" ] && [ ! -f "brain/tasks/lessons.md" ]; then
      LAYOUT_MIGRATION="merge"
    elif [ -f "tasks/todo.md" ] && [ ! -f "brain/tasks/todo.md" ]; then
      LAYOUT_MIGRATION="merge"
    fi
  elif [ -d ".tasks" ]; then
    if [ -f ".tasks/lessons.md" ] || [ -f ".tasks/todo.md" ]; then
      LAYOUT_MIGRATION="true"
    fi
  fi
fi

if [ "$LAYOUT_MIGRATION" = "false" ]; then
  echo "✅ No tasks migration needed"
  exit 2
fi

echo "🔄 Tasks migration: mode=$LAYOUT_MIGRATION"
$DRY_RUN && echo "  ⚠️  DRY RUN — no files will be modified"

# ─── Allowlisted Codex files (ONLY these get moved) ───────────────
CODEX_FILES=(
  "lessons.md"
  "todo.md"
  "CODEX_ERRORS.md"
  "CLAUDE_ERRORS.md"
  "bootstrap-report.md"
  ".bootstrap-plan.txt"
  ".bootstrap-progress.txt"
  ".discovery.env"
)

CODEX_DIRS=(
  "session-logs"
)

CODEX_GLOBS=(
  ".codex-*"
  ".bootstrap-*"
)

# ─── Detect source directory ──────────────────────────────────────
SRC_DIR=""
if [ -d "tasks" ] && { [ -f "tasks/lessons.md" ] || [ -f "tasks/todo.md" ]; }; then
  SRC_DIR="tasks"
elif [ -d ".tasks" ] && { [ -f ".tasks/lessons.md" ] || [ -f ".tasks/todo.md" ]; }; then
  SRC_DIR=".tasks"
fi

if [ -z "$SRC_DIR" ]; then
  echo "✅ No Codex files found in tasks/ or .tasks/"
  exit 2
fi

DEST_DIR="brain/tasks"
MOVED=0
SKIPPED=0

# ─── Ensure destination ───────────────────────────────────────────
if ! $DRY_RUN; then
  mkdir -p "$DEST_DIR"
fi

# ─── Move allowlisted files ──────────────────────────────────────
for FILE in "${CODEX_FILES[@]}"; do
  if [ -f "$SRC_DIR/$FILE" ]; then
    if [ -f "$DEST_DIR/$FILE" ]; then
      if [ "$LAYOUT_MIGRATION" = "merge" ] && [ "$FILE" = "lessons.md" ]; then
        echo "  📝 $FILE: would APPEND to existing $DEST_DIR/$FILE"
        if ! $DRY_RUN; then
          echo "" >> "$DEST_DIR/$FILE"
          echo "<!-- Migrated from $SRC_DIR/ on $(date +%Y-%m-%d) -->" >> "$DEST_DIR/$FILE"
          cat "$SRC_DIR/$FILE" >> "$DEST_DIR/$FILE"
          rm "$SRC_DIR/$FILE"
        fi
        MOVED=$((MOVED + 1))
      else
        echo "  ⏭️  $FILE: already exists in $DEST_DIR/ — skipping"
        SKIPPED=$((SKIPPED + 1))
      fi
    else
      echo "  📦 $FILE: $SRC_DIR/ → $DEST_DIR/"
      if ! $DRY_RUN; then
        mv "$SRC_DIR/$FILE" "$DEST_DIR/$FILE"
      fi
      MOVED=$((MOVED + 1))
    fi
  fi
done

# ─── Move allowlisted directories ─────────────────────────────────
for DIR in "${CODEX_DIRS[@]}"; do
  if [ -d "$SRC_DIR/$DIR" ]; then
    if [ -d "$DEST_DIR/$DIR" ]; then
      echo "  ⏭️  $DIR/: already exists in $DEST_DIR/ — skipping"
      SKIPPED=$((SKIPPED + 1))
    else
      echo "  📦 $DIR/: $SRC_DIR/ → $DEST_DIR/"
      if ! $DRY_RUN; then
        mv "$SRC_DIR/$DIR" "$DEST_DIR/$DIR"
      fi
      MOVED=$((MOVED + 1))
    fi
  fi
done

# ─── Move allowlisted glob patterns ───────────────────────────────
for GLOB in "${CODEX_GLOBS[@]}"; do
  while IFS= read -r FILE; do
    [ -z "$FILE" ] && continue
    BASENAME=$(basename "$FILE")
    if [ -e "$DEST_DIR/$BASENAME" ]; then
      SKIPPED=$((SKIPPED + 1))
    else
      echo "  📦 $BASENAME: $SRC_DIR/ → $DEST_DIR/"
      if ! $DRY_RUN; then
        mv "$FILE" "$DEST_DIR/$BASENAME"
      fi
      MOVED=$((MOVED + 1))
    fi
  done < <(find "$SRC_DIR" -maxdepth 1 -name "$GLOB" -type f 2>/dev/null)
done

# ─── Update references (ONLY if actually moved files) ─────────────
if [ "$MOVED" -gt 0 ] && ! $DRY_RUN; then
  # Update hook scripts: tasks/ → brain/tasks/ (exact boundary)
  for HOOK in .codex/hooks/*.sh; do
    [ -f "$HOOK" ] || continue
    if grep -q '"tasks/' "$HOOK" 2>/dev/null || grep -q '/tasks/' "$HOOK" 2>/dev/null; then
      sed_inplace 's|"tasks/|"brain/tasks/|g' "$HOOK"
      sed_inplace 's|\./tasks/|./brain/tasks/|g' "$HOOK"
      # Prevent double-replacement
      sed_inplace 's|brain/brain/tasks/|brain/tasks/|g' "$HOOK"
    fi
  done

  # Update AGENTS.md references
  if [ -f "AGENTS.md" ]; then
    sed_inplace 's|\btasks/lessons\.md\b|brain/tasks/lessons.md|g' AGENTS.md
    sed_inplace 's|\btasks/todo\.md\b|brain/tasks/todo.md|g' AGENTS.md
    sed_inplace 's|brain/brain/tasks/|brain/tasks/|g' AGENTS.md
    echo "  ⚙️  AGENTS.md references updated → brain/tasks/"
  fi
fi

echo ""
if $DRY_RUN; then
  echo "📊 Would move $MOVED file(s), skip $SKIPPED"
else
  echo "✅ Migration complete: $MOVED moved, $SKIPPED skipped"
fi
