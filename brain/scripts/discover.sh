#!/usr/bin/env bash
# discover.sh — Single-pass repository scanner for Codex Brain Bootstrap
# Scans the project and outputs KEY=VALUE pairs for use by populate-templates.sh
# Usage: bash brain/scripts/discover.sh [project-dir]
# Exit: Always 0 (informational output only)

# ─── Source guard ─────────────────────────────────────────────────
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  echo "❌ discover.sh must be EXECUTED, not sourced." >&2
  return 1 2>/dev/null || exit 1
fi

# ─── Bash 4+ required ─────────────────────────────────────────────
if [ "${BASH_VERSINFO[0]:-0}" -lt 4 ]; then
  for _brew_bash in /opt/homebrew/bin/bash /usr/local/bin/bash; do
    if [ -x "$_brew_bash" ] && [ "$("$_brew_bash" -c 'echo ${BASH_VERSINFO[0]}')" -ge 4 ] 2>/dev/null; then
      exec "$_brew_bash" "$0" "$@"
    fi
  done
  echo "❌ bash 4+ required (found: ${BASH_VERSION:-unknown})" >&2
  echo '   Fix: brew install bash' >&2
  exit 1
fi

set -o pipefail
PROJECT_DIR="${1:-.}"
cd "$PROJECT_DIR" || exit 1

emit() { echo "$1=$2"; }

echo "# ============================================="
echo "# Codex Brain Bootstrap — Discovery Results"
echo "# Generated: $(date '+%Y-%m-%d %H:%M:%S')"
echo "# Project: $PWD"
echo "# ============================================="
echo ""

# ─── Pre-Flight: Existing Configuration ───────────────────────────
echo "# --- Pre-Flight ---"
emit "HAS_AGENTS_MD"    "$([ -f 'AGENTS.md' ] && echo true || echo false)"
emit "HAS_DOT_CODEX"    "$([ -d '.codex' ] && echo true || echo false)"
emit "HAS_BRAIN_DIR"    "$([ -d 'brain' ] && echo true || echo false)"
emit "HAS_LESSONS"      "$([ -f 'brain/tasks/lessons.md' ] && echo true || echo false)"

# Upgrade detection: lessons.md with content = prior bootstrap ran
UPGRADE_MODE=false
if [ -f "brain/tasks/lessons.md" ] && grep -qv '^#\|^$\|^_' "brain/tasks/lessons.md" 2>/dev/null; then
  UPGRADE_MODE=true
fi
emit "UPGRADE_MODE" "$UPGRADE_MODE"

echo ""

# ─── Project Identity ─────────────────────────────────────────────
echo "# --- Project Identity ---"

# Project name from directory
PROJECT_DIR_NAME="$(basename "$PWD")"
emit "PROJECT_DIR_NAME" "$PROJECT_DIR_NAME"

# Git remote name
GIT_REMOTE_URL="$(git remote get-url origin 2>/dev/null || echo '')"
if [ -n "$GIT_REMOTE_URL" ]; then
  # Extract repo name from URL
  REPO_NAME="$(basename "$GIT_REMOTE_URL" .git)"
  emit "REPO_NAME" "$REPO_NAME"
else
  emit "REPO_NAME" "$PROJECT_DIR_NAME"
fi

# Git default branch
DEFAULT_BRANCH="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|.*/||' || echo 'main')"
emit "DEFAULT_BRANCH" "$DEFAULT_BRANCH"

echo ""

# ─── Package Manager & Runtime ────────────────────────────────────
echo "# --- Package Manager ---"

PACKAGE_MANAGER=""
RUNTIME=""
RUNTIME_VERSION=""

if [ -f "package.json" ]; then
  if [ -f "pnpm-lock.yaml" ]; then
    PACKAGE_MANAGER="pnpm"
  elif [ -f "yarn.lock" ]; then
    PACKAGE_MANAGER="yarn"
  else
    PACKAGE_MANAGER="npm"
  fi
  RUNTIME="node"
  RUNTIME_VERSION="$(node --version 2>/dev/null || echo 'unknown')"
elif [ -f "pyproject.toml" ] || [ -f "requirements.txt" ] || [ -f "setup.py" ]; then
  PACKAGE_MANAGER="pip"
  RUNTIME="python"
  RUNTIME_VERSION="$(python3 --version 2>/dev/null | awk '{print $2}' || echo 'unknown')"
elif [ -f "Cargo.toml" ]; then
  PACKAGE_MANAGER="cargo"
  RUNTIME="rust"
  RUNTIME_VERSION="$(rustc --version 2>/dev/null | awk '{print $2}' || echo 'unknown')"
elif [ -f "go.mod" ]; then
  PACKAGE_MANAGER="go"
  RUNTIME="go"
  RUNTIME_VERSION="$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//' || echo 'unknown')"
fi

emit "PACKAGE_MANAGER"         "$PACKAGE_MANAGER"
emit "RUNTIME"                 "$RUNTIME"
emit "RUNTIME_VERSION"         "$RUNTIME_VERSION"

echo ""

# ─── Build Commands ───────────────────────────────────────────────
echo "# --- Build Commands ---"

BUILD_CMD=""
TEST_CMD=""
LINT_CMD=""

case "$PACKAGE_MANAGER" in
  npm|yarn|pnpm)
    BUILD_CMD="$PACKAGE_MANAGER run build"
    # Prefer CI test script if it exists
    if node -e "require('./package.json').scripts['test:ci']" 2>/dev/null; then
      TEST_CMD="$PACKAGE_MANAGER run test:ci"
    else
      TEST_CMD="$PACKAGE_MANAGER test"
    fi
    LINT_CMD="$PACKAGE_MANAGER run lint"
    ;;
  pip)
    BUILD_CMD="python3 -m build"
    TEST_CMD="python3 -m pytest"
    LINT_CMD="ruff check ."
    ;;
  cargo)
    BUILD_CMD="cargo build --release"
    TEST_CMD="cargo test"
    LINT_CMD="cargo clippy"
    ;;
  go)
    BUILD_CMD="go build ./..."
    TEST_CMD="go test ./..."
    LINT_CMD="golangci-lint run"
    ;;
esac

emit "BUILD_CMD_ALL"   "$BUILD_CMD"
emit "TEST_CMD_ALL"    "$TEST_CMD"
emit "LINT_CHECK_CMD"  "$LINT_CMD"

echo ""

# ─── Directory Structure ──────────────────────────────────────────
echo "# --- Directory Structure ---"

# Top-level directories (excluding hidden and known-irrelevant)
TOP_DIRS="$(find . -maxdepth 1 -mindepth 1 -type d \
  ! -name '.*' \
  ! -name 'node_modules' \
  ! -name '__pycache__' \
  ! -name '.venv' \
  ! -name 'dist' \
  ! -name 'build' \
  ! -name 'target' \
  | sed 's|^\./||' | sort | head -20 | tr '\n' ',' | sed 's/,$//')"
emit "TOP_DIRS" "$TOP_DIRS"

echo ""

# ─── Formatter / Linter Detection ─────────────────────────────────
echo "# --- Formatter ---"

FORMATTER=""
if [ -f "biome.json" ] || [ -f "biome.jsonc" ]; then
  FORMATTER="biome"
elif [ -f ".eslintrc*" ] || [ -f "eslint.config*" ]; then
  FORMATTER="eslint"
elif [ -f ".prettierrc*" ] || [ -f "prettier.config*" ]; then
  FORMATTER="prettier"
elif [ -f "pyproject.toml" ] && grep -q 'ruff' pyproject.toml 2>/dev/null; then
  FORMATTER="ruff"
elif [ -f ".flake8" ] || grep -q 'black' pyproject.toml 2>/dev/null; then
  FORMATTER="black"
fi

emit "FORMATTER" "$FORMATTER"

echo ""
echo "# ─── End of discovery ───────────────────────────────────────"
