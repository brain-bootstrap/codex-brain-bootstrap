# Codex Brain Bootstrap

> A production-grade productivity system for [OpenAI Codex CLI](https://github.com/openai/codex). Inspired by and adapted from [claude-code-brain-bootstrap](https://github.com/y-abs/claude-code-brain-bootstrap).

---

## What is this?

Codex Brain Bootstrap gives your Codex CLI sessions everything they need to work like a seasoned engineer on your codebase:

- **Auto-loaded context** — `AGENTS.md` is read by Codex at every session start. It contains your project's operating protocol, rules, and mandatory reads.
- **Lifecycle hooks** — `.codex/hooks/` fire on session start, before/after tool use, and before stopping. They protect config files, block dangerous terminal patterns, inject failure context, and enforce the exit checklist.
- **Skills** — `.agents/skills/` gives Codex invocable workflows (`$plan`, `$review`, `$tdd`, `$debug`, `$mr`, etc.) that encode your team's processes.
- **Subagents** — `.codex/agents/` defines specialized subagents (explorer, reviewer, plan-challenger, security-auditor, session-reviewer) that Codex can delegate to.
- **Brain knowledge layer** — `brain/` is a persistent knowledge base (architecture, build commands, rules, lessons, error tracker) that Codex reads on demand.
- **Smart installer** — `install.sh` handles fresh installs and upgrades, preserving your customizations.

---

## Quick Start

```bash
# 1. Clone into a temp location
git clone https://github.com/your-org/codex-brain-bootstrap.git /tmp/codex-brain

# 2. Install into your project
bash /tmp/codex-brain/install.sh /path/to/your-project

# 3. Cleanup
rm -rf /tmp/codex-brain

# 4. Bootstrap your project knowledge (inside Codex)
$bootstrap
```

That's it. On the next `codex` session, your brain is active.

---

## Pre-flight Check

```bash
bash install.sh --check
```

Verifies: git, jq (recommended for hooks), bash 4+, uvx (for optional MCP plugins).

---

## What Gets Installed

```
your-project/
├── AGENTS.md                    ← Core brain (auto-loaded by Codex every session)
├── AGENTS.override.md.example   ← Personal override template
├── .codexignore                 ← Files Codex should not edit
│
├── .codex/
│   ├── config.toml              ← Project-level Codex configuration
│   ├── hooks.json               ← Lifecycle hook registration
│   ├── hooks/                   ← Hook scripts (10 hooks)
│   │   ├── session-start.sh     ← Injects brain context on every start
│   │   ├── config-protection.sh ← Blocks edits to protected files
│   │   ├── terminal-safety-gate.sh ← Blocks dangerous terminal patterns
│   │   ├── pre-commit-quality.sh ← Quality gate before code changes
│   │   ├── permission-audit.sh  ← Logs permission requests
│   │   ├── post-bash-review.sh  ← Injects failure context on errors
│   │   ├── prompt-guard.sh      ← Scans prompts for accidentally pasted secrets
│   │   ├── tdd-loop-check.sh    ← Prevents stopping on test failures
│   │   └── exit-nudge.sh        ← Enforces exit checklist
│   ├── rules/
│   │   └── default.rules        ← Starlark command approval rules
│   └── agents/                  ← Subagent definitions (5 agents)
│
├── .agents/
│   └── skills/                  ← Invocable skill workflows (48 skills)
│       ├── ask/                 ← $ask: route codebase questions to MCP tools
│       ├── bootstrap/           ← $bootstrap: configure AGENTS.md for project
│       ├── brainstorming/       ← $brainstorming: design before coding
│       ├── build/               ← $build: build and verify
│       ├── careful/             ← $careful: safety mode for destructive ops
│       ├── changelog/           ← $changelog: user-facing changelog from git
│       ├── checkpoint/          ← $checkpoint: save session state
│       ├── clean-worktrees/     ← $clean-worktrees: remove merged worktrees
│       ├── cleanup/             ← $cleanup: clean build artifacts and cache
│       ├── codebase-memory/     ← $codebase-memory: structural graph navigation
│       ├── cocoindex-code/      ← $cocoindex-code: semantic code search
│       ├── code-review-graph/   ← $code-review-graph: blast radius + risk score
│       ├── context/             ← $context: load brain/ files by keyword
│       ├── cross-layer-check/   ← $cross-layer-check: symbol consistency
│       ├── db/                  ← $db: non-interactive database queries
│       ├── debug/               ← $debug: 5-step root cause analysis
│       ├── deps/                ← $deps: manage dependencies and CVE audit
│       ├── diff/                ← $diff: git diff with merge-base
│       ├── docker/              ← $docker: non-interactive Docker operations
│       ├── git/                 ← $git: git workflow with safety checklist
│       ├── health/              ← $health: Codex config health check
│       ├── issue-triage/        ← $issue-triage: GitHub issue triage
│       ├── lint/                ← $lint: lint and format
│       ├── maintain/            ← $maintain: fix stale brain/*.md docs
│       ├── mcp/                 ← $mcp: MCP server management
│       ├── migrate/             ← $migrate: database migration workflow
│       ├── mr/                  ← $mr: generate PR description
│       ├── plan/                ← $plan: create a task plan
│       ├── playwright/          ← $playwright: browser automation via MCP
│       ├── pr-triage/           ← $pr-triage: GitHub PR triage
│       ├── receiving-code-review/ ← $receiving-code-review: review reception
│       ├── repo-recap/          ← $repo-recap: PRs, issues, releases summary
│       ├── research/            ← $research: isolated codebase exploration
│       ├── resume/              ← $resume: restore session from todo.md
│       ├── review/              ← $review: 10-point code review
│       ├── root-cause-trace/    ← $root-cause-trace: deep trace methodology
│       ├── serena/              ← $serena: LSP rename/move across codebase
│       ├── serve/               ← $serve: start dev services locally
│       ├── squad-plan/          ← $squad-plan: multi-agent workstream plan
│       ├── status/              ← $status: project status dashboard
│       ├── subagent-driven-development/ ← $subagent-driven-development
│       ├── tdd/                 ← $tdd: red-green-refactor workflow
│       ├── test/                ← $test: run tests and report
│       ├── ticket/              ← $ticket: create ticket with evidence
│       ├── update-code-index/   ← $update-code-index: scan exports → CODE_INDEX.md
│       ├── worktree/            ← $worktree: git worktree management
│       ├── worktree-status/     ← $worktree-status: show all worktrees
│       └── writing-skills/      ← $writing-skills: craft effective SKILL.md files
│
└── brain/
    ├── architecture.md          ← Service map and data flow (fill in)
    ├── rules.md                 ← 25 golden rules + quality thresholds
    ├── build.md                 ← Build, test, lint commands (fill in)
    ├── terminal-safety.md       ← Full terminal safety reference
    ├── templates.md             ← PR/MR/commit/ticket templates
    ├── plugins.md               ← MCP tool catalog
    ├── cve-policy.md            ← CVE triage rules
    ├── decisions.md             ← Architectural decision log
    ├── tasks/
    │   ├── todo.md              ← Current task state
    │   ├── lessons.md           ← Accumulated session wisdom
    │   └── CODEX_ERRORS.md      ← Bug tracker
    └── scripts/                 ← Bootstrap and validation scripts
```

---

## Skills Reference

Invoke skills with `$skill-name` in any Codex session:

| Skill                          | Purpose                                           |
| ------------------------------ | ------------------------------------------------- |
| `$bootstrap`                   | Configure AGENTS.md for your specific project     |
| `$plan`                        | Write a task plan to brain/tasks/todo.md          |
| `$review`                      | Run 10-point code review                          |
| `$tdd`                         | Red-green-refactor workflow                       |
| `$debug`                       | 5-step root cause analysis                        |
| `$research`                    | Isolated codebase exploration                     |
| `$resume`                      | Restore context from last session                 |
| `$mr`                          | Generate PR description from diff                 |
| `$build`                       | Build and verify                                  |
| `$test`                        | Run tests and report failures                     |
| `$lint`                        | Lint and format check                             |
| `$checkpoint`                  | Save session state                                |
| `$maintain`                    | Fix stale brain/\*.md knowledge docs              |
| `$root-cause-trace`            | Deep 5-step trace from symptom to origin          |
| `$cross-layer-check`           | Verify symbol consistency across all layers       |
| `$worktree`                    | Git worktree management for parallel work         |
| `$brainstorming`               | Design workflow before writing any code           |
| `$careful`                     | Safety mode for destructive commands              |
| `$changelog`                   | Generate user-facing changelog from git log       |
| `$receiving-code-review`       | Code review reception protocol                    |
| `$repo-recap`                  | Repo state summary (PRs, issues, releases)        |
| `$subagent-driven-development` | Multi-agent implementation workflow               |
| `$cocoindex-code`              | Semantic code search via MCP                      |
| `$code-review-graph`           | Pre-PR blast radius + risk score via MCP          |
| `$playwright`                  | Browser automation via MCP (accessibility tree)   |
| `$serena`                      | LSP symbol rename/move across codebase via MCP    |
| `$issue-triage`                | GitHub issue triage — label, prioritize, assign   |
| `$pr-triage`                   | GitHub PR triage — risk, status, blockers         |
| `$writing-skills`              | Craft effective SKILL.md files (structure + QA)   |
| `$codebase-memory`             | Structural graph — call paths, dead code, ADRs    |
| `$ask`                         | Route codebase questions to MCP structural tools  |
| `$clean-worktrees`             | Remove merged git worktrees safely                |
| `$cleanup`                     | Clean build artifacts, deps cache, docker         |
| `$context`                     | Load domain-specific brain/ files by keyword      |
| `$db`                          | Non-interactive database queries                  |
| `$deps`                        | Manage dependencies and CVE audit                 |
| `$diff`                        | Git diff with merge-base (stat/full/files modes)  |
| `$docker`                      | Non-interactive Docker operations                 |
| `$git`                         | Git workflow with pre-push safety checklist       |
| `$health`                      | Codex config health check dashboard               |
| `$mcp`                         | MCP server management in config.toml              |
| `$migrate`                     | Database migration workflow with safety rules     |
| `$serve`                       | Start dev services (reads brain/build.md)         |
| `$squad-plan`                  | Multi-agent parallel workstream plan              |
| `$status`                      | Project status dashboard (budget, hooks, plugins) |
| `$ticket`                      | Create ticket description with evidence           |
| `$update-code-index`           | Scan exports → CODE_INDEX.md deduplication        |
| `$worktree-status`             | Show all git worktrees with status                |

---

## Subagents Reference

Codex can delegate to these specialized agents:

| Agent              | Purpose                                   | Reasoning |
| ------------------ | ----------------------------------------- | --------- |
| `explorer`         | Read-only codebase exploration            | Medium    |
| `reviewer`         | 10-point code review                      | High      |
| `plan-challenger`  | Adversarial plan critique                 | High      |
| `security-auditor` | 6-category security scan                  | High      |
| `session-reviewer` | Extract lessons to brain/tasks/lessons.md | Medium    |

---

## Hooks Reference

Hooks fire automatically at key lifecycle events:

| Hook                      | Event              | Purpose                                       |
| ------------------------- | ------------------ | --------------------------------------------- |
| `session-start.sh`        | SessionStart       | Injects todo.md, lessons.md, git status       |
| `config-protection.sh`    | PreToolUse (Bash)  | Blocks edits to protected config files        |
| `terminal-safety-gate.sh` | PreToolUse (Bash)  | Blocks dangerous terminal patterns            |
| `pre-commit-quality.sh`   | PreToolUse (Bash)  | Quality gate — checks before code changes     |
| `permission-audit.sh`     | PermissionRequest  | Logs permission requests for later review     |
| `post-bash-review.sh`     | PostToolUse (Bash) | Injects context when failures detected        |
| `prompt-guard.sh`         | UserPromptSubmit   | Scans prompts for accidentally pasted secrets |
| `tdd-loop-check.sh`       | Stop               | Blocks stopping if test failures detected     |
| `exit-nudge.sh`           | Stop               | Emits 6-item exit checklist before every stop |

| `warn-missing-test.sh` | Stop | Warns (strict profile) when session modified source files without tests |

Hooks require `[features] codex_hooks = true` in `.codex/config.toml` (experimental, enabled by default in this template).

---

## MCP Plugins (Optional)

Uncomment the relevant sections in `.codex/config.toml` to enable:

| Tool                  | Purpose                            | Requires          |
| --------------------- | ---------------------------------- | ----------------- |
| `cocoindex-code`      | Semantic code search               | Python 3.11+, uvx |
| `codebase-memory-mcp` | Structural graph + call traces     | Python 3.10+, uvx |
| `code-review-graph`   | Change risk analysis (0–100 score) | Python 3.10+, uvx |
| `serena`              | Symbol-level rename/refactor       | Python 3.11+, uvx |
| `playwright`          | Browser automation                 | Node.js 18+       |

Install: `bash brain/scripts/setup-plugins.sh --all`

---

## Customization

### Personal override

Copy `AGENTS.override.md.example` → `AGENTS.override.md` (gitignored) for personal instructions that don't belong in the shared `AGENTS.md`.

### Add domain knowledge

Create `brain/domain/` files for project-specific knowledge:

```
brain/domain/api.md        ← API conventions, auth, rate limits
brain/domain/database.md   ← Schema conventions, migration rules
brain/domain/messaging.md  ← Queue/event patterns
```

See `brain/_examples/` for templates.

### Upgrade

```bash
bash /tmp/codex-brain/install.sh /path/to/your-project
```

Upgrade mode preserves all your customizations and only adds missing components.

---

## Requirements

- **Codex CLI** — latest version with hooks support
- **git** — required for repo detection and hooks
- **jq** — recommended (hooks use it for JSON parsing; gracefully degrade without it)
- **bash 4+** — required for `discover.sh` and `populate-templates.sh` (macOS ships bash 3.2 — `brew install bash`)

---

## License

MIT — see [LICENSE](LICENSE)
