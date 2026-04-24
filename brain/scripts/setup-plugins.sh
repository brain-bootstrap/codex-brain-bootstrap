#!/usr/bin/env bash
# setup-plugins.sh — MCP plugin installer for Codex Brain Bootstrap
# Installs the optional MCP tools: cocoindex, code-review-graph, serena, playwright
# Usage: bash brain/scripts/setup-plugins.sh [--all] [--cocoindex] [--review-graph] [--serena] [--playwright]
# Exit: 0 on success, 1 on failure

# ─── Source guard ─────────────────────────────────────────────────
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  echo "❌ setup-plugins.sh must be EXECUTED, not sourced." >&2
  return 1 2>/dev/null || exit 1
fi

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_platform.sh"

INSTALL_ALL=false
INSTALL_COCOINDEX=false
INSTALL_REVIEW_GRAPH=false
INSTALL_SERENA=false
INSTALL_PLAYWRIGHT=false

for arg in "$@"; do
  case "$arg" in
    --all)           INSTALL_ALL=true ;;
    --cocoindex)     INSTALL_COCOINDEX=true ;;
    --review-graph)  INSTALL_REVIEW_GRAPH=true ;;
    --serena)        INSTALL_SERENA=true ;;
    --playwright)    INSTALL_PLAYWRIGHT=true ;;
  esac
done

# Default to interactive selection if no flags provided
if ! $INSTALL_ALL && ! $INSTALL_COCOINDEX && ! $INSTALL_REVIEW_GRAPH && ! $INSTALL_SERENA && ! $INSTALL_PLAYWRIGHT; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Codex Brain Bootstrap  ·  Plugin Setup"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Usage: bash brain/scripts/setup-plugins.sh [flags]"
  echo ""
  echo "  --all           Install all available plugins"
  echo "  --cocoindex     Semantic code search (Python 3.11+)"
  echo "  --review-graph  Change risk analysis (Python 3.10+)"
  echo "  --serena        Symbol-level refactoring (Python 3.11+)"
  echo "  --playwright    Browser automation (Node.js 18+)"
  echo ""
  exit 0
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Codex Brain Bootstrap  ·  Plugin Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ─── Helper ───────────────────────────────────────────────────────
check_python() {
  local min_minor="$1"
  python3 -c "import sys; exit(0 if sys.version_info >= (3, $min_minor) else 1)" 2>/dev/null
}

# ─── cocoindex ────────────────────────────────────────────────────
if $INSTALL_ALL || $INSTALL_COCOINDEX; then
  echo "🔎 Installing cocoindex-code (semantic search)..."
  if check_python 11; then
    if command -v uvx &>/dev/null; then
      uvx cocoindex-code-mcp-server@latest --version 2>/dev/null && \
        echo "  ✅ cocoindex-code available via uvx" || \
        echo "  ⚠️  uvx found but cocoindex-code-mcp-server not yet cached (will be fetched on first use)"
    else
      echo "  ❌ uvx not found — install with: pip install uv"
    fi
  else
    echo "  ⚠️  Python 3.11+ required — skipping cocoindex"
  fi
  echo ""
fi

# ─── code-review-graph ────────────────────────────────────────────
if $INSTALL_ALL || $INSTALL_REVIEW_GRAPH; then
  echo "🔴 Installing code-review-graph (change risk analysis)..."
  if check_python 10; then
    if command -v uvx &>/dev/null; then
      uvx code-review-graph@latest --version 2>/dev/null && \
        echo "  ✅ code-review-graph available via uvx" || \
        echo "  ⚠️  uvx found but code-review-graph not yet cached (will be fetched on first use)"
    else
      echo "  ❌ uvx not found — install with: pip install uv"
    fi
  else
    echo "  ⚠️  Python 3.10+ required — skipping code-review-graph"
  fi
  echo ""
fi

# ─── serena ───────────────────────────────────────────────────────
if $INSTALL_ALL || $INSTALL_SERENA; then
  echo "🔧 Installing serena (symbol-level refactoring)..."
  if check_python 11; then
    if command -v uvx &>/dev/null; then
      uvx serena@latest --version 2>/dev/null && \
        echo "  ✅ serena available via uvx" || \
        echo "  ⚠️  uvx found but serena not yet cached (will be fetched on first use)"
    else
      echo "  ❌ uvx not found — install with: pip install uv"
    fi
  else
    echo "  ⚠️  Python 3.11+ required — skipping serena"
  fi
  echo ""
fi

# ─── playwright ───────────────────────────────────────────────────
if $INSTALL_ALL || $INSTALL_PLAYWRIGHT; then
  echo "🌐 Installing playwright MCP (browser automation)..."
  if command -v node &>/dev/null && node -e "process.exit(parseInt(process.version.split('.')[0].slice(1)) >= 18 ? 0 : 1)" 2>/dev/null; then
    if command -v npx &>/dev/null; then
      echo "  ✅ playwright MCP available via npx @playwright/mcp@latest"
      # Pre-install browsers if playwright is not yet installed
      if ! npx playwright --version 2>/dev/null | grep -q 'Version'; then
        echo "  📦 First-time install — this may take a moment..."
        npx playwright install chromium 2>&1 | tail -5 || true
      fi
    else
      echo "  ❌ npx not found — install Node.js 18+"
    fi
  else
    echo "  ⚠️  Node.js 18+ required — skipping playwright"
  fi
  echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Plugin setup complete."
echo ""
echo "  Next: uncomment the relevant [mcp_servers.*] sections"
echo "  in .codex/config.toml to activate the tools."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
