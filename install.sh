#!/usr/bin/env bash
# install.sh — Smart installer for Codex Brain Bootstrap
# Safely handles FRESH installs and upgrades of existing configurations.
#
# Usage:
#   git clone https://github.com/your-org/codex-brain-bootstrap.git /tmp/codex-brain
#   bash /tmp/codex-brain/install.sh /path/to/your-repo
#   rm -rf /tmp/codex-brain
#
# FRESH mode:  No Codex-related files exist → copies entire template.
# UPGRADE mode: Any Codex-related file exists → smart merge:
#   - NEVER overwrites user knowledge files (brain/*.md, brain/tasks/)
#   - Updates infrastructure (hooks, rules, agents, skills)
#   - Adds missing components

# ─── Source guard ─────────────────────────────────────────────────
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  echo "❌ install.sh must be EXECUTED, not sourced." >&2
  return 1 2>/dev/null || exit 1
fi

set -euo pipefail

source "$(dirname "$0")/brain/scripts/_platform.sh"

# ── Pre-flight check mode ─────────────────────────────────────────
if [ "${1:-}" = "--check" ]; then
  echo ""
  echo "🔍 Codex Brain Bootstrap — Pre-flight Check"
  echo ""
  echo "  Platform: $BRAIN_PLATFORM"
  require_tool git "required for repo detection" && echo "  ✅ git" || true
  if command -v jq &>/dev/null; then
    echo "  ✅ jq (hooks will parse JSON)"
  else
    echo "  ⚠️  jq not found — hooks will pass through without JSON parsing"
    case "$BRAIN_PLATFORM" in
      macos)   echo "     Install: brew install jq" ;;
      linux)   echo "     Install: sudo apt install jq" ;;
      windows) echo "     Install: scoop install jq" ;;
    esac
  fi
  bash_ver="${BASH_VERSINFO[0]:-0}"
  if [ "$bash_ver" -ge 4 ]; then
    echo "  ✅ bash $BASH_VERSION (≥4 — full support)"
  else
    echo "  ⚠️  bash $BASH_VERSION (<4 — discover.sh needs bash 4+)"
    echo '     Fix: brew install bash'
  fi
  if command -v uvx &>/dev/null; then
    echo "  ✅ uvx (MCP tools available)"
  else
    echo "  ⚠️  uvx not found — optional MCP tools (cocoindex, code-review-graph, serena) won't be available"
    echo "     Install: pip install uv"
  fi
  echo ""
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:?Usage: bash install.sh /path/to/your-repo}"

# ── Validate target is a git repo root ────────────────────────────
if [ ! -d "$TARGET" ]; then
  echo "❌ Target directory does not exist: $TARGET"
  echo "   Create and init your project first: mkdir -p $TARGET && git init $TARGET"
  exit 1
fi

TARGET="$(cd "$TARGET" && pwd)"

if ! git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1; then
  echo "❌ Target is not a git repository: $TARGET"
  echo "   Run: git init $TARGET"
  exit 1
fi

GIT_CDUP="$(git -C "$TARGET" rev-parse --show-cdup 2>/dev/null)" || true
if [ -n "$GIT_CDUP" ]; then
  GIT_ROOT="$(git -C "$TARGET" rev-parse --show-toplevel 2>/dev/null || true)"
  echo "❌ Target is a subdirectory. Install at repo root: bash $0 $GIT_ROOT"
  exit 1
fi

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║  Codex Brain Bootstrap — Smart Installer             ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "  Source:    $SCRIPT_DIR"
echo "  Target:    $TARGET"
echo "  Platform:  $BRAIN_PLATFORM"
echo ""

# ── Detect mode ───────────────────────────────────────────────────
has_codex_content() {
  [ -f "$TARGET/AGENTS.md" ] && return 0
  [ -d "$TARGET/.codex" ] && return 0
  [ -d "$TARGET/brain" ] && return 0
  [ -f "$TARGET/.codexignore" ] && return 0
  return 1
}

if has_codex_content; then
  MODE="UPGRADE"
else
  MODE="FRESH"
fi

echo "  Mode:    $MODE"
echo ""

# ── Helpers ────────────────────────────────────────────────────────

copy_if_missing() {
  local src="$1" dest="$2"
  if [ ! -e "$dest" ]; then
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    return 0
  fi
  return 1
}

add_missing_files() {
  local src_dir="$1" dest_dir="$2"
  local added=0
  [ -d "$src_dir" ] || { echo 0; return; }
  mkdir -p "$dest_dir"
  while IFS= read -r src_file; do
    [ -z "$src_file" ] && continue
    local rel="${src_file#"$src_dir/"}"
    local dest_file="$dest_dir/$rel"
    if [ ! -e "$dest_file" ]; then
      mkdir -p "$(dirname "$dest_file")"
      cp "$src_file" "$dest_file"
      added=$((added + 1))
    fi
  done < <(find "$src_dir" -type f 2>/dev/null)
  echo "$added"
}

# ── FRESH install ─────────────────────────────────────────────────
if [ "$MODE" = "FRESH" ]; then
  echo "🚀 Fresh install — copying all template files..."

  # Core config files
  copy_if_missing "$SCRIPT_DIR/AGENTS.md"                   "$TARGET/AGENTS.md"
  copy_if_missing "$SCRIPT_DIR/AGENTS.override.md.example"  "$TARGET/AGENTS.override.md.example"
  copy_if_missing "$SCRIPT_DIR/.codexignore"                "$TARGET/.codexignore"

  # .codex/ directory (config, hooks, rules, agents)
  n="$(add_missing_files "$SCRIPT_DIR/.codex" "$TARGET/.codex")"
  echo "  ✅ .codex/      — $n files"

  # .agents/ directory (skills)
  n="$(add_missing_files "$SCRIPT_DIR/.agents" "$TARGET/.agents")"
  echo "  ✅ .agents/     — $n files"

  # brain/ directory (knowledge base + scripts)
  n="$(add_missing_files "$SCRIPT_DIR/brain" "$TARGET/brain")"
  echo "  ✅ brain/       — $n files"

  echo ""
  echo "  ✅ Fresh install complete."

# ── UPGRADE install ───────────────────────────────────────────────
else
  echo "🔄 Upgrade mode — preserving user files, adding new components..."

  # AGENTS.md — never overwrite (user has customized it)
  if copy_if_missing "$SCRIPT_DIR/AGENTS.md" "$TARGET/AGENTS.md"; then
    echo "  ✅ AGENTS.md — created (missing)"
  else
    echo "  ⏭️  AGENTS.md — preserved (user-customized)"
  fi

  copy_if_missing "$SCRIPT_DIR/AGENTS.override.md.example" "$TARGET/AGENTS.override.md.example" && true
  copy_if_missing "$SCRIPT_DIR/.codexignore" "$TARGET/.codexignore" && true

  # Infrastructure: always update hooks, rules, agents (add missing, don't remove user additions)
  echo ""
  echo "  Updating infrastructure files (hooks, rules, agents, skills)..."

  # For infrastructure, add missing files without overwriting existing ones
  n="$(add_missing_files "$SCRIPT_DIR/.codex/hooks"   "$TARGET/.codex/hooks")"
  [ "$n" -gt 0 ] && echo "  ✅ .codex/hooks/    — $n new files added"

  n="$(add_missing_files "$SCRIPT_DIR/.codex/rules"   "$TARGET/.codex/rules")"
  [ "$n" -gt 0 ] && echo "  ✅ .codex/rules/    — $n new files added"

  n="$(add_missing_files "$SCRIPT_DIR/.codex/agents"  "$TARGET/.codex/agents")"
  [ "$n" -gt 0 ] && echo "  ✅ .codex/agents/   — $n new files added"

  n="$(add_missing_files "$SCRIPT_DIR/.agents"        "$TARGET/.agents")"
  [ "$n" -gt 0 ] && echo "  ✅ .agents/         — $n new files added"

  # Brain knowledge docs: NEVER overwrite — user has filled these in
  echo ""
  echo "  Adding missing brain/ components..."
  n="$(add_missing_files "$SCRIPT_DIR/brain/scripts"  "$TARGET/brain/scripts")"
  [ "$n" -gt 0 ] && echo "  ✅ brain/scripts/   — $n new files added"

  n="$(add_missing_files "$SCRIPT_DIR/brain/_examples" "$TARGET/brain/_examples")"
  [ "$n" -gt 0 ] && echo "  ✅ brain/_examples/ — $n new files added"

  # Only add brain/*.md files that are completely missing (never overwrite)
  for src_doc in "$SCRIPT_DIR/brain"/*.md; do
    [ -f "$src_doc" ] || continue
    filename="$(basename "$src_doc")"
    if copy_if_missing "$src_doc" "$TARGET/brain/$filename"; then
      echo "  ✅ brain/$filename — created (was missing)"
    fi
  done

  # brain/tasks: only add missing (lessons, errors, todo must never be overwritten)
  n="$(add_missing_files "$SCRIPT_DIR/brain/tasks" "$TARGET/brain/tasks")"
  [ "$n" -gt 0 ] && echo "  ✅ brain/tasks/     — $n new files added (existing preserved)"

  echo ""
  echo "  ✅ Upgrade complete."
fi

# ── Make hook scripts executable ──────────────────────────────────
echo ""
echo "🔒 Making hook scripts executable..."
find "$TARGET/.codex/hooks" -name '*.sh' -exec chmod +x {} \; 2>/dev/null && \
  echo "  ✅ .codex/hooks/*.sh — executable" || true

# ── Next steps ────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Codex Brain Bootstrap installed at: $TARGET"
echo ""
echo "  Next steps:"
echo ""
echo "  1. Bootstrap with Codex:"
echo "     Open the project in Codex and type:"
echo "     \$bootstrap"
echo ""
echo "  2. OR run bootstrap manually:"
echo "     cd $TARGET"
echo "     bash brain/scripts/discover.sh . > brain/tasks/.discovery.env"
echo "     bash brain/scripts/populate-templates.sh brain/tasks/.discovery.env ."
echo "     bash brain/scripts/validate.sh"
echo ""
echo "  3. Install optional MCP plugins:"
echo "     bash brain/scripts/setup-plugins.sh --all"
echo ""
echo "  4. Verify:"
echo "     bash brain/scripts/validate.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
