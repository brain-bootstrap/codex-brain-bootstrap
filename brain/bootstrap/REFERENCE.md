# Bootstrap Reference — Report Templates

> **Read by Codex in bootstrap Phase 5 only.** Contains report templates for FRESH INSTALL and UPGRADE.
> Keeping this separate from `brain/bootstrap/PROMPT.md` prevents these lines from occupying context during phases 1-4.

---

## Template: FRESH INSTALL

```markdown
# 🎉 Bootstrap Complete — [PROJECT_NAME]

> Codex Brain Bootstrap — Your AI coding assistant just learned everything about your codebase.
> Generated [date] · **Mode: Fresh Install** · ⏱️ Completed in ~[N] minutes

---

## ✅ Configuration Health — All Systems Go

- **validate.sh** → ✅ **[N] passed**, 0 failed
- **Remaining placeholders** → ✅ 0
- **Hooks executable** → ✅ [N]/9
- **config.toml** → ✅ Valid TOML with schema directive
- **AGENTS.md size** → ✅ [N] lines (budget: ≤800 lines / 32KB)
- **Skills** → ✅ 48 skills registered
- **Subagents** → ✅ 5 agents registered

## 🔍 What Brain Learned About Your Stack

- 🗣️ **Language(s)** → [list with file counts]
- 📦 **Package Manager** → [name + version]
- 🏗️ **Frameworks** → [list]
- 🎨 **Formatter/Linter** → [name]
- 🧪 **Test Framework** → [name]
- 📐 **Architecture** → [monorepo/single-app/dual-tier]
- ⚙️ **CI** → [name]
- 🗄️ **Database** → [name or N/A]
- 🔌 **MCP Tools** → cocoindex, codebase-memory-mcp, code-review-graph, serena, playwright (see `brain/plugins.md` for install commands)

## 📁 What Was Installed

- **AGENTS.md** — Core brain, auto-loaded by Codex every session
- **9 lifecycle hooks** — session start, config protection, terminal safety, pre-commit quality gate, permission audit, post-bash review, TDD loop check, exit nudge, warn-missing-test (strict profile)
- **5 AI subagents** — explorer, reviewer (10-point review), plan-challenger (adversarial critique), session-reviewer (pattern detection), security-auditor (vulnerability scanning)
- **48 skills** — ask, bootstrap, brainstorming, build, careful, changelog, checkpoint, clean-worktrees, cleanup, codebase-memory, cocoindex-code, code-review-graph, context, cross-layer-check, db, debug, deps, diff, docker, git, health, issue-triage, lint, maintain, mcp, migrate, mr, plan, playwright, pr-triage, receiving-code-review, repo-recap, research, resume, review, root-cause-trace, serve, serena, squad-plan, status, subagent-driven-development, tdd, ticket, update-code-index, worktree, worktree-status, writing-skills
- **Brain knowledge layer** — architecture.md, build.md, rules.md, terminal-safety.md, templates.md, plugins.md, cve-policy.md, decisions.md
- **Starlark approval rules** — .codex/rules/default.rules

## 🧠 Project-Specific Patterns Captured

[List 3-5 critical safety rules discovered from the codebase, e.g.:]

- [Pattern 1 — e.g., "Never block event loop with I/O"]
- [Pattern 2 — e.g., "Config is load-once — changes require restart"]
- [Pattern 3]

## � MCP Suggestions (based on your stack)

[Fill from Phase 4.5 scan — only include if relevant:]

- [e.g., "postgres MCP — DATABASE detected → uvx postgres@latest"]
- [e.g., "github MCP — CI_SYSTEM=github-actions detected → uvx github@latest"]
- [e.g., "filesystem MCP — Docker/Kubernetes detected → uvx filesystem@latest"]

→ Browse all: [registry.smithery.ai](https://registry.smithery.ai)

## �🔌 MCP Tool Status
```

🔎 cocoindex-code — [CONFIGURED/NOT CONFIGURED]
Semantic search — find code by meaning (local vectors, no API key)
→ Install: uvx cocoindex-code-mcp-server@latest --data-dir .codex/cocoindex --index

🔍 codebase-memory-mcp — [CONFIGURED/NOT CONFIGURED]
Structural graph — trace call paths, blast radius, dead code (120× fewer tokens)
→ Install: curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash

🔴 code-review-graph — [CONFIGURED/NOT CONFIGURED]
Pre-PR blast radius + risk score 0-100
→ Install: uvx code-review-graph@latest

🔧 serena — [CONFIGURED/NOT CONFIGURED]
LSP-backed atomic symbol rename across entire codebase
→ Install: uvx serena@latest

🌐 playwright — [CONFIGURED/NOT CONFIGURED]
Browser automation via accessibility tree
→ Install: npx @playwright/mcp@latest

```

## 🤝 Collaboration Mode

**TEAM** (default) — config is committed, shared with the team.
→ Switch to SOLO (personal, not committed): `echo -e '\nAGENTS.md\n.codex/\n.agents/\nbrain/\n.codexignore' >> .gitignore`

## 🎯 What's Next — Get Productive in 60 Seconds

1. 💾 **Commit the brain**: `git add AGENTS.md .codexignore .codex/ .agents/ brain/`
2. 👀 **Review** `brain/architecture.md` — adjust as you explore deeper
3. 🧪 **Try it** — start a Codex session and run `$build`, `$test`, `$lint`
4. 📚 **Grow the brain** — add domain docs as you work: `brain/<domain>.md`
5. 🔄 **Future upgrades**: clone codex-brain-bootstrap into /tmp, run `install.sh .`, then `$bootstrap`

---

> 💡 **Pro tip:** Every correction you make gets captured in `brain/tasks/lessons.md`. The brain literally cannot make the same mistake twice.

⏱️ **Phase timing (AI-work):** P1 [time] · P2 skipped (FRESH) · P3 [time] · P4 [time] · P4.5 [time] · P5 [time]
⏱️ **Wall-clock total:** ~[N] minutes
```

---

## Template: UPGRADE

```markdown
# 🔄 Configuration Upgraded — [PROJECT_NAME]

> Codex Brain Bootstrap — Your Brain just got smarter. New capabilities installed, all your knowledge preserved.
> Generated [date] · **Mode: Smart Upgrade** · ⏱️ Completed in ~[N] minutes

---

## ✅ Configuration Health — All Systems Go

- **validate.sh** → ✅ **[N] passed**, 0 failed
- **Remaining placeholders** → ✅ 0
- **AGENTS.md size** → ✅ [N] lines (budget: ≤800 lines / 32KB)
- **Hooks** → ✅ [N] registered
- **Skills** → ✅ [N] registered
- **Starlark rules** → ✅ `.codex/rules/default.rules` valid

## 🛡️ What Was Preserved — Your Knowledge is Sacred

- 📚 **Your domain docs** → ✅ Untouched — [list of preserved brain/*.md]
- 🧠 **Your lessons & todo** → ✅ Untouched — Sacred, never modified
- ⚡ **Your custom skills** → ✅ Untouched — [list]
- 🪝 **Your custom hooks** → ✅ Untouched — [list]
- 📋 **Your AGENTS.md** → ✅ Enhanced — [N] sections added, all your content preserved

## ➕ What Was Added / Upgraded

- ⚡ **New skills** → [list of added skills, or "none — you had them all!"]
- 🪝 **New hooks** → [list of added hooks, or "none — fully hooked up!"]
- 🤖 **New agents** → [list of added agents, or "none — fully stacked!"]
- 📋 **AGENTS.md** → [N] new sections added (review `{{PLACEHOLDERS}}` in each)
- 📁 **Directory structure** → [normalized to brain/tasks/, or "already standard ✅"]

## ⚠️ Manual Review Required

- **AGENTS.md**: New sections added — fill any remaining `{{PLACEHOLDERS}}`
- **brain/build.md**: Verify commands are still accurate
- `.codex/rules/default.rules`: Review any new approval rules

## 🤝 Collaboration Mode

🤝 **TEAM** (default) — config is committed, shared with the team.
→ Switch to SOLO: `echo -e '\nAGENTS.md\n.codex/\n.agents/\nbrain/\n.codexignore' >> .gitignore`

## 🎯 What's Next

1. 💾 **Commit**: `git add AGENTS.md .codexignore .codex/ .agents/ brain/`
2. 👀 Review changes: `git diff HEAD brain/ AGENTS.md .codex/ .agents/`
3. 🧪 Start a Codex session and verify `$build`, `$test`, `$lint` work correctly

---

> 💡 Your accumulated knowledge (`brain/tasks/lessons.md`) was never touched. Every lesson learned carries forward.

⏱️ **Phase timing:** P1 [time] · P2 [time] · P3 [time] · P4 [time] · P4.5 [time] · P5 [time]
```
