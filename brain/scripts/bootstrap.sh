#!/usr/bin/env bash
# bootstrap.sh — Main bootstrap orchestrator for Codex Brain Bootstrap
# Runs discovery → template population → validation
# Usage: bash brain/scripts/bootstrap.sh [project-dir]
# Exit: 0 on success, 1 on failure

# ─── Source guard ─────────────────────────────────────────────────
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  echo "❌ bootstrap.sh must be EXECUTED, not sourced." >&2
  return 1 2>/dev/null || exit 1
fi

set -euo pipefail

PROJECT_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DISCOVERY_OUT="$PROJECT_DIR/brain/tasks/.discovery.env"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Codex Brain Bootstrap  ·  Bootstrap"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📍 Project: $PROJECT_DIR"
echo ""

# ─── Step 1: Discovery ────────────────────────────────────────────
echo "🔍 Step 1/3 — Scanning project..."
bash "$SCRIPT_DIR/discover.sh" "$PROJECT_DIR" > "$DISCOVERY_OUT" 2>&1
echo "  ✅ Discovery complete → $DISCOVERY_OUT"
echo ""

# ─── Step 2: Populate Templates ───────────────────────────────────
echo "🔄 Step 2/3 — Populating templates..."
bash "$SCRIPT_DIR/populate-templates.sh" "$DISCOVERY_OUT" "$PROJECT_DIR"
echo ""

# ─── Step 3: Validate ─────────────────────────────────────────────
echo "✔️  Step 3/3 — Validating..."
bash "$SCRIPT_DIR/validate.sh"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Bootstrap complete!"
echo ""
echo "  Next steps:"
echo "  1. Ask Codex to complete AGENTS.md: 'Fill in my project details'"
echo "  2. Review brain/architecture.md and add your service map"
echo "  3. Review brain/build.md and verify the commands are correct"
echo "  4. Make hook scripts executable: chmod +x .codex/hooks/*.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
