---
name: code-review-graph
description: Change risk analysis — detect blast radius, risk score, and breaking changes from git diffs. Use before any PR or merge. Triggers on "review PR", "check impact", "blast radius", "what breaks", "safe to merge".
---

# $code-review-graph — Change Risk Analysis

Structural change safety gate. Builds an AST graph from source code, then on any diff computes:
- **Risk score** (0–100)
- **Blast radius** — all transitively affected nodes (100% recall)
- **Breaking changes** — nodes whose signature changed
- **Impacted flows** — execution paths traversing changed nodes

## Quick Decision Matrix

| Question | Tool |
|----------|------|
| Is this change safe to ship? | `detect_changes_tool(base_branch="main")` |
| Build/rebuild the graph | `build_graph_tool(repo_path=".")` |
| Graph status + stats | `get_graph_info_tool` |
| What changed vs main? | `get_diff_tool(base_branch="main")` |
| Node details | `get_node_tool(node_id="<id>")` |
| Node neighbors | `get_neighbors_tool(node_id="<id>", depth=2)` |
| Find by name | `search_nodes_tool(query="AuthService")` |
| Community structure | `get_communities_tool` |
| Critical path | `get_critical_path_tool(source="<id>", target="<id>")` |
| Dependency chain | `get_dependency_chain_tool(node_id="<id>")` |

## Mandatory Pre-PR Workflow

1. `build_graph_tool(repo_path=".")` — first run only (or after major refactor)
2. `detect_changes_tool(base_branch="main")` — risk score + blast radius
3. If risk score ≥ 60 → `get_dependency_chain_tool` on the highest-risk node
4. If impacted flows present → review them with `get_neighbors_tool`
5. Fix or document risks before merging

## Risk Score Interpretation

| Score | Meaning | Action |
|-------|---------|--------|
| 0–25 | Low risk | Review and ship |
| 26–50 | Moderate | Verify blast radius manually |
| 51–75 | High | Write tests for affected nodes |
| 76–100 | Critical | Full review + stakeholder sign-off |

## Lifecycle

**First build:** `build_graph_tool(repo_path=".")` — ~6s for 500 files, ~30s for large repos.

**After major refactor:** `build_graph_tool(repo_path=".", force_rebuild=True)`.

**Config in `.codex/config.toml`:**

```toml
[mcp_servers.code-review-graph]
command = "uvx"
args = ["code-review-graph@latest"]
```

## Key Gotchas

- **Build first:** MCP server exits if graph DB doesn't exist — run `build_graph_tool` before first use
- **uvx required:** needs uv installed (`pip install uv` or `brew install uv`)
- **Score is aggregate:** individual nodes in blast radius may be critical even at score 30 — check the breakdown
- **After git rebase/reset:** run `build_graph_tool(force_rebuild=True)` if graph seems stale
