#!/usr/bin/env bash
# .codex/hooks/permission-audit.sh — PermissionRequest hook
# Logs every permission escalation request to brain/tasks/.permission-denials.log.
# Does NOT approve or deny — preserves normal Codex approval flow.
# Exit: always 0 (logging only, never blocks the request)
# Docs: https://developers.openai.com/codex/hooks#permissionrequest

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"
LOG_DIR="${REPO_ROOT}/brain/tasks"
LOG_FILE="${LOG_DIR}/.permission-audit.log"

mkdir -p "${LOG_DIR}"

PAYLOAD="$(cat)"

# Extract fields for audit log
TOOL_NAME="unknown"
COMMAND=""
DESCRIPTION=""
if command -v jq &>/dev/null; then
  TOOL_NAME="$(echo "${PAYLOAD}" | jq -r '.tool_name // "unknown"' 2>/dev/null || echo "unknown")"
  COMMAND="$(echo "${PAYLOAD}" | jq -r '.tool_input.command // ""' 2>/dev/null | head -c 200 || true)"
  DESCRIPTION="$(echo "${PAYLOAD}" | jq -r '.tool_input.description // ""' 2>/dev/null | head -c 100 || true)"
fi

TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
printf '%s | tool=%s | cmd=%s | desc=%s\n' \
  "${TIMESTAMP}" "${TOOL_NAME}" "${COMMAND}" "${DESCRIPTION}" \
  >> "${LOG_FILE}" 2>/dev/null || true

# Return nothing — preserves normal Codex approval flow
exit 0
