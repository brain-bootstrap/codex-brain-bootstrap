#!/usr/bin/env bash
# _platform.sh — Portable shell helpers for Codex Brain Bootstrap
# Sourced by scripts that need platform-specific behavior. Never executed directly.
# Usage: source "$(dirname "$0")/_platform.sh"

# ─── Platform detection ───────────────────────────────────────────
case "$(uname -s)" in
  Darwin*)              BRAIN_PLATFORM="macos" ;;
  MINGW*|MSYS*|CYGWIN*) BRAIN_PLATFORM="windows" ;;
  *)                    BRAIN_PLATFORM="linux" ;;
esac

# ─── Portable sed -i ──────────────────────────────────────────────
if [ "$BRAIN_PLATFORM" = "macos" ]; then
  sed_inplace() { sed -i '' "$@"; }
else
  sed_inplace() { sed -i "$@"; }
fi

# ─── Portable sed insert-before-line ──────────────────────────────
# BSD sed requires a literal newline after `i\`, GNU sed accepts inline text.
# Usage: insert_before_line "pattern" "text to insert" "file"
if [ "$BRAIN_PLATFORM" = "macos" ]; then
  insert_before_line() {
    local pattern="$1" newtext="$2" file="$3"
    sed -i '' "/${pattern}/i\\
${newtext}" "$file"
  }
else
  insert_before_line() {
    local pattern="$1" newtext="$2" file="$3"
    sed -i "/${pattern}/i\\${newtext}" "$file"
  }
fi

# ─── Require a tool or print actionable install instructions ──────
require_tool() {
  local tool="$1" purpose="${2:-required}"
  if command -v "$tool" &>/dev/null; then return 0; fi
  echo "❌ '$tool' is required ($purpose) but not found." >&2
  case "$BRAIN_PLATFORM" in
    macos)   echo "   Install: brew install $tool" >&2 ;;
    windows) echo "   Install: scoop install $tool  OR  choco install $tool" >&2 ;;
    linux)   echo "   Install: sudo apt install $tool  OR  sudo dnf install $tool" >&2 ;;
  esac
  return 1
}

# ─── Unicode/emoji support detection ──────────────────────────────
supports_unicode() {
  case "${LANG:-}${LC_ALL:-}" in
    *UTF-8*|*utf-8*) return 0 ;;
    *) return 1 ;;
  esac
}
