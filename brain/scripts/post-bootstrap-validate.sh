#!/bin/bash
# post-bootstrap-validate.sh — Unified post-bootstrap validation
# Runs validate.sh + canary-check.sh in a single pass, auto-fixes common issues.
# Usage: bash brain/scripts/post-bootstrap-validate.sh [project-dir]
# Exit: 0 if healthy, 1 if critical failures remain after auto-fix

# ─── Source guard — prevent env corruption if sourced ─────────────
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  echo "❌ post-bootstrap-validate.sh must be EXECUTED, not sourced." >&2
  return 1 2>/dev/null || exit 1
fi

set -eo pipefail
PROJECT_DIR="${1:-.}"
cd "$PROJECT_DIR"

ERRORS=0

# ─── Portable helpers ──────────────────────────────────────────
source "$(dirname "$0")/_platform.sh"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Post-Bootstrap Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─── Step 0: Template integrity check ─────────────────────────────
# If this IS the template repo (not a real project), verify placeholders are intact.
IS_TEMPLATE=false
if [ -f "brain/bootstrap/PROMPT.md" ] && [ -d "brain/_examples" ] && [ -f "brain/scripts/validate.sh" ] && [ -f "brain/docs/DETAILED_GUIDE.md" ]; then
  _HAS_MANIFEST=false
  for _m in package.json Cargo.toml go.mod pyproject.toml pom.xml build.gradle pubspec.yaml mix.exs setup.py requirements.txt composer.json Gemfile CMakeLists.txt Makefile deno.json; do
    [ -f "$_m" ] && _HAS_MANIFEST=true && break
  done
  if ! $_HAS_MANIFEST; then IS_TEMPLATE=true; fi
fi

if $IS_TEMPLATE; then
  echo ""
  echo "🛡️  Template integrity check (template repo detected)..."
  TEMPLATE_OK=true
  if [ -f "AGENTS.md" ] && ! grep -q '{{PROJECT_NAME}}' AGENTS.md 2>/dev/null; then
    echo "  ❌ CRITICAL: AGENTS.md is missing {{PROJECT_NAME}} placeholder — template corrupted!"
    echo "     → Restore from git: git checkout -- AGENTS.md"
    TEMPLATE_OK=false
    ERRORS=$((ERRORS + 1))
  else
    echo "  ✅ AGENTS.md {{PROJECT_NAME}} placeholder intact"
  fi
  PLACEHOLDER_COUNT=$(grep -rEc '\{\{[A-Z_]+\}\}' AGENTS.md brain/ .codex/ 2>/dev/null | awk -F: '{s+=$2} END {print s+0}' || echo 0)
  if [ "$PLACEHOLDER_COUNT" -lt 20 ]; then
    echo "  ❌ CRITICAL: Only $PLACEHOLDER_COUNT placeholders found (expected 20+) — template may be corrupted"
    echo "     → Restore from git: git checkout -- ."
    TEMPLATE_OK=false
    ERRORS=$((ERRORS + 1))
  else
    echo "  ✅ $PLACEHOLDER_COUNT placeholders intact (healthy)"
  fi
  if $TEMPLATE_OK; then
    echo "  ✅ Template integrity: PASSED"
  fi
fi

# ─── Step 1: Auto-fix common issues before validation ─────────────
echo ""
echo "🔧 Auto-fixing common issues..."

# Fix hook permissions
HOOKS_FIXED=0
for hook in .codex/hooks/*.sh brain/scripts/*.sh; do
  if [ -f "$hook" ] && [ ! -x "$hook" ]; then
    chmod +x "$hook"
    HOOKS_FIXED=$((HOOKS_FIXED + 1))
  fi
done
[ "$HOOKS_FIXED" -gt 0 ] && echo "  ✅ Fixed $HOOKS_FIXED non-executable scripts"

# Ensure validate.sh is executable
[ -f "brain/scripts/validate.sh" ] && [ ! -x "brain/scripts/validate.sh" ] && chmod +x brain/scripts/validate.sh

# Validate hooks.json if it exists
if [ -f ".codex/hooks.json" ]; then
  if ! jq . .codex/hooks.json > /dev/null 2>&1; then
    echo "  ⚠️  .codex/hooks.json is invalid JSON — attempting auto-fix (trailing commas)"
    sed_inplace 's/,[[:space:]]*}/}/g; s/,[[:space:]]*]/]/g' .codex/hooks.json
    if jq . .codex/hooks.json > /dev/null 2>&1; then
      echo "  ✅ .codex/hooks.json auto-fixed"
    else
      echo "  ❌ .codex/hooks.json still invalid — manual fix needed"
      ERRORS=$((ERRORS + 1))
    fi
  fi
fi

# ─── Step 2: Run validate.sh ─────────────────────────────────────
echo ""
echo "📋 Running validate.sh..."
if [ -f "brain/scripts/validate.sh" ]; then
  VALIDATE_OUTPUT=$(bash brain/scripts/validate.sh 2>&1 || true)
  echo "$VALIDATE_OUTPUT"
  VALIDATE_FAIL=$(echo "$VALIDATE_OUTPUT" | grep -oE '❌ [0-9]+' | tail -1 | awk '{print $2}') || true
  echo ""
  echo "  validate.sh: ${VALIDATE_FAIL:-0} failed"
  [ "${VALIDATE_FAIL:-0}" -gt 0 ] && ERRORS=$((ERRORS + VALIDATE_FAIL))
else
  echo "  ⚠️  brain/scripts/validate.sh not found — skipping"
fi

# ─── Step 3: Run canary-check.sh ─────────────────────────────────
echo ""
echo "🐤 Running canary-check.sh..."
if [ -f "brain/scripts/canary-check.sh" ]; then
  CANARY_OUTPUT=$(bash brain/scripts/canary-check.sh . 2>&1 || true)
  echo "$CANARY_OUTPUT"
  CANARY_ERRORS=$(echo "$CANARY_OUTPUT" | grep -c '❌ FAIL') || CANARY_ERRORS=0
  echo ""
  echo "  canary-check.sh: $CANARY_ERRORS errors found"
  [ "$CANARY_ERRORS" -gt 0 ] && ERRORS=$((ERRORS + CANARY_ERRORS))
else
  echo "  ⚠️  brain/scripts/canary-check.sh not found — skipping"
fi

# ─── Step 4: Final placeholder check ─────────────────────────────
echo ""
echo "🔖 Final placeholder check..."
REMAINING=$(grep -rEn '\{\{[A-Z_]+\}\}' AGENTS.md brain/ .codex/ 2>/dev/null | grep -v '_examples/' | grep -v '_template' | grep -v 'bootstrap/PROMPT' | grep -v 'brain/docs/' | grep -v 'brain/scripts/' | grep -v 'brain/tasks/' | grep -v 'validate.sh' || true)
if [ -z "$REMAINING" ]; then
  echo "  ✅ No remaining placeholders"
else
  PCOUNT=$(echo "$REMAINING" | wc -l | tr -d ' ')
  echo "  ⚠️  $PCOUNT placeholder occurrences remain (AI creative work needed)"
  echo "$REMAINING" | head -15
fi

# ─── Step 5: Domain doc reference check ──────────────────────────
echo ""
echo "📚 Domain doc reference check..."
DOC_WARNINGS=0
if [ -f "AGENTS.md" ]; then
  REFERENCED_DOCS=$(grep -oE 'brain/[a-z_-]+\.md' AGENTS.md 2>/dev/null | sort -u || true)
  while IFS= read -r doc; do
    [ -z "$doc" ] && continue
    if [ ! -f "$doc" ]; then
      echo "  ⚠️  AGENTS.md references '$doc' — file not found (create it or remove the reference)"
      DOC_WARNINGS=$((DOC_WARNINGS + 1))
    fi
  done <<< "$REFERENCED_DOCS"
fi
[ "$DOC_WARNINGS" -eq 0 ] && echo "  ✅ All referenced brain/*.md files exist"

# ─── Summary ──────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$ERRORS" -gt 0 ]; then
  echo "  ❌ POST-BOOTSTRAP VALIDATION FAILED ($ERRORS errors)"
  echo "     Fix the above errors then re-run this script."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 1
else
  echo "  ✅ POST-BOOTSTRAP VALIDATION PASSED"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
fi
