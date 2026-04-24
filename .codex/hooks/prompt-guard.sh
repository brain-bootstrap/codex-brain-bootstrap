#!/usr/bin/env bash
# prompt-guard.sh — UserPromptSubmit hook
# Scans user prompts for accidentally pasted secrets/API keys before they
# reach the model context. Blocks the prompt and warns the user if found.
#
# Exit 0 = allow the prompt through
# JSON {"decision":"block","reason":"..."} = reject prompt with message

set -euo pipefail

# Read the prompt from stdin (JSON provided by Codex)
INPUT="$(cat)"

# Extract the prompt text (fail gracefully if jq is absent)
if command -v jq &>/dev/null; then
  PROMPT="$(echo "$INPUT" | jq -r '.prompt // ""' 2>/dev/null)"
else
  # jq not available — skip guard, allow prompt through
  exit 0
fi

# Safety: if extraction failed, allow through
[ -z "$PROMPT" ] && exit 0

DETECTED=""

# Check for OpenAI-style API keys (sk-proj-... or sk-...)
if echo "$PROMPT" | grep -qE 'sk-proj-[A-Za-z0-9_-]{40,}'; then
  DETECTED="OpenAI project API key (sk-proj-...)"
elif echo "$PROMPT" | grep -qE 'sk-[A-Za-z0-9_-]{40,}'; then
  DETECTED="OpenAI API key (sk-...)"
# GitHub tokens
elif echo "$PROMPT" | grep -qE 'ghp_[A-Za-z0-9]{36}'; then
  DETECTED="GitHub personal access token (ghp_...)"
elif echo "$PROMPT" | grep -qE 'ghs_[A-Za-z0-9]{36}'; then
  DETECTED="GitHub Actions token (ghs_...)"
elif echo "$PROMPT" | grep -qE 'gho_[A-Za-z0-9]{36}'; then
  DETECTED="GitHub OAuth token (gho_...)"
# AWS
elif echo "$PROMPT" | grep -qE 'AKIA[0-9A-Z]{16}'; then
  DETECTED="AWS access key ID (AKIA...)"
# Google API keys
elif echo "$PROMPT" | grep -qE 'AIza[0-9A-Za-z_-]{35}'; then
  DETECTED="Google API key (AIza...)"
# PEM private keys
elif echo "$PROMPT" | grep -q 'BEGIN RSA PRIVATE KEY'; then
  DETECTED="RSA private key (PEM block)"
elif echo "$PROMPT" | grep -q 'BEGIN OPENSSH PRIVATE KEY'; then
  DETECTED="OpenSSH private key"
elif echo "$PROMPT" | grep -q 'BEGIN EC PRIVATE KEY'; then
  DETECTED="EC private key (PEM block)"
elif echo "$PROMPT" | grep -q 'BEGIN PRIVATE KEY'; then
  DETECTED="Private key (PEM block)"
# Anthropic API keys
elif echo "$PROMPT" | grep -qE 'sk-ant-[A-Za-z0-9_-]{40,}'; then
  DETECTED="Anthropic API key (sk-ant-...)"
fi

if [ -n "$DETECTED" ]; then
  jq -cn --arg reason "⚠️ Possible secret detected in prompt: $DETECTED. Remove the sensitive data and retry. Never share secrets in AI prompts." \
    '{"decision": "block", "reason": $reason}'
  exit 0
fi

# Clean — allow prompt through
exit 0
