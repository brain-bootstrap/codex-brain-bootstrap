#!/usr/bin/env bash
# Hook: PostToolUse(Edit|Write|MultiEdit) — edit accumulator
# Purpose: Record edited file paths to a session-scoped temp file for batch formatting at Stop.
# Exit: Always 0.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

ACCUMULATOR="${CODEX_PROJECT_DIR:-.}/brain/tasks/.codex-edited-files-${CODEX_SESSION_ID:-default}"

# Only accumulate formattable source files.
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.json|\
  *.py|*.go|*.rs|*.java|*.kt|*.scala|\
  *.rb|*.swift|*.cs|*.cpp|*.c|*.h|\
  *.php|*.ex|*.exs|*.hs|*.dart)
    echo "$FILE_PATH" >> "$ACCUMULATOR"
    ;;
esac

# TDD activation flag — written only for SOURCE CODE files.
case "$FILE_PATH" in
  *.js|*.ts|*.tsx|*.jsx|*.mjs|*.cjs|\
  *.py|*.go|*.rs|*.java|*.kt|*.scala|\
  *.rb|*.swift|*.cs|*.cpp|*.c|*.h|\
  *.php|*.ex|*.exs|*.hs|*.dart)
    TDD_FLAG="${CODEX_PROJECT_DIR:-.}/brain/tasks/.tdd-source-edited-${CODEX_SESSION_ID:-default}"
    touch "$TDD_FLAG" 2>/dev/null || true
    ;;
esac

exit 0
