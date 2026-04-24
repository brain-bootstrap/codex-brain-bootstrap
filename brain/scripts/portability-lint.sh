#!/usr/bin/env bash
# portability-lint.sh — Detect non-portable patterns in shell scripts
# Run: bash brain/scripts/portability-lint.sh
# Exit: 0 if clean, 1 if violations found
# Design: EXTENSIBLE — add new patterns to check(), no script changes needed elsewhere.

set -euo pipefail

ERRORS=0
WARNINGS=0

# check SEVERITY "description" "grep-pattern"
check() {
  local severity="$1" description="$2" pattern="$3"
  local hits
  # Search .sh files only, exclude comments and this script itself
  hits=$(grep -rn "$pattern" --include='*.sh' . 2>/dev/null \
    | grep -v 'portability-lint\.sh' \
    | grep -v '^\([^:]*:\)\{0,1\}[[:space:]]*#' || true)
  if [ -n "$hits" ]; then
    if [ "$severity" = "ERROR" ]; then
      echo "  ❌ $description"
      ERRORS=$((ERRORS + 1))
    else
      echo "  ⚠️  $description"
      WARNINGS=$((WARNINGS + 1))
    fi
    echo "$hits" | head -5 | sed 's/^/     /'
  fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Portability Lint — Cross-Platform Safety"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── GNU coreutils / grep ───────────────────────────────────────────
check ERROR \
  "head -n -N (negative count) — GNU-only, BSD rejects" \
  'head -n -[0-9]'

check ERROR \
  "grep -P (PCRE flag) — not available on macOS default grep" \
  'grep -[a-zA-Z]*P '

check ERROR \
  "readlink -f — GNU-only (macOS requires greadlink)" \
  'readlink -f'

check ERROR \
  "stat --format or stat -c — GNU stat (macOS uses stat -f)" \
  'stat --format\|stat -c '

check ERROR \
  "date --date= or date -d — GNU date parsing" \
  'date --date\|date -d '

# ── Bash-specific constructs ──────────────────────────────────────
check ERROR \
  "declare -A (associative arrays) — bash 4+ only (macOS ships bash 3.2)" \
  'declare -A '

check ERROR \
  "mapfile / readarray — bash 4+ only" \
  'mapfile \|readarray '

check ERROR \
  "sort --random-sort — GNU sort only" \
  'sort --random-sort'

check ERROR \
  "cp --reflink — GNU cp only" \
  'cp --reflink'

check ERROR \
  "ls --color — GNU ls only (macOS uses CLICOLOR)" \
  'ls --color'

# ── Unsafe patterns ────────────────────────────────────────────────
check WARNING \
  "echo -e — not POSIX (use printf instead)" \
  'echo -e '

check WARNING \
  "which command — prefer command -v for portability" \
  '\bwhich\b'

check ERROR \
  "grep -E with double-quoted alternation — zsh misinterprets |" \
  'grep -[a-zA-Z]*E "[^"]*|[^"]*"'

# ── Summary ────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "  Results: ❌ %d errors   ⚠️  %d warnings\n" "$ERRORS" "$WARNINGS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$ERRORS" -gt 0 ]; then
  exit 1
fi
