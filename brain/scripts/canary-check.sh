#!/bin/bash
# canary-check.sh — Structural validation of LIVE Codex Brain configuration
# Unlike validate.sh (template completeness), this checks the ACTIVE config health.
# Run periodically, via CI, or after bootstrap to verify configuration integrity.
# Exit code: 0 = all pass, 1 = failures found

# ─── Source guard — prevent env corruption if sourced ─────────────
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  echo "❌ canary-check.sh must be EXECUTED, not sourced." >&2
  return 1 2>/dev/null || exit 1
fi

set -eo pipefail

PROJECT_DIR="${1:-.}"
ERRORS=0
WARNINGS=0
PASSES=0

info()  { echo "  ✅ PASS — $1"; PASSES=$((PASSES + 1)); }
warn()  { echo "  ⚠️  WARN — $1"; WARNINGS=$((WARNINGS + 1)); }
fail()  { echo "  ❌ FAIL — $1"; ERRORS=$((ERRORS + 1)); }

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Codex Brain Canary Check"
echo "  Project: $PROJECT_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. AGENTS.md exists and is in healthy range
echo ""
echo "📋 Root Instruction File..."
if [ -f "$PROJECT_DIR/AGENTS.md" ]; then
  LINES=$(wc -l < "$PROJECT_DIR/AGENTS.md")
  if [ "$LINES" -lt 10 ]; then
    fail "AGENTS.md is too short ($LINES lines, minimum 10)"
  elif [ "$LINES" -gt 800 ]; then
    fail "AGENTS.md is too long ($LINES lines, maximum 800 — Codex has a 32KB limit)"
  else
    info "AGENTS.md exists ($LINES lines)"
  fi
else
  fail "AGENTS.md not found"
fi

# 2. Token budget estimate (rough: 1 token ≈ 4 chars)
echo ""
echo "💰 Token Budget Estimate..."
if [ -f "$PROJECT_DIR/AGENTS.md" ]; then
  TOTAL_CHARS=$(wc -c < "$PROJECT_DIR/AGENTS.md")
  # brain/tasks/lessons.md is also always-loaded via session-start hook
  if [ -f "$PROJECT_DIR/brain/tasks/lessons.md" ]; then
    LESSON_CHARS=$(wc -c < "$PROJECT_DIR/brain/tasks/lessons.md")
    TOTAL_CHARS=$((TOTAL_CHARS + LESSON_CHARS))
  fi
  ESTIMATED_TOKENS=$((TOTAL_CHARS / 4))
  if [ "$ESTIMATED_TOKENS" -gt 15000 ]; then
    fail "Estimated always-on tokens ($ESTIMATED_TOKENS) exceeds 15K — context OVERLOADED"
  elif [ "$ESTIMATED_TOKENS" -gt 10000 ]; then
    warn "Estimated always-on tokens ($ESTIMATED_TOKENS) exceeds 10K — approaching heavy zone"
  else
    info "Estimated always-on tokens: ~$ESTIMATED_TOKENS (healthy)"
  fi
fi

# 3. Rule count audit
echo ""
echo "📐 Rule Count Audit..."
RULE_COUNT=0
if [ -f "$PROJECT_DIR/brain/rules.md" ]; then
  RULE_COUNT=$(grep -cE '^[[:space:]]*\*\*Rule [0-9]+' "$PROJECT_DIR/brain/rules.md" 2>/dev/null || echo 0)
fi
if [ "$RULE_COUNT" -lt 20 ]; then
  warn "Rules in brain/rules.md: $RULE_COUNT (expected 20+)"
else
  info "Rules in brain/rules.md: $RULE_COUNT"
fi

# 4. Skills inventory
echo ""
echo "🎓 Skills..."
if [ -d "$PROJECT_DIR/.agents/skills" ]; then
  SKILL_COUNT=$(find "$PROJECT_DIR/.agents/skills" -name 'SKILL.md' | wc -l)
  if [ "$SKILL_COUNT" -lt 10 ]; then
    fail "Skills found: $SKILL_COUNT (expected 10+)"
  else
    info "Skills found: $SKILL_COUNT"
  fi
else
  fail ".agents/skills/ directory not found"
fi

# 5. Hooks registered in hooks.json
echo ""
echo "🪝 Hooks..."
if [ -f "$PROJECT_DIR/.codex/hooks.json" ]; then
  if command -v jq &>/dev/null; then
    HOOK_COUNT=$(jq '[.. | objects | select(has("command"))] | length' "$PROJECT_DIR/.codex/hooks.json" 2>/dev/null || echo 0)
    info "Hooks registered in hooks.json: $HOOK_COUNT"
  else
    HOOK_COUNT=$(grep -c '"command"' "$PROJECT_DIR/.codex/hooks.json" 2>/dev/null || echo 0)
    info "Hooks registered in hooks.json: $HOOK_COUNT (jq not available, used grep)"
  fi

  # Verify hook scripts exist and are executable
  for hook_file in "$PROJECT_DIR"/.codex/hooks/*.sh; do
    [ -f "$hook_file" ] || continue
    if [ ! -x "$hook_file" ]; then
      fail "Hook script not executable: $(basename "$hook_file")"
    fi
  done
else
  fail ".codex/hooks.json not found"
fi

# 6. hooks_enabled in config.toml
echo ""
echo "⚙️  Config..."
if [ -f "$PROJECT_DIR/.codex/config.toml" ]; then
  if grep -q 'codex_hooks.*=.*true' "$PROJECT_DIR/.codex/config.toml" 2>/dev/null; then
    info "codex_hooks = true in config.toml"
  else
    warn "codex_hooks not enabled in config.toml — hooks will not fire"
  fi
else
  fail ".codex/config.toml not found"
fi

# 7. Agents
echo ""
echo "🤖 Agents..."
if [ -d "$PROJECT_DIR/.codex/agents" ]; then
  AGENT_COUNT=$(find "$PROJECT_DIR/.codex/agents" -name '*.toml' | wc -l)
  info "Agents found: $AGENT_COUNT"
else
  warn ".codex/agents/ not found"
fi

# 8. Shell safety: hook scripts must not use grep -E with double-quoted patterns
echo ""
echo "🔒 Shell Safety (Pipe-Immune Patterns)..."
GREP_E_DOUBLE_QUOTE=0
for hook_script in "$PROJECT_DIR"/.codex/hooks/*.sh; do
  [ -f "$hook_script" ] || continue
  BASENAME=$(basename "$hook_script")
  if grep -nE 'grep[[:space:]]+-[a-zA-Z]*[qn]?[a-zA-Z]*E[a-zA-Z]*[[:space:]]+"' "$hook_script" 2>/dev/null | grep -v '^[0-9]*:[[:space:]]*#' | grep -q '.'; then
    fail "Hook $BASENAME has grep -E with double-quoted pattern — use single quotes or case statement"
    GREP_E_DOUBLE_QUOTE=$((GREP_E_DOUBLE_QUOTE + 1))
  fi
done
if [ "$GREP_E_DOUBLE_QUOTE" -eq 0 ]; then
  info "No grep -E double-quoted alternation patterns in hooks"
fi

# 9. lessons.md size check
echo ""
echo "📝 Session Knowledge..."
if [ -f "$PROJECT_DIR/brain/tasks/lessons.md" ]; then
  LESSON_LINES=$(wc -l < "$PROJECT_DIR/brain/tasks/lessons.md")
  if [ "$LESSON_LINES" -gt 500 ]; then
    warn "brain/tasks/lessons.md exceeds 500 lines ($LESSON_LINES) — archive old entries"
  else
    info "brain/tasks/lessons.md size OK ($LESSON_LINES lines)"
  fi
else
  warn "brain/tasks/lessons.md not found"
fi

# 10. Remaining placeholder check
echo ""
echo "🔖 Placeholder Check..."
REMAINING=$(grep -rn '{{' "$PROJECT_DIR/AGENTS.md" "$PROJECT_DIR/brain/" 2>/dev/null | grep -v '_examples/' | grep -v '_template' | grep -v 'bootstrap' | grep -v 'node_modules' | grep -v 'brain/docs/' | grep -v 'brain/scripts/' | grep -v 'brain/tasks/' | grep -v "= '{{" || true)
if [ -z "$REMAINING" ]; then
  info "No remaining {{PLACEHOLDER}} values — bootstrap complete"
else
  PLACEHOLDER_COUNT=$(echo "$REMAINING" | wc -l)
  warn "$PLACEHOLDER_COUNT remaining {{PLACEHOLDER}} values — bootstrap may be incomplete"
fi

# 11. Stale reference scan in brain/*.md
echo ""
echo "🔍 Stale Reference Scan..."
STALE_FOUND=0
for doc in "$PROJECT_DIR"/brain/*.md; do
  [ -f "$doc" ] || continue
  for ref in $(grep -oE '`(brain/[^`]+|\.codex/[^`]+|\.agents/[^`]+)`' "$doc" 2>/dev/null | tr -d '`' || true); do
    if [ ! -e "$PROJECT_DIR/$ref" ] && [ ! -d "$PROJECT_DIR/$ref" ]; then
      if [[ "$ref" != *"*"* ]] && [[ "$ref" != *"**"* ]] && [[ "$ref" != *"<"* ]] && [[ "$ref" != *"..."* ]]; then
        warn "Stale reference in $(basename "$doc"): \`$ref\` does not exist"
        STALE_FOUND=1
      fi
    fi
  done
done
if [ "$STALE_FOUND" -eq 0 ]; then
  info "No stale file references found in brain/*.md"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Results: ✅ $PASSES passed | ❌ $ERRORS errors | ⚠️  $WARNINGS warnings"

if [ "$ERRORS" -gt 0 ]; then
  echo "  ❌ CANARY CHECK FAILED — fix $ERRORS error(s)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 1
else
  echo "  ✅ CANARY CHECK PASSED"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
fi
