---
name: codebase-memory
description: Use when you need structural graph navigation — trace call paths, detect blast radius, find dead code, or query architecture — before reading files. Structural queries only: not for semantic meaning (use cocoindex-code for that).
---

# $codebase-memory — Structural Graph Navigation

Zero-file-read structural analysis via `codebase-memory-mcp`. Always try these tools BEFORE reading files for structural questions.

**Not for semantic search** (use `$cocoindex-code`). Not for rename/refactor (use `$serena`).

## Quick Decision Matrix

| Question | Tool |
|----------|------|
| What calls `foo()`? | `trace_path(function_name="foo", direction="inbound")` |
| What does `foo()` call? | `trace_path(function_name="foo", direction="outbound")` |
| Full call chain | `trace_path(direction="both", depth=3)` |
| Impact of my change | `detect_changes(base_branch="main")` |
| Architecture overview | `get_architecture` |
| Find by name/pattern | `search_graph(name_pattern="Auth.*")` |
| Dead code | `search_graph(max_degree=0, label="Function")` |
| Custom Cypher query | `query_graph(query="MATCH (n:Function)-[:CALLS]->(m) RETURN n.name LIMIT 20")` |
| Execution flows | `list_flows` → `get_affected_flows` |

## First Use

```bash
# Index the repository (one-time setup, ~6s for 500 files)
index_repository(repo_path=".")
# Verify
list_projects
# View architecture map
get_architecture
```

## Config in `.codex/config.toml`

```toml
[mcp_servers.codebase-memory]
command = "uvx"
args = ["codebase-memory-mcp@latest", "--data-dir", ".codex/codebase-memory"]
```

Or if using the binary release directly:

```toml
[mcp_servers.codebase-memory]
command = "codebase-memory-mcp"
args = []
```

## Workflow — Before Reviewing Changes

```
1. detect_changes(base_branch="main")    → risk score + blast radius
2. get_affected_flows                    → which execution paths break
3. trace_path on highest-risk functions  → full call chain context
```

## Workflow — Codebase Exploration

```
1. get_architecture    → community map, entry points, god nodes
2. search_graph(name_pattern="<keyword>")  → find relevant nodes
3. trace_path          → traverse from found nodes
4. get_code_snippet(qualified_name="<name>")  → source with context
```

## Known Gotchas

1. `trace_path` requires **exact** qualified names — use `search_graph(name_pattern=...)` first to find them
2. Results default to 10 per page — check `has_more` and paginate with `offset`
3. `query_graph` has a 200-row cap — use `search_graph` with degree filters for counts
4. `direction="outbound"` misses cross-service callers — use `direction="both"` to see all
5. Index is not always auto-updated — run `index_repository(mode="fast")` for immediate refresh

## Token Efficiency

**120× fewer tokens** than file exploration for structural questions. A call chain that would require reading 15 files can be answered in 1-2 MCP calls.
