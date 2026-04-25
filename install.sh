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

# ─── Source guard — prevent env corruption if sourced ─────────────
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  echo "❌ install.sh must be EXECUTED, not sourced." >&2
  echo "   Wrong:  source install.sh /path/to/repo" >&2
  echo "   Right:  bash install.sh /path/to/repo" >&2
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
  require_tool git "required for repo detection" && echo "  ✅ git $(git --version 2>/dev/null | head -1)" || true
  if command -v jq &>/dev/null; then
    echo "  ✅ jq $(jq --version 2>/dev/null)"
  else
    echo "  ❌ jq not found — STRONGLY RECOMMENDED"
    echo "     Without jq: safety hooks (config protection, terminal safety gate,"
    echo "     commit quality) silently pass through. JSON-based discovery is degraded."
    case "$BRAIN_PLATFORM" in
      macos)   echo "     Install: brew install jq" ;;
      linux)   echo "     Install: sudo apt install jq  OR  sudo dnf install jq" ;;
      windows) echo "     Install: scoop install jq  OR  choco install jq" ;;
    esac
  fi
  bash_ver="${BASH_VERSINFO[0]:-0}"
  if [ "$bash_ver" -ge 4 ]; then
    echo "  ✅ bash $BASH_VERSION (≥4 — full support)"
  else
    echo "  ⚠️  bash $BASH_VERSION (<4 — discover.sh and populate-templates.sh need Bash 4+)"
    echo '     Fix: brew install bash && export PATH="$(brew --prefix)/bin:$PATH"'
  fi
  PY_FOUND=false
  for py_cmd in python3 python; do
    if command -v "$py_cmd" &>/dev/null; then
      PY_VER=$("$py_cmd" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null || true)
      PY_MAJOR="${PY_VER%%.*}"
      PY_MINOR="${PY_VER##*.}"
      if [ "${PY_MAJOR:-0}" -ge 3 ] && [ "${PY_MINOR:-0}" -ge 10 ]; then
        echo "  ✅ $py_cmd $PY_VER (≥3.10 — graphify knowledge graph ready)"
        PY_FOUND=true
        break
      else
        echo "  ⚠️  $py_cmd $PY_VER (<3.10 — graphify needs 3.10+)"
      fi
    fi
  done
  if [ "$PY_FOUND" = "false" ]; then
    echo "  ⚠️  Python 3.10+ not found — graphify knowledge graph won't be available"
    case "$BRAIN_PLATFORM" in
      macos)   echo "     Install: brew install python@3.12" ;;
      windows) echo "     Install: winget install Python.Python.3.12" ;;
      linux)   echo "     Install: sudo apt install python3" ;;
    esac
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

# ── Parse flags ────────────────────────────────────────────────────
POSITIONAL_ARGS=()
for arg in "$@"; do
  case "$arg" in
    --codex|--claude|--copilot)
      echo "⚠️  $arg flag is not valid for codex-brain-bootstrap." >&2
      echo "   Usage: bash install.sh /path/to/your-repo" >&2
      exit 1
      ;;
    *) POSITIONAL_ARGS+=("$arg") ;;
  esac
done
TARGET="${POSITIONAL_ARGS[0]:?Usage: bash install.sh /path/to/your-repo}"

# ── Validate target is a git repo root ────────────────────────────
if [ ! -d "$TARGET" ]; then
  echo ""
  echo "╔══════════════════════════════════════════════════════╗"
  echo "║  Codex Brain Bootstrap — Smart Installer             ║"
  echo "╚══════════════════════════════════════════════════════╝"
  echo ""
  echo "  Target:  $TARGET"
  echo ""
  echo "❌ ERROR: Target directory does not exist."
  echo "   Brain Bootstrap must be installed at the root of an existing git repo."
  echo ""
  echo "   Create and initialize your project first:"
  echo "     mkdir -p $TARGET"
  echo "     git init $TARGET"
  echo "     bash $0 $TARGET"
  echo ""
  exit 1
fi

TARGET="$(cd "$TARGET" && pwd)"

if ! git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1; then
  echo ""
  echo "╔══════════════════════════════════════════════════════╗"
  echo "║  Codex Brain Bootstrap — Smart Installer             ║"
  echo "╚══════════════════════════════════════════════════════╝"
  echo ""
  echo "  Target:  $TARGET"
  echo ""
  echo "❌ ERROR: Target is not inside a git repository."
  echo "   Brain Bootstrap must be installed at the root of a git repo."
  echo ""
  echo "   Initialize git first:"
  echo "     git init $TARGET"
  echo "     bash $0 $TARGET"
  echo ""
  exit 1
fi

GIT_CDUP="$(git -C "$TARGET" rev-parse --show-cdup 2>/dev/null)" || true
if [ -n "$GIT_CDUP" ]; then
  GIT_ROOT="$(git -C "$TARGET" rev-parse --show-toplevel 2>/dev/null || true)"
  echo ""
  echo "╔══════════════════════════════════════════════════════╗"
  echo "║  Codex Brain Bootstrap — Smart Installer             ║"
  echo "╚══════════════════════════════════════════════════════╝"
  echo ""
  echo "  Target:     $TARGET"
  echo "  Repo root:  $GIT_ROOT"
  echo ""
  echo "❌ ERROR: Target is a subdirectory of a git repo, not the root."
  echo "   Brain Bootstrap must be installed at the REPOSITORY ROOT."
  echo ""
  echo "   Use the repo root instead:"
  echo "     bash $0 $GIT_ROOT"
  echo ""
  exit 1
fi

# ── Self-bootstrap guard ──────────────────────────────────────────
if [ -f "$TARGET/CONTRIBUTING.md" ]; then
  if grep -q 'codex-brain-bootstrap' "$TARGET/CONTRIBUTING.md" 2>/dev/null; then
    echo "❌ ERROR: Target appears to be the Brain Bootstrap template repo itself."
    echo "   Install into your PROJECT repo, not into the template."
    echo "   Usage: bash install.sh /path/to/your-actual-project"
    exit 1
  fi
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
  local _tmplist
  _tmplist=$(mktemp)
  find "$src_dir" -type f > "$_tmplist" 2>/dev/null
  while IFS= read -r src_file; do
    [ -z "$src_file" ] && continue
    local rel="${src_file#"$src_dir/"}"
    local dest_file="$dest_dir/$rel"
    if [ ! -e "$dest_file" ]; then
      mkdir -p "$(dirname "$dest_file")"
      cp "$src_file" "$dest_file"
      added=$((added + 1))
    fi
  done < "$_tmplist"
  rm -f "$_tmplist"
  echo "$added"
}

# Smart sync: update template-originated files, add new template files,
# PRESERVE user-only files (exist in dest only — never touched).
# Echoes "updated:added:preserved" counts.
sync_dir() {
  local src_dir="$1" dest_dir="$2"
  local updated=0 added=0 preserved=0
  [ -d "$src_dir" ] || { echo "0:0:0"; return; }
  mkdir -p "$dest_dir"
  local _tmplist
  _tmplist=$(mktemp)
  find "$src_dir" -type f > "$_tmplist" 2>/dev/null
  while IFS= read -r src_file; do
    [ -z "$src_file" ] && continue
    local rel="${src_file#"$src_dir/"}"
    local dest_file="$dest_dir/$rel"
    mkdir -p "$(dirname "$dest_file")"
    if [ -e "$dest_file" ]; then
      if ! diff -q "$src_file" "$dest_file" >/dev/null 2>&1; then
        cp "$src_file" "$dest_file"
        updated=$((updated + 1))
      fi
    else
      cp "$src_file" "$dest_file"
      added=$((added + 1))
    fi
  done < "$_tmplist"
  rm -f "$_tmplist"
  # Count user-only files preserved
  if [ -d "$dest_dir" ]; then
    local _tmplist2
    _tmplist2=$(mktemp)
    find "$dest_dir" -type f > "$_tmplist2" 2>/dev/null
    while IFS= read -r dest_file; do
      [ -z "$dest_file" ] && continue
      local rel="${dest_file#"$dest_dir/"}"
      [ ! -e "$src_dir/$rel" ] && preserved=$((preserved + 1))
    done < "$_tmplist2"
    rm -f "$_tmplist2"
  fi
  echo "$updated:$added:$preserved"
}

# ── FRESH install ─────────────────────────────────────────────────
if [ "$MODE" = "FRESH" ]; then
  echo "🚀 Fresh install — copying all template files..."

  # Core config files
  copy_if_missing "$SCRIPT_DIR/AGENTS.md"                   "$TARGET/AGENTS.md"
  copy_if_missing "$SCRIPT_DIR/AGENTS.override.md.example"  "$TARGET/AGENTS.override.md.example"
  copy_if_missing "$SCRIPT_DIR/.codexignore"                "$TARGET/.codexignore"
  copy_if_missing "$SCRIPT_DIR/.shellcheckrc"               "$TARGET/.shellcheckrc"

  # .codex/ directory (config, hooks, rules, agents)
  n="$(add_missing_files "$SCRIPT_DIR/.codex" "$TARGET/.codex")"
  echo "  ✅ .codex/      — $n files"

  # .agents/ directory (skills)
  n="$(add_missing_files "$SCRIPT_DIR/.agents" "$TARGET/.agents")"
  echo "  ✅ .agents/     — $n files"

  # brain/ directory (knowledge base + scripts)
  n="$(add_missing_files "$SCRIPT_DIR/brain" "$TARGET/brain")"
  echo "  ✅ brain/       — $n files"

  # Tool config dirs
  n="$(add_missing_files "$SCRIPT_DIR/.serena" "$TARGET/.serena")"
  echo "  ✅ .serena/     — $n files"

  n="$(add_missing_files "$SCRIPT_DIR/.cocoindex_code" "$TARGET/.cocoindex_code")"
  echo "  ✅ .cocoindex_code/ — $n files"

  # CI / GitHub templates
  n="$(add_missing_files "$SCRIPT_DIR/.github" "$TARGET/.github")"
  echo "  ✅ .github/     — $n files"

  # Count all installed files
  total=0
  for _dir in "$TARGET/.codex" "$TARGET/.agents" "$TARGET/brain"; do
    [ -d "$_dir" ] && total=$((total + $(find "$_dir" -type f 2>/dev/null | wc -l)))
  done
  for _f in AGENTS.md AGENTS.override.md.example .codexignore .shellcheckrc; do
    [ -f "$TARGET/$_f" ] && total=$((total + 1))
  done

  # Make scripts executable inline
  chmod +x "$TARGET/.codex/hooks/"*.sh 2>/dev/null || true
  chmod +x "$TARGET/brain/scripts/"*.sh 2>/dev/null || true

  echo ""
  echo "✅ Fresh install complete! $total files installed."
  echo ""
  echo "👉 Next step:"
  echo "   Open Codex and run \$bootstrap"
  echo ""
  exit 0

# ── UPGRADE install ───────────────────────────────────────────────
else
  echo "🔄 Upgrade mode — preserving user files, updating infrastructure..."
  echo ""

  PRESERVED_COUNT=0
  UPDATED_COUNT=0
  ADDED_COUNT=0

  # ── Pre-upgrade backup ──────────────────────────────────────────
  mkdir -p "$TARGET/brain/tasks"
  if (cd "$TARGET" && tar czf "brain/tasks/.pre-upgrade-backup.tar.gz" \
    AGENTS.md .codexignore .codex/ .agents/ brain/ .github/ 2>/dev/null); then
    true
  fi
  echo "  💾 Safety backup → brain/tasks/.pre-upgrade-backup.tar.gz"
  echo "     Restore: tar xzf brain/tasks/.pre-upgrade-backup.tar.gz"
  echo ""

  # ── Phase A: Inventory & protect ALL user content ─────────────────
  # Dynamically scans everything the user has. No hardcoded file lists.
  # REPORTING ONLY — preservation is enforced structurally by sync_dir
  # (preserves user-only files) and copy_if_missing (never overwrites).

  echo "🛡️  Phase A — Inventorying your data (NEVER overwritten):"

  # Root files
  for f in AGENTS.md AGENTS.override.md.example .codexignore .shellcheckrc; do
    if [ -f "$TARGET/$f" ]; then
      echo "  🔒 $f"
      PRESERVED_COUNT=$((PRESERVED_COUNT + 1))
    fi
  done

  # All user files in brain/ EXCEPT infrastructure dirs
  # (infrastructure dirs are handled by sync_dir in Phase B — user-only files preserved there too)
  if [ -d "$TARGET/brain" ]; then
    _tmpinv1=$(mktemp)
    find "$TARGET/brain" -type f ! -name '.gitkeep' > "$_tmpinv1" 2>/dev/null
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      rel="${f#"$TARGET/"}"
      # Skip infrastructure dirs — Phase B handles them with sync_dir
      case "$rel" in
        brain/scripts/*|brain/_examples/*|brain/docs/*) continue ;;
      esac
      case "$rel" in
        brain/tasks/lessons.md|brain/tasks/todo.md|brain/tasks/CODEX_ERRORS.md)
          echo "  🔒 $rel (sacred — never modified)" ;;
        *)
          echo "  🔒 $rel" ;;
      esac
      PRESERVED_COUNT=$((PRESERVED_COUNT + 1))
    done < "$_tmpinv1"
    rm -f "$_tmpinv1"
  fi

  # All user files in .codex/
  if [ -d "$TARGET/.codex" ]; then
    _tmpinv2=$(mktemp)
    find "$TARGET/.codex" -type f > "$_tmpinv2" 2>/dev/null
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      rel="${f#"$TARGET/"}"
      echo "  🔒 $rel"
      PRESERVED_COUNT=$((PRESERVED_COUNT + 1))
    done < "$_tmpinv2"
    rm -f "$_tmpinv2"
  fi

  # All user files in .agents/
  if [ -d "$TARGET/.agents" ]; then
    _tmpinv3=$(mktemp)
    find "$TARGET/.agents" -type f > "$_tmpinv3" 2>/dev/null
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      rel="${f#"$TARGET/"}"
      echo "  🔒 $rel"
      PRESERVED_COUNT=$((PRESERVED_COUNT + 1))
    done < "$_tmpinv3"
    rm -f "$_tmpinv3"
  fi

  echo ""
  echo "  → $PRESERVED_COUNT existing files protected"
  echo ""

  # ── Phase B: Sync infrastructure dirs ───────────────────────────
  # Uses sync_dir: updates template files, adds new ones, preserves user-only files.
  echo "⬆️  Phase B — Updating Brain infrastructure:"
  for dir_pair in \
    ".codex/hooks:hooks" \
    ".codex/rules:rules" \
    ".codex/agents:agents" \
    ".agents:skills" \
    "brain/scripts:scripts" \
    "brain/_examples:examples" \
    "brain/docs:docs"; do
    dir_name="${dir_pair%%:*}"
    dir_label="${dir_pair#*:}"
    src="$SCRIPT_DIR/$dir_name"
    dest="$TARGET/$dir_name"
    if [ -d "$src" ]; then
      result=$(sync_dir "$src" "$dest")
      u="${result%%:*}"; rest="${result#*:}"; a="${rest%%:*}"; p="${rest#*:}"
      UPDATED_COUNT=$((UPDATED_COUNT + u))
      ADDED_COUNT=$((ADDED_COUNT + a))
      status=""
      [ "$u" -gt 0 ] && status="${status}${u} updated"
      [ "$a" -gt 0 ] && status="${status:+$status, }${a} added"
      [ "$p" -gt 0 ] && status="${status:+$status, }${p} user files kept"
      [ -z "$status" ] && status="up to date"
      echo "  ⬆️  $dir_name/ → $status ($dir_label)"
    fi
  done
  echo ""

  # ── Phase C: Tool config dirs (add missing only) ─────────────────
  echo "➕ Phase C — Tool configs (add missing, preserve customizations):"
  for dir_pair in \
    ".serena:serena LSP" \
    ".cocoindex_code:cocoindex data" \
    ".github:CI templates"; do
    dir_name="${dir_pair%%:*}"
    dir_label="${dir_pair#*:}"
    src="$SCRIPT_DIR/$dir_name"
    dest="$TARGET/$dir_name"
    if [ -d "$src" ]; then
      n="$(add_missing_files "$src" "$dest")"
      ADDED_COUNT=$((ADDED_COUNT + n))
      if [ "$n" -gt 0 ]; then
        echo "  ➕ $dir_name/ — $n new files ($dir_label)"
      else
        echo "  ✅ $dir_name/ — up to date"
      fi
    fi
  done
  echo ""

  # ── Phase D: Add missing root files and user data (add only, never overwrite) ──
  echo "➕ Phase D — Adding missing files:"

  phase_d_added=0

  # Root files
  for f in AGENTS.md AGENTS.override.md.example .codexignore .shellcheckrc; do
    if [ -f "$SCRIPT_DIR/$f" ] && copy_if_missing "$SCRIPT_DIR/$f" "$TARGET/$f"; then
      echo "  ➕ $f (new)"
      phase_d_added=$((phase_d_added + 1))
    fi
  done

  # Brain root *.md docs (add missing only)
  mkdir -p "$TARGET/brain"
  for src_doc in "$SCRIPT_DIR/brain"/*.md; do
    [ -f "$src_doc" ] || continue
    filename="$(basename "$src_doc")"
    if copy_if_missing "$src_doc" "$TARGET/brain/$filename"; then
      echo "  ➕ brain/$filename (new)"
      phase_d_added=$((phase_d_added + 1))
    fi
  done

  # brain/tasks (lessons, errors, todo — sacred user data)
  # Uses find instead of glob to catch dotfiles (.gitignore, .gitkeep)
  mkdir -p "$TARGET/brain/tasks"
  _tmptasks=$(mktemp)
  find "$SCRIPT_DIR/brain/tasks" -maxdepth 1 -type f > "$_tmptasks" 2>/dev/null
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    fname="$(basename "$f")"
    if copy_if_missing "$f" "$TARGET/brain/tasks/$fname"; then
      echo "  ➕ brain/tasks/$fname (new)"
      phase_d_added=$((phase_d_added + 1))
    fi
  done < "$_tmptasks"
  rm -f "$_tmptasks"

  ADDED_COUNT=$((ADDED_COUNT + phase_d_added))

  if [ "$phase_d_added" -eq 0 ]; then
    echo "  ✅ All files present — nothing to add"
  fi

  echo ""

  # ── Phase E: Gitignore guard ─────────────────────────────────────
  # Ensure Codex-specific files that should stay out of version control
  # are listed in .gitignore. Supports SOLO/TEAM detection:
  # SOLO mode: AGENTS.md is already gitignored → also gitignore personal config files
  echo "🔒 Phase E — Gitignore guard:"

  GITIGNORE_FILE="$TARGET/.gitignore"
  GITIGNORE_ADDED=0

  if [ -f "$GITIGNORE_FILE" ]; then
    # Always-personal files: gitignored regardless of SOLO/TEAM
    ALWAYS_PERSONAL="brain/tasks/.pre-upgrade-backup.tar.gz brain/tasks/.discovery.env .cocoindex_code/"
    # SOLO-only files: gitignored when repo already gitignores AGENTS.md
    SOLO_PERSONAL="AGENTS.local.md .codex/settings.local.toml"

    IS_SOLO=false
    if grep -qE '^AGENTS\.md$' "$GITIGNORE_FILE" 2>/dev/null; then
      IS_SOLO=true
    fi

    MISSING_ENTRIES=""
    for pf in $ALWAYS_PERSONAL; do
      if ! grep -qF "$pf" "$GITIGNORE_FILE" 2>/dev/null; then
        MISSING_ENTRIES="$MISSING_ENTRIES$pf
"
        GITIGNORE_ADDED=$((GITIGNORE_ADDED + 1))
      fi
    done

    if [ "$IS_SOLO" = true ]; then
      for pf in $SOLO_PERSONAL; do
        if ! grep -qF "$pf" "$GITIGNORE_FILE" 2>/dev/null; then
          MISSING_ENTRIES="$MISSING_ENTRIES$pf
"
          GITIGNORE_ADDED=$((GITIGNORE_ADDED + 1))
        fi
      done
    fi

    if [ -n "$MISSING_ENTRIES" ]; then
      printf '\n# Codex Brain Bootstrap — local/generated files (added by install.sh)\n' >> "$GITIGNORE_FILE"
      printf '%s' "$MISSING_ENTRIES" >> "$GITIGNORE_FILE"
      echo "  ➕ Added $GITIGNORE_ADDED entry/entries to .gitignore"
    else
      echo "  ✅ All Brain-generated files already gitignored"
    fi
  else
    echo "  ⏭️  Skipped — no .gitignore found"
  fi

  echo ""

  # ── Summary ─────────────────────────────────────────────────────
  echo "╔══════════════════════════════════════════════════════╗"
  echo "║  ✅  Smart merge complete!                           ║"
  echo "╚══════════════════════════════════════════════════════╝"
  echo ""
  echo "  🔒 Preserved:  $PRESERVED_COUNT user files (knowledge, tasks, config)"
  echo "  ⬆️  Updated:    $UPDATED_COUNT infrastructure files"
  echo "  ➕ Added:      $ADDED_COUNT new Brain components"
  echo ""
  echo "  Every file you created — CODEX_ERRORS, lessons, architecture docs,"
  echo "  domain knowledge, custom agents, rules — is exactly as you left it."
fi

# ── Make scripts executable ───────────────────────────────────────
echo ""
echo "🔒 Making scripts executable..."
find "$TARGET/.codex/hooks" -name '*.sh' -exec chmod +x {} \; 2>/dev/null && \
  echo "  ✅ .codex/hooks/*.sh — executable" || true
find "$TARGET/brain/scripts" -name '*.sh' -exec chmod +x {} \; 2>/dev/null && \
  echo "  ✅ brain/scripts/*.sh — executable" || true
find "$TARGET/.agents/skills" -name '*.sh' -exec chmod +x {} \; 2>/dev/null && \
  echo "  ✅ .agents/skills/**/*.sh — executable" || true

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

if ! command -v jq &>/dev/null; then
  echo ""
  echo "⚠️  jq is not installed — safety hooks will be degraded."
  echo "   Without jq, config-protection, terminal-safety-gate, and commit-quality"
  echo "   hooks cannot parse JSON tool input and will silently pass through."
  echo ""
  case "$BRAIN_PLATFORM" in
    macos)   echo "   Install now:  brew install jq" ;;
    windows) echo "   Install now:  scoop install jq  OR  choco install jq" ;;
    linux)   echo "   Install now:  sudo apt install jq  OR  sudo dnf install jq" ;;
  esac
  echo ""
fi
echo ""