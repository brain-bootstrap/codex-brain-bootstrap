# Codex Plugins & MCP Tools — Configuration & Reference

> **When to read:** Any task involving MCP tools, external integrations, plugin configuration, or semantic search.

## Overview

The bootstrap configures an **MCP tool stack** — each tool covers a distinct, non-overlapping axis of codebase intelligence. All tools are declared in `.codex/config.toml` under `[mcp_servers.*]`.

| Tool                    | Axis                                                                      | Invocation                     |
| ----------------------- | ------------------------------------------------------------------------- | ------------------------------ |
| **cocoindex-code**      | 🔎 Semantic search — find code by meaning (local vectors)                 | `$cocoindex-code` or describe  |
| **codebase-memory-mcp** | 🔍 Structural graph — call paths, blast radius, dead code, ADRs           | `$codebase-memory` or describe |
| **code-review-graph**   | 🔴 Change risk analysis — blast radius + risk score 0–100                 | `$code-review-graph` or pre-PR |
| **serena**              | 🔧 Symbol-level refactoring — LSP rename/move across all files atomically | `$serena` or describe rename   |
| **playwright**          | 🌐 Browser automation — navigate, click, snapshot via accessibility tree  | `$playwright` or describe UI   |

## Tool Details

---

### codebase-memory-mcp — Structural Graph

**Purpose:** Live structural graph of your codebase — trace call paths, detect blast radius, find dead code, query architecture. Zero-file-read analysis.

**When to use:**

- "What calls `AuthService.login()`?"
- "What does `process_payment()` call?"
- "Show me the full call chain from `apiHandler` to the DB"
- Understanding architecture before a big refactor

**Key tools:** `trace_path`, `detect_changes`, `get_architecture`, `search_graph`, `query_graph`, `list_flows`, `get_affected_flows`

**Config in `.codex/config.toml`:**

```toml
[mcp_servers.codebase-memory]
command = "codebase-memory-mcp"   # binary installed via install.sh
args = []
```

**Install:** `curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash` — auto-detects Codex and writes the MCP config.

**Token efficiency:** 120× fewer tokens than file exploration for structural questions.

See `$codebase-memory` skill for the full decision matrix.

---

### cocoindex-code — Semantic Search

**Purpose:** Find code by meaning, not exact names. Uses local vector embeddings — no API key required.

**When to use:**

- Looking for "where is rate limiting implemented?" (you don't know the function name)
- Finding all files that handle a concept (authentication, billing, etc.)
- Understanding how a business concept flows through the codebase

**Config in `.codex/config.toml`:**

```toml
[mcp_servers.cocoindex-code]
command = "uvx"
args = ["cocoindex-code-mcp-server@latest", "--data-dir", ".codex/cocoindex"]
```

**First run:** Index must be built. Run:

```bash
uvx cocoindex-code-mcp-server@latest --data-dir .codex/cocoindex --index
```

---

### code-review-graph — Change Risk Analysis

**Purpose:** Pre-PR safety gate. Detects blast radius, risk score (0–100), and breaking changes from a git diff.

**When to use:**

- Before opening any PR
- After a refactor that touched shared code
- When you need to know "what else could break?"

**Config in `.codex/config.toml`:**

```toml
[mcp_servers.code-review-graph]
command = "uvx"
args = ["code-review-graph@latest"]
```

**Risk score interpretation:**

- 0–30: Low risk — proceed
- 31–60: Medium risk — review carefully
- 61–100: High risk — expand test coverage before merging

---

### serena — Symbol-Level Refactoring

**Purpose:** LSP-backed atomic rename/move across the entire codebase. Zero manual grep needed.

**When to use:**

- Renaming a function, class, or variable used in 10+ files
- Moving a module to a different directory
- Finding all callers of a function before deleting it

**Config in `.codex/config.toml`:**

```toml
[mcp_servers.serena]
command = "uvx"
args = ["serena@latest"]
```

**Key operations:**

- `rename_symbol` — rename across all files, atomically
- `move_symbol` — move to different module
- `find_references` — all callers of a function

---

### playwright — Browser Automation

**Purpose:** Navigate, interact with, and snapshot web pages via accessibility tree (no screenshots needed).

**When to use:**

- Testing web UIs interactively
- Scraping or extracting content from a running app
- Verifying that a UI change looks correct

**Config in `.codex/config.toml`:**

```toml
[mcp_servers.playwright]
command = "npx"
args = ["@playwright/mcp@latest"]
```

---

## Complete Coverage Map

```
Question / Task                               Tool
──────────────────────────────────────────────────────────────────
"Find code related to rate limiting"          cocoindex-code        ← semantic meaning
"Who calls AuthService.login()?"              codebase-memory-mcp   ← structural graph
"What does process_payment() call?"           codebase-memory-mcp   ← call trace
"Is this PR safe to ship?"                    code-review-graph     ← blast radius + risk
"Rename AuthService.login everywhere"         serena                ← LSP atomic rename
"Find all callers of process_payment()"       serena                ← LSP references
"Test this login form"                        playwright            ← browser UI
"Scrape this documentation page"              playwright            ← browser navigation
```

## Enabling / Disabling Tools

Uncomment/comment the relevant section in `.codex/config.toml`.
Tools that are not configured will not be invoked.

### Additional per-server config options

```toml
[mcp_servers.example]
command = "uvx"
args = ["example-mcp@latest"]
startup_timeout_sec = 10      # seconds to start (default: 10)
tool_timeout_sec = 60         # seconds per tool call (default: 60)
enabled = true                # set false to disable without deleting config
required = false              # set true to fail startup if server can't init
enabled_tools = ["search"]    # tool allow list (omit = all tools)
disabled_tools = ["delete"]   # tool deny list (applied after enabled_tools)
env_vars = ["MY_TOKEN"]       # forward these env vars to the server process
```

**CLI alternative:** `codex mcp add <server-name> -- <command>` adds a STDIO server via the Codex CLI without editing config.toml manually. `codex mcp login <server-name>` handles OAuth for HTTP servers that require it.
