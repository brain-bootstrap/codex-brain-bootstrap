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
- **Hooks executable** → ✅ [N]/8
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
- 🔌 **MCP Tools** → cocoindex, code-review-graph, serena, playwright (install with uvx)

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

## 🔌 MCP Tool Status
```

🔎 cocoindex-code — [INSTALLED/NOT INSTALLED]
Semantic search — find code by meaning (local vectors, no API key)
→ First run: uvx cocoindex-code-mcp-server@latest --data-dir .codex/cocoindex --index

🔴 code-review-graph — [INSTALLED/NOT INSTALLED]
Pre-PR blast radius + risk score 0-100
→ Install: uvx code-review-graph@latest

🔧 serena — [INSTALLED/NOT INSTALLED]
LSP-backed atomic symbol rename across entire codebase
→ Install: uvx serena@latest

🌐 playwright — [INSTALLED/NOT INSTALLED]
Browser automation via accessibility tree
→ Install: uvx playwright@latest

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

⏱️ **Phase timing (AI-work):** P1 [time] · P2 [time] · P3 [time] · P4 [time] · P5 [time]
⏱️ **Wall-clock total:** ~[N] minutes
```

---

## Template: UPGRADE

```markdown
# 🔄 Bootstrap Upgrade Complete — [PROJECT_NAME]

> Codex Brain Bootstrap — Upgraded from v[OLD] to v[NEW].
> Generated [date] · **Mode: Upgrade** · ⏱️ Completed in ~[N] minutes

---

## ✅ What Changed

- **Infrastructure updated** — hooks, rules, agents, skills
- **Knowledge preserved** — brain/architecture.md, brain/tasks/, brain/rules.md untouched
- **New hooks added** → [list any new hooks]
- **New skills added** → [list any new skills]
- **New agents added** → [list any new agents]

## ⚠️ Manual Review Required

- AGENTS.md: New sections were added — review and customize `{{PLACEHOLDERS}}`
- brain/build.md: Verify build commands are still accurate for your project
- .codex/rules/default.rules: Review any new approval rules

## ✅ Configuration Health

- **validate.sh** → ✅ **[N] passed**, 0 failed
- **Remaining placeholders** → ⚠️ [N] — run `$bootstrap` to fill

## 🎯 What's Next

1. Review changes: `git diff HEAD brain/ AGENTS.md .codex/ .agents/`
2. Fill remaining placeholders: `$bootstrap`
3. Commit: `git add .`
```
