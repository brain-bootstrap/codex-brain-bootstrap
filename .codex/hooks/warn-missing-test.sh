#!/bin/bash
# Hook: Stop — Warn when session modified source files without corresponding tests
# Purpose: Educational reminder (exit 0, never blocks). Only active in strict profile.
# Requires: CODEX_HOOK_PROFILE=strict
#
# NOTE: Codex PostToolUse only emits Bash events — file write/edit events do NOT fire hooks.
# This hook runs at Stop to check git-modified files instead of per-write interception.

PROFILE="${CODEX_HOOK_PROFILE:-standard}"
[ "$PROFILE" != "strict" ] && exit 0

# Collect source files modified this turn (staged + unstaged, skip deletions)
CHANGED=$(git diff --name-only HEAD 2>/dev/null; git diff --name-only 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null)
if [ -z "$CHANGED" ]; then
  exit 0
fi

WARNED=false

while IFS= read -r FILE_PATH; do
  [ -z "$FILE_PATH" ] && continue

  # Skip non-code files
  case "$FILE_PATH" in
    *.py|*.ts|*.tsx|*.js|*.jsx|*.go|*.rs|*.java|*.rb|*.swift) ;;
    *) continue ;;
  esac

  # Skip test files themselves
  case "$FILE_PATH" in
    *test*|*spec*|*__tests__*) continue ;;
  esac

  # Only check files inside a recognizable source tree
  case "$FILE_PATH" in
    */src/*|*/app/*|*/lib/*|*/core/*|*/components/*|*/services/*|*/packages/*|*/handlers/*|*/controllers/*) ;;
    *) continue ;;
  esac

  BASENAME=$(basename "$FILE_PATH")
  NAME_NO_EXT="${BASENAME%.*}"
  EXT="${BASENAME##*.}"

  # Check for corresponding test file
  FOUND_TEST=false
  for test_dir in tests __tests__ test spec; do
    for test_pattern in "test_${NAME_NO_EXT}" "${NAME_NO_EXT}_test" "${NAME_NO_EXT}.test" "${NAME_NO_EXT}.spec"; do
      if find . \( -path "*/${test_dir}/${test_pattern}.*" -o -path "*/${test_pattern}.${EXT}" \) 2>/dev/null | grep -q .; then
        FOUND_TEST=true
        break 2
      fi
    done
  done

  if [ "$FOUND_TEST" = "false" ]; then
    echo "💡 Source file modified without a corresponding test: $FILE_PATH"
    WARNED=true
  fi
done <<< "$(echo "$CHANGED" | sort -u)"

if [ "$WARNED" = "true" ]; then
  echo "   Consider using \$tdd to add tests before your next turn."
fi

exit 0
