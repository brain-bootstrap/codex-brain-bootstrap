---
name: serena
description: Use when renaming symbols across files, finding all references to a function/class, moving code between files, or inlining variables — LSP-backed atomic multi-file refactoring. Zero manual grep needed.
---

# $serena — LSP-Backed Symbol Refactoring

**Core principle:** Type-aware, 100% recall. Grep finds strings; Serena finds symbols — including aliased imports, dynamic usages, and type-renamed references.

## Decision Matrix

| Question | Use |
|----------|-----|
| "Rename `AuthService` everywhere" | serena — `rename_symbol` |
| "Find all callers of `login()`" | serena — `find_references` |
| "Move `UserMapper` to another file" | serena — `move_symbol` |
| "Inline the `MAX_RETRIES` constant" | serena — `inline_symbol` |
| "Find code about rate limiting" | cocoindex-code — semantic meaning |
| "Is renaming this safe to ship?" | code-review-graph — blast radius |

## Key Tools

```
find_symbol(name, type?)         — find by name/type (LSP, not grep)
find_references(symbol)          — all usages across the project
get_symbol_info(symbol)          — signature, docstring, defined-in, refs
rename_symbol(symbol, new_name)  — rename everywhere atomically
move_symbol(symbol, target_file) — move + fix all imports
replace_symbol_body(symbol, body) — replace impl, keep signature
inline_symbol(symbol)            — inline at all call sites
get_call_graph(symbol)           — call graph from a symbol
```

## Standard Workflows

**Rename across codebase:**

```
1. find_symbol("OldName")         → confirm it's the right symbol
2. find_references("OldName")     → verify scope
3. rename_symbol("OldName", "NewName")  → atomic rename
```

**Move a class to another file:**

```
1. get_symbol_info("MyClass")  → see current location and imports
2. move_symbol("MyClass", "src/new_module.py")
```

**Find all callers before deleting:**

```
1. find_references("legacyFunction")  → if empty, safe to delete
```

## Project Config

`.serena/project.yml` (committed to repo) controls which language servers are active:

```yaml
languages:
  - python
  - typescript
  - javascript
```

Language servers are auto-installed by serena on first use (pyright, typescript-language-server).

## Config in `.codex/config.toml`

```toml
[mcp_servers.serena]
command = "uvx"
args = ["serena@latest"]
```

## Token Cost

Low — on-demand per MCP call. No background indexing. LSP server initializes on first call (~2-3s), then fast.

## When NOT to Use

- Semantic search (you don't know exact names) → `cocoindex-code`
- Simple literal string search → use grep
- Change risk / blast radius → `code-review-graph`
