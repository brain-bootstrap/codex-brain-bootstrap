---
name: health
description: Verify Codex configuration health — AGENTS.md, hooks, config.toml, agents, skills, secrets scan, and MCP reachability. Reports ✅/⚠️/❌ for each check.
---

# Health Skill — Codex Configuration Validation

Verify that the Codex Brain configuration is healthy and complete.

## Steps

### 1. AGENTS.md
- Exists and is not empty
- Line count: `wc -l < AGENTS.md`
- Size: `wc -c < AGENTS.md` (budget: ≤32KB = 32768 bytes)
- Contains key sections: Skills Roster, Exit Checklist, Terminal Rules

### 2. config.toml
- `.codex/config.toml` exists and is valid TOML
- Has `#:schema` directive on first line
- Has `codex_hooks = true` under `[features]`

### 3. hooks.json
- `.codex/hooks.json` exists and is valid JSON: `jq . .codex/hooks.json`
- Hook count: `jq '[.. | objects | select(has("command"))] | length' .codex/hooks.json`

### 4. Hook Scripts
- All `.codex/hooks/*.sh` files exist and are executable:
  ```bash
  for h in .codex/hooks/*.sh; do test -x "$h" || echo "NOT_EXEC: $h"; done
  ```

### 5. Subagents
- All `.codex/agents/*.toml` files exist
- Each has `name`, `description`, `developer_instructions` fields:
  ```bash
  for f in .codex/agents/*.toml; do grep -q 'developer_instructions' "$f" || echo "INCOMPLETE: $f"; done
  ```

### 6. Skills
- All `.agents/skills/*/SKILL.md` files exist
- Each has `name:` and `description:` in frontmatter:
  ```bash
  for f in .agents/skills/*/SKILL.md; do grep -q '^name:' "$f" || echo "BAD FRONTMATTER: $f"; done
  ```

### 7. Error Log
- `brain/tasks/CODEX_ERRORS.md` exists (warn if missing)

### 8. Secrets Scan
```bash
git ls-files | xargs grep -l 'BEGIN.*PRIVATE KEY\|password\s*=\s*[^{][^"\x27]\{8,\}' 2>/dev/null | head -10
```
Report any matches as ⚠️ warnings.

### 9. MCP Tool Reachability
Check that the required runtimes are available (all MCP tools run via `uvx` or `npx`):
```bash
command -v uvx &>/dev/null && echo "uvx: ✅" || echo "uvx: ❌ missing — install via: pip install uv"
command -v npx &>/dev/null && echo "npx: ✅" || echo "npx: ⚠️ missing — install Node.js (for playwright)"
command -v ccc &>/dev/null && echo "cocoindex CLI (ccc): ✅" || echo "cocoindex CLI (ccc): ⚠️ optional — install via: pip install cocoindex"
# uvx-based: codebase-memory-mcp, code-review-graph, serena, cocoindex-code-mcp-server (available when uvx installed)
```

## Report Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Codex Health — <repo>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  AGENTS.md budget         ✅ 187 lines / 4.2KB (budget: 32KB)
  config.toml              ✅ valid + schema directive
  hooks.json               ✅ valid JSON, 9 hooks registered
  Hook scripts             ✅ 9/9 executable
  Subagents                ✅ 5/5 complete
  Skills                   ✅ 30/30 have valid frontmatter
  Error log                ✅ CODEX_ERRORS.md exists
  Secrets scan             ✅ no leaks detected
  codebase-memory-mcp      ⚠️ missing — run setup-plugins.sh
  cocoindex (ccc)          ✅ installed
  code-review-graph        ✅ installed
  uvx (playwright/serena)  ✅ installed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Overall: ⚠️ healthy with 1 warning
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After the table, list any ⚠️/❌ items with one-line fix instructions.
