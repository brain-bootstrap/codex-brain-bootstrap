#!/usr/bin/env bash
# validate.sh — Template consistency and completeness validator for Codex Brain Bootstrap
# Run: bash brain/scripts/validate.sh
# Exit: 0 if all checks pass, 1 if any fail

# ─── Source guard ─────────────────────────────────────────────────
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  echo "❌ validate.sh must be EXECUTED, not sourced." >&2
  return 1 2>/dev/null || exit 1
fi

set -euo pipefail

PASS=0
FAIL=0
WARN=0

pass() { echo "  ✅ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
warn() { echo "  ⚠️  $1"; WARN=$((WARN + 1)); }

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Codex Brain Bootstrap  ·  Validator"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. Required files exist
echo ""
echo "📁 Required files..."
REQUIRED_FILES=(
  "AGENTS.md"
  "AGENTS.override.md.example"
  ".codexignore"
  ".codex/config.toml"
  ".codex/hooks.json"
  ".codex/rules/default.rules"
  "brain/rules.md"
  "brain/architecture.md"
  "brain/build.md"
  "brain/terminal-safety.md"
  "brain/templates.md"
  "brain/plugins.md"
  "brain/cve-policy.md"
  "brain/decisions.md"
  "brain/tasks/todo.md"
  "brain/tasks/lessons.md"
  "brain/tasks/CODEX_ERRORS.md"
)

for f in "${REQUIRED_FILES[@]}"; do
  if [ -f "$f" ]; then
    pass "$f"
  else
    fail "MISSING: $f"
  fi
done

# 2. Hook scripts exist and are executable
echo ""
echo "🔗 Hook scripts..."
HOOK_SCRIPTS=(
  ".codex/hooks/session-start.sh"
  ".codex/hooks/config-protection.sh"
  ".codex/hooks/terminal-safety-gate.sh"
  ".codex/hooks/pre-commit-quality.sh"
  ".codex/hooks/permission-audit.sh"
  ".codex/hooks/post-bash-review.sh"
  ".codex/hooks/tdd-loop-check.sh"
  ".codex/hooks/exit-nudge.sh"
  ".codex/hooks/warn-missing-test.sh"
)

for f in "${HOOK_SCRIPTS[@]}"; do
  if [ -f "$f" ]; then
    if [ -x "$f" ]; then
      pass "$f (executable)"
    else
      warn "$f exists but is NOT executable — run: chmod +x $f"
    fi
  else
    fail "MISSING: $f"
  fi
done

# 3. Skills exist
echo ""
echo "🛠️  Skills..."
SKILLS=(
  ".agents/skills/bootstrap/SKILL.md"
  ".agents/skills/plan/SKILL.md"
  ".agents/skills/review/SKILL.md"
  ".agents/skills/tdd/SKILL.md"
  ".agents/skills/debug/SKILL.md"
  ".agents/skills/research/SKILL.md"
  ".agents/skills/resume/SKILL.md"
  ".agents/skills/mr/SKILL.md"
  ".agents/skills/build/SKILL.md"
  ".agents/skills/test/SKILL.md"
  ".agents/skills/lint/SKILL.md"
  ".agents/skills/maintain/SKILL.md"
  ".agents/skills/checkpoint/SKILL.md"
  ".agents/skills/root-cause-trace/SKILL.md"
  ".agents/skills/cross-layer-check/SKILL.md"
  ".agents/skills/worktree/SKILL.md"
  ".agents/skills/brainstorming/SKILL.md"
  ".agents/skills/careful/SKILL.md"
  ".agents/skills/changelog/SKILL.md"
  ".agents/skills/cocoindex-code/SKILL.md"
  ".agents/skills/code-review-graph/SKILL.md"
  ".agents/skills/playwright/SKILL.md"
  ".agents/skills/receiving-code-review/SKILL.md"
  ".agents/skills/repo-recap/SKILL.md"
  ".agents/skills/serena/SKILL.md"
  ".agents/skills/subagent-driven-development/SKILL.md"
  ".agents/skills/issue-triage/SKILL.md"
  ".agents/skills/pr-triage/SKILL.md"
  ".agents/skills/writing-skills/SKILL.md"
  ".agents/skills/codebase-memory/SKILL.md"
  ".agents/skills/ask/SKILL.md"
  ".agents/skills/clean-worktrees/SKILL.md"
  ".agents/skills/cleanup/SKILL.md"
  ".agents/skills/context/SKILL.md"
  ".agents/skills/db/SKILL.md"
  ".agents/skills/deps/SKILL.md"
  ".agents/skills/diff/SKILL.md"
  ".agents/skills/docker/SKILL.md"
  ".agents/skills/git/SKILL.md"
  ".agents/skills/health/SKILL.md"
  ".agents/skills/mcp/SKILL.md"
  ".agents/skills/migrate/SKILL.md"
  ".agents/skills/serve/SKILL.md"
  ".agents/skills/squad-plan/SKILL.md"
  ".agents/skills/status/SKILL.md"
  ".agents/skills/ticket/SKILL.md"
  ".agents/skills/update-code-index/SKILL.md"
  ".agents/skills/worktree-status/SKILL.md"
)

for f in "${SKILLS[@]}"; do
  if [ -f "$f" ]; then
    pass "$f"
  else
    fail "MISSING: $f"
  fi
done

# 4. Subagent definitions exist
echo ""
echo "🤖 Subagents..."
AGENTS=(
  ".codex/agents/explorer.toml"
  ".codex/agents/reviewer.toml"
  ".codex/agents/plan-challenger.toml"
  ".codex/agents/security-auditor.toml"
  ".codex/agents/session-reviewer.toml"
)

for f in "${AGENTS[@]}"; do
  if [ -f "$f" ]; then
    pass "$f"
  else
    fail "MISSING: $f"
  fi
done

# 5. Unfilled placeholders check
echo ""
echo "🔲 Unfilled placeholders..."
PLACEHOLDER_FILES=(
  "AGENTS.md"
  "brain/architecture.md"
  "brain/build.md"
  "brain/cve-policy.md"
)

for f in "${PLACEHOLDER_FILES[@]}"; do
  if [ -f "$f" ]; then
    count=$(grep -c '{{[A-Z_]*}}' "$f" 2>/dev/null || echo 0)
    if [ "$count" -gt 0 ]; then
      warn "$f has $count unfilled {{PLACEHOLDER}} token(s) — run \$bootstrap to fill"
    else
      pass "$f (no unfilled placeholders)"
    fi
  fi
done

# 6b. config.toml has schema directive
echo ""
echo "⚙️  config.toml schema directive..."
if grep -q '^#:schema' .codex/config.toml 2>/dev/null; then
  pass "config.toml has #:schema directive"
else
  warn "config.toml missing #:schema directive (add as first line for IDE autocomplete)"
fi

# 7. AGENTS.md references brain/ docs (not claude/ docs)
echo ""
echo "📚 AGENTS.md references..."
if grep -q 'claude/' AGENTS.md 2>/dev/null; then
  warn "AGENTS.md may still reference claude/ paths — verify they've been updated to brain/"
else
  pass "AGENTS.md uses brain/ references"
fi

# 8. Config files exist
echo ""
echo "⚙️  Config files..."
CONFIG_FILES=(
  ".serena/project.yml"
  ".cocoindex_code/settings.yml"
  ".shellcheckrc"
  "brain/tasks/.gitignore"
)

for f in "${CONFIG_FILES[@]}"; do
  if [ -f "$f" ]; then
    pass "$f"
  else
    fail "MISSING: $f"
  fi
done

# 9. New scripts and files created in session
echo ""
echo "📁 Additional scripts and files..."
NEW_FILES=(
  "brain/docs/DETAILED_GUIDE.md"
  "brain/scripts/canary-check.sh"
  "brain/scripts/migrate-tasks.sh"
  "brain/scripts/merge-agents-md.sh"
  "brain/scripts/merge-codexignore.sh"
  "brain/scripts/dry-run.sh"
  "brain/scripts/post-bootstrap-validate.sh"
  ".github/workflows/ci.yml"
  ".github/PULL_REQUEST_TEMPLATE.md"
  ".github/ISSUE_TEMPLATE/bug-report.yml"
  ".github/ISSUE_TEMPLATE/feature-request.yml"
  ".github/ISSUE_TEMPLATE/config.yml"
  ".agents/skills/cross-layer-check/scripts/cross-layer-check.sh"
)

for f in "${NEW_FILES[@]}"; do
  if [ -f "$f" ]; then
    pass "$f"
  else
    fail "MISSING: $f"
  fi
done

NEW_EXECUTABLES=(
  "brain/scripts/canary-check.sh"
  "brain/scripts/migrate-tasks.sh"
  "brain/scripts/merge-agents-md.sh"
  "brain/scripts/merge-codexignore.sh"
  "brain/scripts/dry-run.sh"
  "brain/scripts/post-bootstrap-validate.sh"
  ".agents/skills/cross-layer-check/scripts/cross-layer-check.sh"
)

for f in "${NEW_EXECUTABLES[@]}"; do
  if [ -x "$f" ]; then
    pass "$f is executable"
  else
    fail "NOT EXECUTABLE: $f"
  fi
done

# ─── Summary ──────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Results: ✅ $PASS passed   ❌ $FAIL failed   ⚠️  $WARN warnings"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$FAIL" -gt 0 ]; then
  echo "  ❌ $FAIL check(s) failed — review above and fix before using."
  exit 1
elif [ "$WARN" -gt 0 ]; then
  echo "  ⚠️  Warnings found — bootstrap may not be fully configured."
  exit 0
else
  echo "  ✅ All checks passed. Bootstrap is complete."
  exit 0
fi
