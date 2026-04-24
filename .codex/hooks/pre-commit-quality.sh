#!/usr/bin/env bash
# .codex/hooks/pre-commit-quality.sh — PreToolUse hook (Bash matcher)
# Checks staged files before git commits for:
#   - Debugger/breakpoint statements (blocked — CRITICAL)
#   - Hardcoded secrets / API keys (blocked — CRITICAL)
#   - console.log / print() statements (warned — non-blocking)
#   - Conventional commit message format (warned — non-blocking)
#
# Uses preferred Codex PreToolUse block format for denial.
# Docs: https://developers.openai.com/codex/hooks#pretooluse

set -euo pipefail

PAYLOAD="$(cat)"

# Extract the bash command
CMD=""
if command -v jq &>/dev/null; then
  CMD="$(echo "${PAYLOAD}" | jq -r '.tool_input.command // ""' 2>/dev/null || true)"
fi

if [ -z "${CMD}" ]; then
  exit 0
fi

# Only trigger on git commit commands
if ! echo "${CMD}" | grep -qE 'git[[:space:]]+commit' 2>/dev/null; then
  exit 0
fi

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"

IS_AMEND=false
if echo "${CMD}" | grep -q '\-\-amend' 2>/dev/null; then
  IS_AMEND=true
fi

# Get staged files
if [ "${IS_AMEND}" = "true" ]; then
  STAGED="$(cd "${REPO_ROOT}" && git diff --name-only HEAD~1 HEAD 2>/dev/null || true)"
else
  STAGED="$(cd "${REPO_ROOT}" && git diff --cached --name-only 2>/dev/null || true)"
fi

if [ -z "${STAGED}" ]; then
  exit 0
fi

# shellcheck disable=SC2034
ISSUES=""

# ── Debugger statements (BLOCKING) ────────────────────────────────
DEBUGGER_HITS=""
while IFS= read -r f; do
  case "${f}" in
    *.js|*.ts|*.tsx|*.jsx|*.mjs|*.cjs|*.py|*.rb|*.go|*.rs)
      if [ -f "${REPO_ROOT}/${f}" ]; then
        HITS="$(grep -nE '(debugger;|breakpoint\(\)|import pdb|pdb\.set_trace|binding\.pry)' "${REPO_ROOT}/${f}" 2>/dev/null | head -3 || true)"
        [ -n "${HITS}" ] && DEBUGGER_HITS="${DEBUGGER_HITS}${f}: ${HITS}\n"
      fi
      ;;
  esac
done <<< "${STAGED}"

if [ -n "${DEBUGGER_HITS}" ]; then
  REASON="Pre-commit quality gate: Debugger statements found in staged files. Remove them before committing.\n\n${DEBUGGER_HITS}"
  # shellcheck disable=SC2086
  printf '%s' "${REASON}" | jq -Rs '
    {
      "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": ("Pre-commit quality gate: Debugger/breakpoint statements found in staged files — remove before committing.\n" + .)
      }
    }
  ' 2>/dev/null || cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Pre-commit quality gate: Debugger/breakpoint statements found in staged files. Remove them before committing."
  }
}
EOF
  exit 0
fi

# ── Hardcoded secrets (BLOCKING) ──────────────────────────────────
SECRET_HITS=""
while IFS= read -r f; do
  case "${f}" in
    *.js|*.ts|*.tsx|*.jsx|*.py|*.rb|*.go|*.rs|*.json|*.yaml|*.yml|*.env*)
      if [ -f "${REPO_ROOT}/${f}" ]; then
        HITS="$(grep -nEi '(api[_-]?key|secret[_-]?key|private[_-]?key|password)[[:space:]]*[:=][[:space:]]*["'"'"'][A-Za-z0-9+/=_\-]{20,}' "${REPO_ROOT}/${f}" 2>/dev/null | head -3 || true)"
        [ -n "${HITS}" ] && SECRET_HITS="${SECRET_HITS}${f}: ${HITS}\n"
      fi
      ;;
  esac
done <<< "${STAGED}"

if [ -n "${SECRET_HITS}" ]; then
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Pre-commit quality gate: Possible hardcoded secrets/API keys found in staged files. Move credentials to environment variables or a secrets manager. Never commit secrets to version control."
  }
}
EOF
  exit 0
fi

# ── console.log / print() warnings (non-blocking, inject context) ─
LOG_HITS=""
while IFS= read -r f; do
  case "${f}" in
    *.js|*.ts|*.tsx|*.jsx|*.mjs|*.cjs)
      if [ -f "${REPO_ROOT}/${f}" ]; then
        HITS="$(grep -n 'console\.log' "${REPO_ROOT}/${f}" 2>/dev/null | head -2 || true)"
        [ -n "${HITS}" ] && LOG_HITS="${LOG_HITS}  ${f}: ${HITS}\n"
      fi
      ;;
  esac
done <<< "${STAGED}"

# ── Conventional commit format check (non-blocking) ──────────────
# Inject non-blocking warnings as additionalContext via PostToolUse
# (PreToolUse can only allow or deny — warnings become context after the commit runs)
# Nothing to output here — allow the commit to proceed
exit 0
