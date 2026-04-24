#!/usr/bin/env bash
# integration-test.sh — End-to-end test of install.sh (FRESH + UPGRADE)
# Run: bash brain/scripts/integration-test.sh
# Exit: 0 if all pass, 1 on failure
# Designed for CI — creates temp dirs, cleans up after itself.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
PASS=0
FAIL=0
CLEANUP_DIRS=()

pass() { echo "  ✅ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }

cleanup() {
  # ${arr[@]+...} guards against bash 3.x "unbound variable" on empty arrays with set -u
  for d in ${CLEANUP_DIRS[@]+"${CLEANUP_DIRS[@]}"}; do
    rm -rf "$d" 2>/dev/null || true
  done
}
trap cleanup EXIT

make_test_repo() {
  local dir
  dir=$(mktemp -d)
  git init "$dir" >/dev/null 2>&1
  git -C "$dir" commit --allow-empty -m "init" >/dev/null 2>&1
  echo "$dir"
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Integration Test — install.sh"
echo "  Source: $SCRIPT_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Test 1: --check mode ──────────────────────────────────────────
echo ""
echo "Test 1: --check mode"
if bash "$SCRIPT_DIR/install.sh" --check >/dev/null 2>&1; then
  pass "--check exits 0"
else
  fail "--check exits non-zero"
fi

# ── Test 2: FRESH install ─────────────────────────────────────────
echo ""
echo "Test 2: FRESH install"
FRESH_DIR=$(make_test_repo)
CLEANUP_DIRS+=("$FRESH_DIR")

if bash "$SCRIPT_DIR/install.sh" "$FRESH_DIR" >/dev/null 2>&1; then
  pass "install.sh FRESH exits 0"
else
  fail "install.sh FRESH exits non-zero"
fi

# Verify key files exist
for f in AGENTS.md .codexignore .codex/config.toml .codex/hooks.json brain/scripts/discover.sh; do
  if [ -e "$FRESH_DIR/$f" ]; then
    pass "FRESH: $f exists"
  else
    fail "FRESH: $f missing"
  fi
done

# Verify scripts are executable
if [ -x "$FRESH_DIR/brain/scripts/discover.sh" ]; then
  pass "FRESH: scripts are executable"
else
  fail "FRESH: scripts not executable"
fi

# Verify hooks are executable
if [ -x "$FRESH_DIR/.codex/hooks/session-start.sh" ]; then
  pass "FRESH: hooks are executable"
else
  fail "FRESH: hooks not executable"
fi

# Verify _platform.sh is sourceable
if bash -c "source '$FRESH_DIR/brain/scripts/_platform.sh' && echo \$BRAIN_PLATFORM" >/dev/null 2>&1; then
  pass "FRESH: _platform.sh sourceable"
else
  fail "FRESH: _platform.sh not sourceable"
fi

# Verify skills installed
SKILL_COUNT=$(find "$FRESH_DIR/.agents/skills" -name 'SKILL.md' 2>/dev/null | wc -l | tr -d ' ')
if [ "$SKILL_COUNT" -ge 16 ]; then
  pass "FRESH: $SKILL_COUNT skills installed (≥16)"
else
  fail "FRESH: only $SKILL_COUNT skills (expected ≥16)"
fi

# Verify agents installed
AGENT_COUNT=$(find "$FRESH_DIR/.codex/agents" -name '*.toml' 2>/dev/null | wc -l | tr -d ' ')
if [ "$AGENT_COUNT" -ge 4 ]; then
  pass "FRESH: $AGENT_COUNT agents installed (≥4)"
else
  fail "FRESH: only $AGENT_COUNT agents (expected ≥4)"
fi

# Verify hooks registered in hooks.json
if command -v jq &>/dev/null; then
  HOOK_COUNT=$(jq '.hooks | length' "$FRESH_DIR/.codex/hooks.json" 2>/dev/null || echo 0)
  if [ "$HOOK_COUNT" -ge 5 ]; then
    pass "FRESH: $HOOK_COUNT hooks registered in hooks.json (≥5)"
  else
    fail "FRESH: only $HOOK_COUNT hooks in hooks.json (expected ≥5)"
  fi
else
  echo "  ⚠️  jq not available — skipping hooks.json validation"
fi

# ── Test 3: UPGRADE (re-run on same dir) ──────────────────────────
echo ""
echo "Test 3: UPGRADE (re-run on fresh install)"
if bash "$SCRIPT_DIR/install.sh" "$FRESH_DIR" >/dev/null 2>&1; then
  pass "install.sh UPGRADE exits 0"
else
  fail "install.sh UPGRADE exits non-zero"
fi

# Key files must still exist after upgrade
for f in AGENTS.md .codexignore brain/tasks/todo.md brain/tasks/lessons.md; do
  if [ -e "$FRESH_DIR/$f" ]; then
    pass "UPGRADE: $f preserved"
  else
    fail "UPGRADE: $f missing after upgrade"
  fi
done

# ── Test 4: validate.sh passes ────────────────────────────────────
echo ""
echo "Test 4: validate.sh in fresh install"
if (cd "$FRESH_DIR" && bash brain/scripts/validate.sh 2>&1 | grep -q '0 failed'); then
  pass "validate.sh: 0 failures"
else
  fail "validate.sh: failures detected"
fi

# ── Summary ───────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "  Results: ✅ %d passed   ❌ %d failed\n" "$PASS" "$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
