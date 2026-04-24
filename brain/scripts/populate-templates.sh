#!/usr/bin/env bash
# populate-templates.sh — Batch placeholder replacement for Codex Brain Bootstrap
# Replaces mechanical {{PLACEHOLDER}} values across template files in a single pass.
# Usage: bash brain/scripts/populate-templates.sh <discovery-env-file> [project-dir] [--dry-run]
# Exit: 0 on success, 1 on error

# ─── Source guard ─────────────────────────────────────────────────
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  echo "❌ populate-templates.sh must be EXECUTED, not sourced." >&2
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
  exit 1
fi

set -eo pipefail

DISCOVERY_FILE="${1:?Usage: populate-templates.sh <discovery-env-file> [project-dir] [--dry-run]}"
PROJECT_DIR="${2:-.}"
DRY_RUN=false
for arg in "$@"; do
  case "$arg" in --dry-run) DRY_RUN=true ;; esac
done

if [ ! -f "$DISCOVERY_FILE" ]; then
  echo "❌ Discovery file not found: $DISCOVERY_FILE"
  exit 1
fi

cd "$PROJECT_DIR"

# ─── Portable helpers ─────────────────────────────────────────────
source "$(dirname "$0")/_platform.sh"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Codex Brain Bootstrap — Populate Templates"
if $DRY_RUN; then echo "  ⚠️  DRY RUN — no files will be modified"; fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─── Parse discovery file ─────────────────────────────────────────
declare -A VALUES # portability-ok (bash 4+ enforced above via BASH_VERSINFO check)
while IFS= read -r line; do
  [[ "$line" =~ ^#.*$ ]] && continue
  [[ -z "$line" ]] && continue
  key="${line%%=*}"
  value="${line#*=}"
  key=$(echo "$key" | xargs)
  [ -z "$key" ] && continue
  VALUES["$key"]="$value"
done < "$DISCOVERY_FILE"

echo "📦 Loaded ${#VALUES[@]} discovery values"

# ─── Self-bootstrap protection ────────────────────────────────────
# Block if running on the template repo itself
IS_TEMPLATE=false
if [ -f "brain/scripts/populate-templates.sh" ] && \
   [ ! -f "package.json" ] && [ ! -f "Cargo.toml" ] && \
   [ ! -f "go.mod" ] && [ ! -f "pyproject.toml" ]; then
  # Could be template repo — check git remote
  if git remote -v 2>/dev/null | grep -q 'codex-brain-bootstrap'; then
    IS_TEMPLATE=true
  fi
fi

if $IS_TEMPLATE; then
  echo ""
  echo "🛑 SELF-BOOTSTRAP BLOCKED — This is the template repository!"
  echo "   Run this script in a target project, not in codex-brain-bootstrap itself."
  echo "   To force: add --force flag"
  exit 1
fi

# ─── Replacements ─────────────────────────────────────────────────
replace_in_file() {
  local file="$1" placeholder="$2" value="$3"
  if [ ! -f "$file" ]; then return; fi
  if ! grep -qF "{{${placeholder}}}" "$file" 2>/dev/null; then return; fi
  if $DRY_RUN; then
    echo "  [dry-run] Would replace {{${placeholder}}} in $file"
    return
  fi
  # Escape value for sed (forward slashes and &)
  local escaped_value
  escaped_value=$(echo "$value" | sed 's/[\/&]/\\&/g')
  sed_inplace "s|{{${placeholder}}}|${escaped_value}|g" "$file"
  echo "  ✅ Replaced {{${placeholder}}} in $file"
}

TARGET_FILES=(
  "AGENTS.md"
  "brain/architecture.md"
  "brain/build.md"
  "brain/cve-policy.md"
  "brain/decisions.md"
)

echo ""
echo "🔄 Applying replacements..."

for file in "${TARGET_FILES[@]}"; do
  replace_in_file "$file" "PROJECT_NAME"       "${VALUES[REPO_NAME]:-${VALUES[PROJECT_DIR_NAME]:-MyProject}}"
  replace_in_file "$file" "PACKAGE_MANAGER"    "${VALUES[PACKAGE_MANAGER]:-}"
  replace_in_file "$file" "RUNTIME"            "${VALUES[RUNTIME]:-}"
  replace_in_file "$file" "RUNTIME_VERSION"    "${VALUES[RUNTIME_VERSION]:-}"
  replace_in_file "$file" "BUILD_CMD_ALL"      "${VALUES[BUILD_CMD_ALL]:-}"
  replace_in_file "$file" "TEST_CMD_ALL"       "${VALUES[TEST_CMD_ALL]:-}"
  replace_in_file "$file" "LINT_CHECK_CMD"     "${VALUES[LINT_CHECK_CMD]:-}"
  replace_in_file "$file" "FORMATTER"          "${VALUES[FORMATTER]:-}"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Done. Run \`bash brain/scripts/validate.sh\` to verify."
echo ""
echo "  Remaining tasks for Codex to complete:"
echo "  1. Fill architecture.md — service map and data flow"
echo "  2. Fill build.md — any missing commands"
echo "  3. Use \$bootstrap to ask Codex to complete the setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
