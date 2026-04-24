---
name: cocoindex-code
description: Semantic vector search over the codebase — find code by meaning, not exact names. Use when you need to locate implementations without knowing exact function/class names. Triggers on "find code", "search codebase", "locate implementation", "what does X do".
---

# $cocoindex-code — Semantic Search

Finds code by meaning using local vector embeddings. No API key, works offline.

## When to Use This vs Other Tools

| Use cocoindex-code | Use serena instead |
|--------------------|-------------------|
| "find code that handles rate limiting" | "who calls `rateLimit()`?" |
| "locate authentication middleware" | "what does `AuthService` import?" |
| "find all error handling patterns" | "trace path from HTTP handler to DB" |
| Exploring unfamiliar codebase | Tracing known functions |
| Fuzzy conceptual search | Exact symbol traversal |

## The One Tool: `search`

```json
{
  "query": "string — natural language or code snippet",
  "limit": 5,
  "offset": 0,
  "refresh_index": true,
  "languages": ["python", "typescript"],
  "paths": ["src/auth/*"]
}
```

**After getting results:** Use the file tool on `file_path` at `start_line`–`end_line` for full context.

## Performance Tips

- Set `refresh_index: false` for consecutive searches in the same session (no code changes)
- Use `languages` filter to scope search (faster for single-language queries)
- Default limit is 5. Increase to 10–20 for broad exploration.

## Lifecycle

**Index not built yet:**

```bash
uvx cocoindex-code-mcp-server@latest --data-dir .codex/cocoindex --index
```

**After major changes:** Index auto-refreshes on each MCP search call (`refresh_index=true` default).

**Config in `.codex/config.toml`:**

```toml
[mcp_servers.cocoindex-code]
command = "uvx"
args = ["cocoindex-code-mcp-server@latest", "--data-dir", ".codex/cocoindex"]
```

## Supported Languages (29)

Python, JavaScript, TypeScript/TSX/JSX, Rust, Go, Java, C, C++, C#, SQL,
Shell/Bash, Markdown, PHP, Lua, Ruby, Swift, Kotlin, Scala, R, HTML, CSS/SCSS,
JSON, YAML/TOML, XML, Solidity, Pascal, Fortran, plain text.
