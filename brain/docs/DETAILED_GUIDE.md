<p align="center">
  <h1 align="center">ᗺB · Codex Brain Bootstrap — The Complete Guide</h1>
  <p align="center"><em>by <a href="https://github.com/brain-bootstrap">brain-bootstrap</a></em></p>
  <p align="center"><strong>Everything you need to know, nothing you don't.<br>From "what is this?" to "I want to build my own hooks."</strong></p>
  <p align="center">
    <a href="#-the-big-picture">Big Picture</a> · <a href="#-get-started">Get Started</a> · <a href="#-the-architecture-tour">Architecture</a> · <a href="#-every-file-explained">Files</a> · <a href="#-deep-dives">Deep Dives</a> · <a href="#-make-it-yours">Customize</a> · <a href="#-faq">FAQ</a>
  </p>
  <p align="center">
    <a href="../../LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="MIT License"></a>
    <a href="#"><img src="https://img.shields.io/badge/100%2B_files-9_categories-blueviolet" alt="100+ files"></a>
    <a href="#"><img src="https://img.shields.io/badge/48_skills-10_hooks-brightgreen" alt="Automation"></a>
  </p>
</p>

---

> 📖 **This is the deep reference.** Looking for the quick pitch? → [README.md](../../README.md)
>
> **Reading time:** ~15 minutes cover to cover. Every section is self-contained.

---

## 📑 Table of Contents

- [🗺️ The Big Picture](#-the-big-picture)
- [🚀 Get Started](#-get-started)
- [🏛️ The Architecture Tour](#-the-architecture-tour)
  - [🎯 The Context Loading Strategy](#-the-context-loading-strategy)
- [📂 Every File, Explained](#-every-file-explained)
  - [🏠 Root Files](#-root-files)
  - [🧠 Bootstrap Scaffolding — `brain/bootstrap/`](#-bootstrap-scaffolding--brainbootstrap)
  - [📚 Knowledge Docs — `brain/`](#-knowledge-docs--brain)
  - [🎓 Skills — `.agents/skills/`](#-skills--agentsskills)
  - [🪝 Lifecycle Hooks — `.codex/hooks/`](#-lifecycle-hooks--codexhooks)
  - [🤖 AI Subagents — `.codex/agents/`](#-ai-subagents--codexagents)
  - [🔒 Approval Rules — `.codex/rules/`](#-approval-rules--codexrules)
  - [🧠 Memory — `brain/tasks/`](#-memory--braintasks)
  - [🔧 Scripts — `brain/scripts/`](#-scripts--brainscripts)
- [🔬 Deep Dives](#-deep-dives)
  - [📂 The 9 Configuration Categories](#-the-9-configuration-categories)
  - [🔄 Bootstrap: How It Actually Works](#-bootstrap-how-it-actually-works)
  - [♻️ Upgrading an Existing Config](#-upgrading-an-existing-config)
- [🏷️ Placeholder Reference](#-placeholder-reference)
- [🎨 Make It Yours](#-make-it-yours)
- [📐 Best Practices](#-best-practices)
- [❓ FAQ](#-faq)
- [🔌 Plugin Ecosystem — Deep Dive](#-plugin-ecosystem--deep-dive)
- [🤝 Contributing](#-contributing)
- [⚖️ License](#-license)

---

## 🗺️ The Big Picture

Codex Brain Bootstrap is **100+ files** organized into **9 categories** that turn your Codex CLI from a talented stranger into a senior engineer who knows your codebase inside out.

Here's the mental model:

```
  🧠  Your Brain (AGENTS.md)
   │   "Here's how we work, here's what matters, here's what never to touch"
   │
   ├── 📚  Knowledge (brain/*.md)
   │       "Here's our architecture, our build system, our auth patterns..."
   │
   ├── 🎓  Discipline (.agents/skills/)
   │       "Here's how to write tests, trace bugs, stay safe"
   │
   ├── 🪝  Guardrails (.codex/hooks/)
   │       "Here's what you're NOT allowed to do, enforced in code"
   │
   ├── 🤖  Delegation (.codex/agents/)
   │       "Here's your team — research, review, challenge"
   │
   └── 🧠  Memory (brain/tasks/)
            "Here's everything we've learned together"
```

**49 skills. 10 lifecycle hooks. 5 AI subagents. 5 MCP tools. 104+ validation checks. Zero setup friction.**

> 💡 Battle-tested. Works with **any language, any framework, any repo**.

---

## 🚀 Get Started

### Step 1 — Install the template

```bash
git clone https://github.com/brain-bootstrap/codex-brain-bootstrap.git /tmp/brain
bash /tmp/brain/install.sh your-repo/
rm -rf /tmp/brain
```

The install script auto-detects FRESH vs UPGRADE mode. If you have an existing Codex config, it preserves all your files and adds only what's missing.

### Step 2 — Let the AI configure itself

Open Codex CLI in your repo and run:

```
$bootstrap
```

Codex will:

1. 🔍 **Discover** your tech stack (language, framework, package manager, linter, test runner, DB, CI…)
2. 🏗️ **Analyze** your architecture (services, domains, patterns)
3. 📝 **Populate** all `{{PLACEHOLDER}}` values across every template file
4. 🧠 **Generate** domain-specific knowledge docs
5. 🔌 **Install** plugins — 5-tool MCP stack (cocoindex-code, codebase-memory-mcp, code-review-graph, playwright, serena) via `brain/scripts/setup-plugins.sh`
6. ✅ **Validate** everything works (`brain/scripts/post-bootstrap-validate.sh` — validate + canary + auto-fix, 104+ checks)

> 💡 **No Codex CLI?** Paste `brain/bootstrap/PROMPT.md` into any AI chat — it works with any LLM.

### Step 3 — Validate and commit

```bash
bash brain/scripts/validate.sh
git add AGENTS.md .codexignore brain/ .codex/ .agents/
git commit -m "chore: add Codex configuration"
```

> 🤝 **TEAM mode** — commit everything, share the AI context with your whole team. Or **SOLO mode**: add `AGENTS.md`, `brain/`, `.codex/`, `.agents/`, `.codexignore` to `.gitignore` and keep the config personal.

### Step 4 — Ship code with superpowers

```
$plan implement user authentication
$build
$test
$review
$mr
```

That's it. You now have a brain. 🧠

---

## 🏛️ The Architecture Tour

Here's how all 100+ files fit together:

```
Your repo
├── 📋 AGENTS.md                  ← The brain (auto-loaded every conversation)
│
├── ⚙️ .codex/
│   ├── config.toml               ← Project configuration + MCP servers
│   ├── hooks.json                ← Lifecycle hook registration
│   ├── hooks/    (8 files)       ← Safety, quality, recovery, TDD loop
│   ├── agents/   (5 files)       ← research, reviewer, plan-challenger, session-reviewer, security-auditor
│   └── rules/
│       └── default.rules         ← Starlark command approval rules
│
├── 🎓 .agents/
│   └── skills/ (48 files)        ← $tdd, $review, $mr, $bootstrap, $cocoindex-code...
│
├── 📚 brain/
│   ├── architecture.md  📖       ← On-demand (project structure)
│   ├── rules.md         📖       ← On-demand + referenced from AGENTS.md
│   ├── build.md         📖       ← On-demand (when building)
│   ├── terminal-safety  📖       ← On-demand (safety reference)
│   ├── <your-domains>   📖       ← On-demand (when task involves domain)
│   └── tasks/                    ← Persistent memory across sessions
│       ├── lessons.md            ← "Never make this mistake again"
│       ├── todo.md               ← "Here's where I left off"
│       └── CODEX_ERRORS.md       ← Structured error log
│
└── 🚫 .codexignore               ← "Don't even look at these files"
```

### 🎯 The Context Loading Strategy

Unlike Claude Code (which uses `@import` for auto-loading), Codex loads `AGENTS.md` for every session. The system is designed around a single always-loaded context with on-demand deeper reads:

| Layer                | What loads                                            | When                      | Token cost |
| :------------------- | :---------------------------------------------------- | :------------------------ | :--------: |
| 🟢 **Always on**     | `AGENTS.md` — operating protocol, lookup table, rules | Every conversation        |   ~4-6K    |
| 🟡 **Hook-injected** | `brain/tasks/todo.md` + `brain/tasks/lessons.md`      | Session start             |  ~500-2K   |
| 🔵 **On-demand**     | `brain/*.md` domain docs (build, auth, DB…)           | When the task requires it | ~1-2K each |

> 🎯 **Result:** Minimal cost for simple tasks, deep context exactly when needed.

---

## 📂 Every File, Explained

### 🏠 Root Files

| File                              | What it does                                                                |
| :-------------------------------- | :-------------------------------------------------------------------------- |
| 📋 `AGENTS.md`                    | The brain — operating protocol, exit checklist, skills roster, lookup table |
| 👤 `AGENTS.override.md.example`   | Your personal overrides template (gitignored in use)                        |
| 🚫 `.codexignore`                 | Keeps binaries, lock files, and build artifacts out of context              |
| 📖 `README.md`                    | The pitch + quick start                                                     |
| ⚖️ `LICENSE`                      | MIT                                                                         |
| 🐚 `.shellcheckrc`                | ShellCheck configuration for script linting                                 |
| 🔎 `.cocoindex_code/settings.yml` | CocoIndex semantic search configuration (include/exclude patterns)          |
| 🔧 `.serena/project.yml`          | Serena LSP language server configuration                                    |

### 🧠 Bootstrap Scaffolding — `brain/bootstrap/`

> These files exist only during bootstrap. After Phase 5 cleanup, you can delete them. For future upgrades, re-clone the template.

| File                    | What it does                                                         |
| :---------------------- | :------------------------------------------------------------------- |
| 🪄 `PROMPT.md`          | Paste into any AI to auto-configure — works with any LLM             |
| 📖 `REFERENCE.md`       | Report templates for Phase 5 — kept separate to save working context |
| 🔄 `UPGRADE_GUIDE.md`   | Smart Merge guide — loaded only for UPGRADE mode                     |
| `_AGENTS.md.template`   | Base AGENTS.md template with all {{PLACEHOLDER}} tokens              |
| `_codexignore.template` | Base .codexignore with standard exclusions                           |

### 📚 Knowledge Docs — `brain/`

These are the AI's textbooks. The session-start hook injects the most critical ones; others load on-demand:

| File                            | What it teaches                                           | When to read                            |
| :------------------------------ | :-------------------------------------------------------- | :-------------------------------------- |
| `architecture.md`               | Workspace layout, services, packages, aliases             | Any task touching project structure     |
| `rules.md`                      | 25 golden rules + quality thresholds                      | Every session (referenced in AGENTS.md) |
| `terminal-safety.md`            | Shell anti-patterns that hang sessions                    | Any shell command                       |
| `build.md`                      | Build, test, lint, CI commands and gotchas                | Building, testing, CI                   |
| `templates.md`                  | MR/ticket templates, context management                   | Opening a PR, writing a commit          |
| `cve-policy.md`                 | CVE decision tree, override checklist                     | Security scans, dependency updates      |
| `plugins.md`                    | MCP tool catalog and configuration                        | Using semantic search, review graph     |
| `decisions.md`                  | Architectural decision log — settled choices              | Making a significant tech choice        |
| `README.md`                     | Meta-docs: how to extend the knowledge base               | Reference                               |
| `docs/DETAILED_GUIDE.md`        | Complete guide — architecture, all files, deep dives, FAQ | Reference                               |
| `_examples/api-domain.md`       | Worked example: REST API domain                           | 🗑️ Delete after use                     |
| `_examples/database-domain.md`  | Worked example: Database domain                           | 🗑️ Delete after use                     |
| `_examples/messaging-domain.md` | Worked example: Event-driven domain                       | 🗑️ Delete after use                     |

> 💡 **The examples are training wheels.** Study them → create your own → delete them.

### 🎓 Skills — `.agents/skills/` (48 files)

Skills activate when invoked with `$skill-name`. Every skill has a `description:` field that tells Codex when to load it:

| Skill                            | Type       | When it kicks in                                                     |
| :------------------------------- | :--------- | :------------------------------------------------------------------- |
| 🧪 `tdd`                         | Background | Loads when editing `*.test.*` or `*.spec.*` — enforces test-first    |
| 🔎 `root-cause-trace`            | Invocable  | 5-step systematic error investigation                                |
| 📝 `changelog`                   | Invocable  | Generates release notes from git commits                             |
| ⚠️ `careful`                     | Invocable  | Activates safety guards during sensitive operations                  |
| 🔍 `cross-layer-check`           | Invocable  | Verifies a symbol exists across all monorepo layers (bundled script) |
| 🗺️ `codebase-memory`             | Invocable  | Live structural graph — trace call paths, blast radius, dead code    |
| 🔭 `cocoindex-code`              | Invocable  | Semantic vector search — find code by meaning, not exact names       |
| 🛡️ `code-review-graph`           | Invocable  | Change risk analysis — risk score 0–100, blast radius                |
| 📋 `repo-recap`                  | Invocable  | Generate release / activity summaries                                |
| 🔀 `pr-triage`                   | Invocable  | Audit open PRs, deep review selected ones                            |
| 🐛 `issue-triage`                | Invocable  | Audit open issues, categorize, detect duplicates                     |
| 🌐 `playwright`                  | Invocable  | Browser automation via MCP                                           |
| 🔧 `serena`                      | Invocable  | LSP-backed rename/move/inline across the entire codebase             |
| 💡 `brainstorming`               | Invocable  | Requirements exploration and design before writing code              |
| 🤝 `receiving-code-review`       | Invocable  | Process review feedback before implementing suggestions              |
| 🤖 `subagent-driven-development` | Invocable  | Dispatch independent tasks to fresh subagents with two-stage review  |
| ✍️ `writing-skills`              | Invocable  | Create and maintain SKILL.md files with quality standards            |
| 📏 `plan`                        | Invocable  | Structure a task before coding                                       |
| 📋 `review`                      | Invocable  | Full 10-point code review                                            |
| 🏗️ `mr`                          | Invocable  | Generate MR/PR description                                           |
| 🐛 `debug`                       | Invocable  | Root cause analysis workflow                                         |
| 🔬 `research`                    | Invocable  | Isolated codebase exploration                                        |
| 🔄 `resume`                      | Invocable  | Restore context from last session                                    |
| 🔁 `checkpoint`                  | Invocable  | Save session state before compaction                                 |
| 🏭 `build`                       | Invocable  | Build and verify                                                     |
| 🧪 `test`                        | Invocable  | Run tests and report failures                                        |
| 🔍 `lint`                        | Invocable  | Lint and format check                                                |
| 🔧 `maintain`                    | Invocable  | Detect and fix stale `brain/*.md` files                              |
| 🌿 `worktree`                    | Invocable  | Git worktree management for parallel work                            |
| 🚀 `bootstrap`                   | Invocable  | Auto-configure `AGENTS.md` for this repo                             |
| ❓ `ask`                         | Invocable  | Route codebase questions to MCP structural tools                     |
| 🧹 `clean-worktrees`             | Invocable  | Remove merged git worktrees safely                                   |
| 🗑️ `cleanup`                     | Invocable  | Clean build artifacts, deps cache, docker volumes                    |
| 📖 `context`                     | Invocable  | Load domain-specific brain/ files by keyword                         |
| 🗄️ `db`                          | Invocable  | Non-interactive database queries                                     |
| 📦 `deps`                        | Invocable  | Manage dependencies and CVE audit                                    |
| 📊 `diff`                        | Invocable  | Git diff with merge-base (stat/full/files/commits)                   |
| 🐳 `docker`                      | Invocable  | Non-interactive Docker operations                                    |
| 🌿 `git`                         | Invocable  | Git workflow with pre-push safety checklist                          |
| 🏥 `health`                      | Invocable  | Codex config health check dashboard                                  |
| 🔌 `mcp`                         | Invocable  | MCP server management in config.toml                                 |
| 🚚 `migrate`                     | Invocable  | Database migration workflow with safety rules                        |
| 🖥️ `serve`                       | Invocable  | Start dev services (reads brain/build.md)                            |
| 👥 `squad-plan`                  | Invocable  | Multi-agent parallel workstream plan                                 |
| 📈 `status`                      | Invocable  | Project status dashboard (budget, hooks, plugins)                    |
| 🎫 `ticket`                      | Invocable  | Create ticket description with evidence                              |
| 🔄 `update-code-index`           | Invocable  | Scan exports → CODE_INDEX.md deduplication                           |
| 🌲 `worktree-status`             | Invocable  | Show all git worktrees with status                                   |

### 🪝 Lifecycle Hooks — `.codex/hooks/` (10 files)

These are your guardrails. They run automatically — no tokens, no AI reasoning, deterministic protection:

> **Important:** In Codex CLI, `PreToolUse` and `PostToolUse` hooks fire ONLY for the Bash tool. File write/edit hooks (`Write`, `Edit`, `MultiEdit`) do NOT fire hook events.

| Hook                         | Fires on           | What it does                                                            |  ⏱️  |
| :--------------------------- | :----------------- | :---------------------------------------------------------------------- | :--: |
| 🏁 `session-start.sh`        | SessionStart       | Injects branch, task state, todo.md, lessons.md                         | 10s  |
| 🔒 `config-protection.sh`    | PreToolUse (Bash)  | Blocks editing `biome.json`, `tsconfig.json`, IDE configs               |  5s  |
| 🚧 `terminal-safety-gate.sh` | PreToolUse (Bash)  | Blocks pagers, `vi`, unbounded output, pipe double-quotes               |  5s  |
| 🧹 `pre-commit-quality.sh`   | PreToolUse (Bash)  | Catches `debugger`, secrets, `console.log` before git commits           | 30s  |
| 🪪 `permission-audit.sh`     | PermissionRequest  | Logs permission requests for later review                               |  5s  |
| 📓 `post-bash-review.sh`     | PostToolUse (Bash) | Injects failure context when Bash errors detected                       |  5s  |
| �️ `prompt-guard.sh`          | UserPromptSubmit   | Blocks prompt if secrets/API keys are accidentally pasted               |  5s  |
| �🔁 `tdd-loop-check.sh`      | Stop               | TDD enforcement — blocks stopping if tests were skipped                 | 120s |
| 👋 `exit-nudge.sh`           | Stop               | 6-item exit checklist reminder before every yield                       |  5s  |
| 💡 `warn-missing-test.sh`    | Stop               | Warns (strict profile) when session modified source files without tests |  5s  |

> 🛡️ **Hooks are not suggestions — they're enforcement.** A blocked action returns an error message explaining what to do instead.
>
> Hooks require `[features] codex_hooks = true` in `.codex/config.toml` (enabled by default in this template).

### 🤖 AI Subagents — `.codex/agents/` (5 files)

Your AI has a team. Each subagent runs in an **isolated context** — research doesn't pollute your main conversation:

| Agent                   | What it does                                                                        |
| :---------------------- | :---------------------------------------------------------------------------------- |
| 🔍 **explorer**         | Fast read-only codebase exploration (quick/medium/thorough modes)                   |
| 📋 **reviewer**         | Expert 10-point code review with severity classification                            |
| ⚔️ **plan-challenger**  | Adversarial plan review — finds real risks before you write code                    |
| 📊 **session-reviewer** | Conversation pattern analysis — detects corrections, frustrations, recurring issues |
| 🔐 **security-auditor** | Security scanning — secrets, auth gaps, injection, CVEs, DEPLOY/HOLD verdict        |

### 🔒 Approval Rules — `.codex/rules/`

`default.rules` (Starlark format) defines which commands run automatically vs. which require explicit user approval:

```python
prefix_rule(
  pattern = "rm -rf",
  decision = "require-approval",
  justification = "Irreversible destructive operation"
)
prefix_rule(
  pattern = "git push",
  decision = "require-approval",
  justification = "External side effect — user must confirm"
)
```

> Unlike Claude Code's path-scoped `rules/*.md` files (which inject markdown into context), Codex rules are binary: `allow` or `require-approval`. Domain-specific guidelines belong in `AGENTS.md` or the knowledge docs.

### 🧠 Memory — `brain/tasks/`

The AI's persistent memory across sessions:

| File                 | What it stores                                                                        |
| :------------------- | :------------------------------------------------------------------------------------ |
| 📓 `lessons.md`      | Accumulated wisdom — mistakes, corrections, discoveries. Read at every session start. |
| 📝 `todo.md`         | Current task plan with checkable items. Survives context compaction.                  |
| 🐛 `CODEX_ERRORS.md` | Structured error log — promotes recurring bugs to `AGENTS.md` after 3+ recurrences.   |
| `.gitkeep`           | Ensures directory is tracked in git even when empty                                   |
| `.gitignore`         | Excludes session temp files from git tracking                                         |

### 🔧 Scripts — `brain/scripts/`

The automation backbone — pure bash, zero token cost:

| Script                          | What it does                                                                                 |  Speed  |
| :------------------------------ | :------------------------------------------------------------------------------------------- | :-----: |
| 🔍 `discover.sh`                | Single-pass repo scanner — detects stack, frameworks, commands                               |   ~2s   |
| 📝 `populate-templates.sh`      | Batch fills `{{PLACEHOLDER}}` values across template files                                   |   ~3s   |
| ✅ `post-bootstrap-validate.sh` | Unified validation — runs validate + canary + auto-fix                                       |  ~10s   |
| 🔎 `validate.sh`                | 66+-check template validator — file existence, hooks, JSON validity, placeholders            |   ~5s   |
| 🏥 `canary-check.sh`            | LIVE config health — AGENTS.md size, skills count, hooks, stale refs                         |   ~2s   |
| 🛡️ `phase2-verify.sh`           | Phase 2 data-integrity check — confirms lessons/todo/config survived Smart Merge             |   ~1s   |
| 🔌 `setup-plugins.sh`           | All-in-one bootstrap plugin management — install, disable, verify, update AGENTS.md          |   ~5s   |
| 🖥️ `_platform.sh`               | Portable shell helper library — detects platform, provides `sed_inplace()`, `require_tool()` | instant |
| 🔍 `portability-lint.sh`        | GNU-only pattern detector — head -n -N, grep -P, readlink -f, date -d, etc.                  |   ~1s   |
| 🧪 `integration-test.sh`        | End-to-end test of install.sh — FRESH + UPGRADE + validate in temp dirs                      |  ~10s   |
| 💾 `merge-agents-md.sh`         | Smart merge for `AGENTS.md` during upgrades — appends missing sections safely                |   ~1s   |
| 💾 `merge-codexignore.sh`       | Union merge for `.codexignore` — adds new patterns without removing existing ones            | instant |
| 📁 `migrate-tasks.sh`           | Migrates task files from old layout to current `brain/tasks/` structure                      | instant |
| 🎭 `dry-run.sh`                 | Simulate install without touching the target repo — preview what would change                |   ~2s   |

---

## 🔬 Deep Dives

### 📂 The 9 Configuration Categories

#### 1. 📋 Root Instructions (`AGENTS.md`)

The brain of the brain. Auto-loaded every conversation. Contains:

- **Operating Protocol** (8 rules) — plan first, delegate, prove it works, fix bugs yourself
- **Exit Checklist** (6 items) — prevents knowledge drift across sessions
- **Skills Roster** (30 entries) — every available skill with invocation syntax
- **Mandatory Reads table** — lookup table for which docs to read per task
- **Terminal Rules** — universal safety patterns
- **Critical Patterns** — your project's non-negotiable rules
- **Review Protocol** — 10-point checklist before any MR

#### 2. 📚 Domain Knowledge (`brain/`)

On-demand deep knowledge. A lookup table in `AGENTS.md` tells the AI which file to read:

```
Task about building?   → Read brain/build.md
Task about security?   → Read brain/cve-policy.md
Task about MCP tools?  → Read brain/plugins.md
```

**Adding a new domain?** Create `brain/<domain>.md` → add to lookup table → done.

#### 3. 🎓 Skills (`.agents/skills/`)

Skills are reference guides for proven techniques, tools, and workflows. The `description:` field in each skill's YAML frontmatter is the **discovery mechanism** — Codex reads it to decide whether to load the skill:

```yaml
---
name: root-cause-trace
description: Use when errors occur deep in execution and you need to trace back to the original trigger.
---
```

> 🎯 **NEVER put workflow summaries in `description:`** — Codex will follow the description instead of reading the skill body.

**Bundled script skills:** Some skills include supporting scripts:

- `cross-layer-check/scripts/cross-layer-check.sh` — bash script for symbol search across layers

#### 4. 🪝 Lifecycle Hooks (`.codex/hooks/`)

Deterministic automation — zero token cost. 10 hooks across 5 lifecycle events:

- 🏁 **Session start** — inject branch, task state, lessons, todo
- 🔒 **Config protection** — block editing linter/compiler configs
- 🚧 **Terminal safety** — block `vi`, pagers, unbounded output
- 🧹 **Commit quality** — catch debugger statements, secrets
- 👋 **Exit checklist** — 6-item reminder before yielding

**Critical Codex hook behavior:**

- `PreToolUse` + `PostToolUse` fire only for **Bash** tool — NOT for file writes/edits
- `Stop` hooks use JSON output to control Codex: `{}` or exit 0 = allow stop; `{"decision":"block","reason":"..."}` or exit 2 = Codex continues
- `PermissionRequest` hooks audit permission escalation attempts

#### 5. 🤖 AI Subagents (`.codex/agents/*.toml`)

TOML files with `name`, `description`, and `developer_instructions`. Isolated context windows:

- **explorer** — explore 20+ files without polluting main context
- **reviewer** — 10-point code review with severity classification
- **plan-challenger** — find real risks before writing a single line
- **security-auditor** — secrets, auth gaps, injection, CVE scanning
- **session-reviewer** — detect corrections and patterns in conversation

#### 6. 🔒 Approval Rules (`.codex/rules/default.rules`)

Starlark rules that enforce command approval. Unlike path-scoped markdown rules (Claude Code feature), Codex rules are **binary approval decisions** — they don't inject content into context. Use `AGENTS.md` for behavioral guidelines.

```python
# Format:
prefix_rule(pattern="PATTERN", decision="allow|require-approval", justification="WHY")
```

#### 7. ⚙️ Configuration (`.codex/config.toml` + `.codex/hooks.json`)

Two-file configuration split:

- **`config.toml`** — model settings, MCP server declarations, feature flags
- **`hooks.json`** — hook event registrations with shell commands and timeouts

Key config.toml settings:

```toml
[features]
codex_hooks = true          # Required for hooks to fire

model_reasoning_effort = "high"   # Top-level key in Codex config

[mcp_servers.cocoindex-code]
command = "uvx"
args = ["cocoindex-code-mcp-server@latest", "--data-dir", ".codex/cocoindex"]
```

#### 8. 🔌 Plugin Ecosystem

Five MCP tools cover distinct intelligence axes:

| Tool                     | Axis                                                                    | Config key          |
| :----------------------- | :---------------------------------------------------------------------- | :------------------ |
| 🔎 **cocoindex-code**    | _"Find code by meaning"_ — semantic vector search, local embeddings     | `cocoindex-code`    |
| 🔍 **codebase-memory**   | _"Who calls this function?"_ — live structural graph, 120× fewer tokens | `codebase-memory`   |
| 🔴 **code-review-graph** | _"Is this PR safe?"_ — risk score 0–100, blast radius                   | `code-review-graph` |
| 🌐 **playwright**        | _"Test this form / scrape this page"_ — browser automation              | `playwright`        |
| 🔧 **serena**            | _"Rename everywhere"_ — LSP-backed atomic rename/move/inline            | `serena`            |

All tools are declared in `.codex/config.toml` under `[mcp_servers.*]`. Uncomment to enable. See `brain/plugins.md` for full documentation.

#### 9. 🧠 Memory (`brain/tasks/`)

Three-file persistent memory:

- **`lessons.md`** — accumulated wisdom, injected at session start
- **`todo.md`** — current task state, survives compaction
- **`CODEX_ERRORS.md`** — structured error log; recurring bugs (3+) get promoted to rules in `AGENTS.md`

---

### 🔄 Bootstrap: How It Actually Works

The bootstrap runs in **5 optimized phases**:

#### Phase 1: Discovery (~2s) 🔍

Runs `brain/scripts/discover.sh` — a single script that replaces 15+ individual detection commands:

- Detects existing config → chooses **FRESH** or **UPGRADE** mode
- Scans for languages (with file counts), package manager, runtime
- Detects formatter/linter, test frameworks, DB, CI
- Derives build/test/lint/serve commands
- Outputs structured KEY=VALUE pairs to `brain/tasks/.discovery.env`

#### Phase 2: Smart Merge (UPGRADE only) 🔄

If upgrading an existing config:

1. **`merge-agents-md.sh`** — appends missing sections to `AGENTS.md` (never modifies existing content)
2. **`merge-codexignore.sh`** — union-merges new patterns into `.codexignore`
3. **`phase2-verify.sh`** — confirms all data survived the merge

#### Phase 3: Populate Templates (~3s) 📝

Runs `brain/scripts/populate-templates.sh`:

- Fills 70+ `{{PLACEHOLDER}}` tokens from discovery data
- Generates domain-specific knowledge stubs
- Creates `brain/domain/` structure based on detected components

#### Phase 4: Plugin Setup (~5s) 🔌

Runs `brain/scripts/setup-plugins.sh`:

- Installs/verifies MCP tool servers
- Updates `AGENTS.md` with installed plugin invocations
- Verifies `.codex/config.toml` entries

#### Phase 5: Validate ✅

Runs `brain/scripts/post-bootstrap-validate.sh`:

- `validate.sh` — template completeness (104+ checks)
- `canary-check.sh` — live config health (AGENTS.md size, hooks, skills)
- Auto-fixes common issues (permissions, executable bits)

---

### ♻️ Upgrading an Existing Config

```bash
# From the bootstrap source repo:
bash install.sh /path/to/your-project

# Or if already inside your project:
bash brain/scripts/dry-run.sh    # preview what would change
bash install.sh .                # run the upgrade
```

The upgrade is **safe by design**:

- Existing `AGENTS.md`, `brain/tasks/*.md`, and custom skills are **never overwritten**
- New sections are appended with `<!-- BB: added by upgrade YYYY-MM-DD -->` markers
- `.codexignore` patterns are union-merged (existing patterns preserved)
- `brain/scripts/phase2-verify.sh` runs automatically to confirm data integrity

---

## 🏷️ Placeholder Reference

After install, `brain/bootstrap/_AGENTS.md.template` (and other templates) contain `{{PLACEHOLDER}}` tokens that the bootstrap fills in:

| Placeholder                | Where used                | What it becomes                         |
| :------------------------- | :------------------------ | :-------------------------------------- |
| `{{PROJECT_NAME}}`         | AGENTS.md, brain/\*.md    | Your project/repo name                  |
| `{{TECH_STACK}}`           | AGENTS.md                 | Primary language + framework            |
| `{{PACKAGE_MANAGER}}`      | brain/build.md, AGENTS.md | npm, pnpm, yarn, uv, cargo, etc.        |
| `{{BUILD_COMMAND}}`        | brain/build.md            | The actual command to build             |
| `{{TEST_COMMAND}}`         | brain/build.md            | The actual command to run tests         |
| `{{LINT_COMMAND}}`         | brain/build.md            | The actual formatter/linter command     |
| `{{FORMATTER}}`            | AGENTS.md                 | Biome, Prettier, Black, rustfmt, etc.   |
| `{{RUNTIME}}`              | brain/build.md            | Node.js version, Python version, etc.   |
| `{{ARCHITECTURE_SUMMARY}}` | brain/architecture.md     | Brief description of your app structure |
| `{{CRITICAL_RULES}}`       | AGENTS.md                 | Project-specific non-negotiable rules   |

Run `bash brain/scripts/validate.sh` to see which placeholders still need filling.

---

## 🎨 Make It Yours

### Personal override

Copy `AGENTS.override.md.example` → `AGENTS.override.md` (gitignored) for personal instructions that don't belong in the shared `AGENTS.md`.

### Add domain knowledge

Create files in `brain/domain/` for project-specific knowledge. Follow the pattern in `brain/_examples/`:

```
brain/domain/api.md        ← API conventions, auth, rate limits
brain/domain/database.md   ← Schema conventions, migration rules
brain/domain/messaging.md  ← Queue/event patterns, retry policies
```

### Add a new skill

1. Create `.agents/skills/<name>/SKILL.md`
2. Write YAML frontmatter with `name:` and `description:`
3. Keep `description:` as triggering conditions — never a workflow summary
4. Add the skill to the Skills Roster in `AGENTS.md`
5. Add a check to `brain/scripts/validate.sh`

> Use `$writing-skills` for the complete skill authoring guide.

### Add a new hook

1. Create `.codex/hooks/my-hook.sh` (chmod +x)
2. Register it in `.codex/hooks.json` under the correct event key:

```json
"PreToolUse": [
  {
    "matcher": "Bash",
    "hooks": [
      {
        "type": "command",
        "command": "/usr/bin/env bash \"$(git rev-parse --show-toplevel 2>/dev/null || echo .)\"/.codex/hooks/my-hook.sh",
        "timeout": 10
      }
    ]
  }
]
```

3. Return exit 0 to allow; output `{"decision":"block","reason":"..."}` or exit code 2 to block

### Add domain rules to `.codex/rules/default.rules`

Add `prefix_rule()` entries for commands specific to your project:

```python
prefix_rule(
  pattern = "DROP TABLE",
  decision = "require-approval",
  justification = "Irreversible schema change"
)
```

---

## 📐 Best Practices

### AGENTS.md

- Keep it **under 32KB** — Codex has a hard limit on instruction file size
- Organize the mandatory reads lookup table carefully — it's what directs Codex to the right docs
- Use the Exit Checklist section to enforce discipline at turn boundaries

### Skills

- **description: field = triggering conditions only** — never workflow summary
- Keep frequently-used skills under 200 words (they load often)
- Cross-reference other skills instead of repeating content

### Hooks

- Return `{}` (JSON) from `Stop` hooks to allow stopping; `{"decision":"block","reason":"..."}` or exit 2 to continue
- `Stop` hooks must output valid JSON (plain text is invalid for this event)
- `PreToolUse` hooks receive the full command in stdin; parse carefully

### Memory

- Archive `brain/tasks/lessons.md` when it exceeds ~200 lines
- Promote errors in `CODEX_ERRORS.md` to `AGENTS.md` after 3+ recurrences
- Keep `brain/tasks/todo.md` under 50 lines — link to separate plan files for big tasks

---

## ❓ FAQ

**Q: Do I need to pay for MCP tools?**

> No. All 5 MCP tools (cocoindex-code, codebase-memory, code-review-graph, playwright, serena) run locally. No external API required. You do need `uvx`, `npx`, or other package runners installed.

**Q: How is this different from just writing a good README?**

> A README explains your code to humans. Brain Bootstrap explains your workflows, architecture, rules, and patterns to an AI — in a format it can act on (hooks, skills, agents, rules). It also enforces behaviors automatically (hooks block bad terminal commands regardless of what the AI "decides").

**Q: Why does `AGENTS.md` have {{PLACEHOLDER}} tokens after install?**

> By design. The bootstrap fills them in using `brain/scripts/populate-templates.sh` after scanning your repo. Run `$bootstrap` or `bash brain/scripts/populate-templates.sh` to fill them.

**Q: Can I use this with multiple AI tools (not just Codex)?**

> Yes. The `brain/` knowledge docs and `AGENTS.md` are plain Markdown — any AI can read them. The `.codex/hooks/` and `.codex/rules/` are Codex-specific, but the knowledge is portable. Paste `brain/bootstrap/PROMPT.md` into ChatGPT, Claude, or any LLM to bootstrap without Codex CLI.

**Q: How do I update Brain Bootstrap after it ships updates?**

> Re-clone and re-run: `bash /tmp/brain/install.sh .` — the upgrade mode preserves all your customizations and adds missing components. Run `brain/scripts/dry-run.sh` first to preview what changes.

**Q: What's the `brain/tasks/CODEX_ERRORS.md` file for?**

> It's a structured bug tracker for AI-introduced errors. When you correct Codex, add an entry. When the same mistake recurs 3+ times, add a rule to `AGENTS.md`. This creates a feedback loop where each project gets progressively smarter over time.

**Q: Why are some hooks `PreToolUse` and others `Stop`?**

> Codex lifecycle events: `SessionStart` fires once at start; `PreToolUse`/`PostToolUse` fire around Bash commands only (not file writes); `Stop` fires when Codex wants to yield; `PermissionRequest` fires on escalation. Design hooks for the event that matches their purpose.

**Q: Is it safe to commit everything (AGENTS.md, brain/, .codex/, .agents/) to git?**

> Yes — this is the recommended TEAM mode. It shares the AI context with all developers. Make sure `brain/tasks/.gitignore` is set to exclude session temp files. For SOLO mode, add the directories to your `.gitignore` and keep them personal.

---

## 🔌 Plugin Ecosystem — Deep Dive

Five MCP tools are managed by `brain/scripts/setup-plugins.sh`. Each covers a distinct, non-overlapping intelligence axis:

### cocoindex-code — Semantic Search

Find code by meaning, not exact names. Uses local vector embeddings — no API key required.

```bash
# Install
uvx cocoindex-code-mcp@latest setup

# Usage in session
$cocoindex-code
# Or just describe what you're looking for
```

**When to use:** "Where is rate limiting implemented?" (you don't know the exact function name).

See `brain/plugins.md` and `$cocoindex-code` skill for full reference.

### codebase-memory-mcp — Structural Graph

Live structural graph — trace call paths, blast radius, dead code. 120× fewer tokens than file exploration.

```toml
# .codex/config.toml
[mcp_servers.codebase-memory]
command = "uvx"
args = ["codebase-memory-mcp@latest", "--data-dir", ".codex/codebase-memory"]
```

**First run:** `index_repository(repo_path=".")` (~6s for 500 files).

See `$codebase-memory` skill for the full decision matrix.

### code-review-graph — Change Risk Analysis

Scores your diff 0–100 for risk. Identifies blast radius, breaking changes, and the highest-risk files.

**Use before every PR.** See `$code-review-graph` skill for the full workflow.

### playwright — Browser Automation

Navigate, click, snapshot, fill forms in real browsers via the accessibility tree (not pixels).

**Use for:** UI testing, form validation, web scraping, checking how a deployed app looks.

See `$playwright` skill for usage patterns.

### serena — LSP Symbol Refactoring

Atomic rename/move/inline that tracks every reference across the entire codebase. Never misses a caller.

**Use for:** Renaming functions/classes, moving files, inlining variables.

See `$serena` skill for the full command reference.

---

## 🤝 Contributing

Contributions welcome! Here's how to set up the development environment and guidelines for contributing:

### Setup

```bash
git clone https://github.com/brain-bootstrap/codex-brain-bootstrap.git
cd codex-brain-bootstrap
bash install.sh --check   # verify prerequisites
bash brain/scripts/validate.sh  # should show 0 failures
```

### Guidelines

- **Domain-agnostic** — no company names, no project-specific logic in templates
- **Test everything** — add checks to `brain/scripts/validate.sh` for new files
- **Shell portability** — run `brain/scripts/portability-lint.sh` before submitting
- **Placeholders** — use `{{UPPER_SNAKE}}` syntax for template values
- **Hook scripts** — must be executable, have `#!/bin/bash` shebang, `set -euo pipefail`
- **Skills** — `description:` must be triggering conditions only (see `$writing-skills`)

### CI Pipeline

GitHub Actions runs 4 jobs on every PR:

| Job         | What it checks                                          |
| :---------- | :------------------------------------------------------ |
| ShellCheck  | Shell script correctness (all `*.sh` files)             |
| Portability | GNU-only patterns (runs `portability-lint.sh`)          |
| Links       | Documentation links (offline lychee check)              |
| Validate    | `validate.sh` on Ubuntu + macOS + Windows (3 platforms) |
| Integration | `integration-test.sh` on all 3 platforms                |

All 5 jobs must pass before merging.

---

## ⚖️ License

MIT — see [LICENSE](../../LICENSE)

---

_Generated by ᗺB Brain Bootstrap · [github.com/brain-bootstrap/codex-brain-bootstrap](https://github.com/brain-bootstrap/codex-brain-bootstrap)_
