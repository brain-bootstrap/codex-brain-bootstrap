---
name: playwright
description: Browser automation — navigate, click, fill, snapshot web pages. Use for UI testing, documentation scraping, OAuth flows, web research. Always snapshot first, screenshot never (unless required).
---

# $playwright — Browser Automation

**Use when:** you need to interact with a web page — test a UI, scrape docs, verify a login flow, research a live API.

**Token cost:** 🟡 LOW-MEDIUM — accessibility snapshots are structured text (no pixel cost); large pages produce verbose trees.

## Decision Matrix

| Task | Use |
|------|-----|
| "Test this login form end-to-end" | playwright |
| "Scrape this documentation page" | playwright |
| "Verify OAuth redirect works" | playwright |
| "Find code about auth" | cocoindex-code |
| "Rename AuthService everywhere" | serena |

## Core Tools

```
browser_navigate(url)           — go to URL
browser_snapshot()              — accessibility tree (PREFER over screenshot)
browser_click(element, ref)     — click by accessibility label
browser_fill(element, ref, val) — fill an input
browser_screenshot()            — visual capture (only when structure is insufficient)
browser_evaluate(script)        — run JS in page context
browser_wait_for_url(url)       — wait for navigation
browser_close()                 — clean up when done
```

## Standard Workflow — Snapshot First, Screenshot Never (Unless Needed)

```
1. browser_navigate(url)
2. browser_snapshot()              ← read the accessibility tree
3. browser_click / browser_fill    ← interact by element label or ref
4. browser_snapshot()              ← verify the new state
5. browser_close()                 ← always clean up
```

**Never use `browser_screenshot` as the first action** — accessibility snapshots give the same structural information at a fraction of the token cost.

## Token Efficiency Tips

- `browser_snapshot` returns a structured accessibility tree — use `element` labels for clicking/filling
- Prefer `browser_evaluate` for data extraction over reading the full snapshot repeatedly
- Always `browser_close` when done — open tabs accumulate context

## Config in `.codex/config.toml`

```toml
[mcp_servers.playwright]
command = "npx"
args = ["@playwright/mcp@latest"]
```

## Manual Browser Install (if needed)

```bash
# Pre-install Chromium (avoids delay on first use)
npx playwright install chromium

# Linux CI — with system dependencies
npx playwright install chromium --with-deps
```

The MCP server (`npx @playwright/mcp@latest`) lazy-installs on first invocation — no manual setup required if Chromium is already installed.
