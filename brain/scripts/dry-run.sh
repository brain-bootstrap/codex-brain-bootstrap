#!/usr/bin/env bash
# dry-run.sh — Preview ALL structural changes $bootstrap would make
# Runs every merge script in --dry-run mode. Changes nothing on disk.
#
# Usage: bash brain/scripts/dry-run.sh [project-dir]
# Exit:  0 always

# ─── Source guard ─────────────────────────────────────────────────
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  echo "❌ dry-run.sh must be EXECUTED, not sourced." >&2
  return 1 2>/dev/null || exit 1
fi

PROJECT_DIR="${1:-.}"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISCOVERY_ENV="$PROJECT_DIR/brain/tasks/.discovery.env"
BOOTSTRAP_DIR="$PROJECT_DIR/brain/bootstrap"

echo "╔══════════════════════════════════════════════════════╗"
echo "║  ᗺB  Codex Brain Bootstrap — Dry Run Preview         ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "  No files will be modified. This is a preview only."
echo ""

# ─── 1. Tasks migration ──────────────────────────────────────────
echo "━━━ 1/3 Tasks Migration ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f "$DISCOVERY_ENV" ]; then
  bash "$SCRIPTS_DIR/migrate-tasks.sh" --discovery-env "$DISCOVERY_ENV" --target "$PROJECT_DIR" --dry-run 2>&1 || true
else
  bash "$SCRIPTS_DIR/migrate-tasks.sh" --target "$PROJECT_DIR" --dry-run 2>&1 || true
fi
echo ""

# ─── 2. AGENTS.md section merge ──────────────────────────────────
echo "━━━ 2/3 AGENTS.md Section Merge ━━━━━━━━━━━━━━━━━━━━━"
TMPL="$BOOTSTRAP_DIR/_AGENTS.md.template"
if [ -f "$TMPL" ] && [ -f "$PROJECT_DIR/AGENTS.md" ]; then
  bash "$SCRIPTS_DIR/merge-agents-md.sh" --template "$TMPL" --target "$PROJECT_DIR/AGENTS.md" --dry-run 2>&1 || true
else
  echo "  ⏭️  Skipped (template or target missing)"
fi
echo ""

# ─── 3. .codexignore union merge ─────────────────────────────────
echo "━━━ 3/3 .codexignore Union Merge ━━━━━━━━━━━━━━━━━━━━"
TMPL="$BOOTSTRAP_DIR/_codexignore.template"
if [ -f "$TMPL" ] && [ -f "$PROJECT_DIR/.codexignore" ]; then
  bash "$SCRIPTS_DIR/merge-codexignore.sh" \
    --template "$TMPL" \
    --target "$PROJECT_DIR/.codexignore" \
    --discovery-env "$DISCOVERY_ENV" \
    --dry-run 2>&1 || true
else
  echo "  ⏭️  Skipped (template or target missing)"
fi
echo ""

echo "╔══════════════════════════════════════════════════════╗"
echo "║  ✅ Dry run complete — no files were modified         ║"
echo "╚══════════════════════════════════════════════════════╝"
