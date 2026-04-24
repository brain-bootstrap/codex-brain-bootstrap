# Codex Brain — {{PROJECT_NAME}} Instructions

> **Non-negotiable.** Auto-loaded every session. Budget: <32KB. Detail in `brain/*.md` — read via file tool.
> At session start: read `brain/architecture.md` and `brain/rules.md` using the file tool.

## ⚠️ Mandatory Reads — You MUST consult before acting

**Session start →** read **`brain/tasks/todo.md`** + **`brain/tasks/lessons.md`** + **`brain/tasks/CODEX_ERRORS.md`**.

| If task involves…                                                                                | YOU MUST read FIRST                                                                                                           |
| ------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| _anything_ (first action)                                                                        | `brain/tasks/todo.md` + `brain/tasks/lessons.md` + `brain/tasks/CODEX_ERRORS.md` + `brain/architecture.md` + `brain/rules.md` |
| build, test, CI, lint, format, migration, local dev                                              | `brain/build.md`                                                                                                              |
| MR, PR, ticket, context management                                                               | `brain/templates.md`                                                                                                          |
| terminal, shell, subprocess, pager, interactive                                                  | `brain/terminal-safety.md`                                                                                                    |
| CVE, dependency upgrade, security scan                                                           | `brain/cve-policy.md`                                                                                                         |
| plugin, MCP, skill, subagent, memory                                                             | `brain/plugins.md`                                                                                                            |
| structural query, semantic search, cocoindex, code-review-graph, change risk, playwright, serena | `brain/plugins.md`                                                                                                            |

<!-- {{DOMAIN_LOOKUP_TABLE}} -->

## Operating Protocol (always active)

1. **Plan first** — write plan to `brain/tasks/todo.md` before non-trivial tasks (3+ steps or architectural decisions).
2. **Use subagents** — offload research/exploration to subagents (saves main context window).
3. **Prove completion** — run tests, check logs, demonstrate correctness.
4. **No hacky solutions** — find the elegant way. Ask "is there a more elegant way?" before committing.
5. **Fix bugs autonomously** — don't ask, just fix. Zero context switching from the user.
6. **Mark progress** — check items in `brain/tasks/todo.md` as you go.
7. **Evidence-based** — verify before stating. Distinguish pre-existing issues from introduced ones.
8. **Maintain knowledge autonomously** — update `brain/*.md` when you discover stale info. Stale docs are bugs.

## Reasoning Strategy

- **High effort by default** (`model_reasoning_effort = "high"` in config). Use it — it's there.
- Complex problems: decompose into sub-questions → confidence-weight each → combine → if overall confidence < 0.8, do more research.
- For planning, review, architecture: engage maximum reasoning. Don't shortcut.
- For routine tasks (build, grep, lint): minimal reasoning overhead is fine.

## Token Cost Strategy

- **Subagents** for exploration: `$research`, `$reviewer`, `$plan-challenger`, `$security-auditor` run in isolated context — main stays clean.
- **Read domain docs on-demand** from the lookup table, not preemptively.
- **Discard after use**: tool outputs, file reads (re-readable), intermediate research. Keep: decisions, corrections, test results.
- **Context pollution warning**: subagents prevent "context rot" — a single thread handling exploration + implementation degrades faster.

## Subagent Roster

| Skill                 | Invocation                            | Best for                                       |
| :-------------------- | :------------------------------------ | :--------------------------------------------- |
| `explorer` (built-in) | spawn via subagent request            | Read-only codebase mapping, evidence gathering |
| `reviewer`            | `.codex/agents/reviewer.toml`         | 10-point code review before PR                 |
| `plan-challenger`     | `.codex/agents/plan-challenger.toml`  | Adversarial plan stress-test                   |
| `security-auditor`    | `.codex/agents/security-auditor.toml` | Security scan, OWASP, secrets                  |
| `session-reviewer`    | `.codex/agents/session-reviewer.toml` | Extract lessons from session patterns          |

**Usage pattern:** "Spawn a reviewer subagent to review this PR. Focus on correctness and missing tests."

**Global subagent config** (`.codex/config.toml` under `[agents]`):

- `max_threads` (default 6) — concurrent open agent thread cap
- `max_depth` (default 1) — nesting depth; keep at 1 unless you need recursive delegation
- `job_max_runtime_seconds` — default per-worker timeout for `spawn_agents_on_csv` batch jobs

**Batch processing (experimental):** `spawn_agents_on_csv` spawns one worker per CSV row, waits for all, and exports results. Useful for bulk audits (e.g., one file/service per row).

## Skills Roster (`$skill-name`)

| Skill                         | Invocation                     | Use case                                             |
| :---------------------------- | :----------------------------- | :--------------------------------------------------- |
| `bootstrap`                   | `$bootstrap`                   | Auto-configure AGENTS.md for this repo               |
| `plan`                        | `$plan`                        | Plan non-trivial tasks with todo.md                  |
| `review`                      | `$review`                      | Full 10-point code review                            |
| `tdd`                         | `$tdd`                         | Write-test-first workflow                            |
| `debug`                       | `$debug`                       | Root cause analysis                                  |
| `research`                    | `$research`                    | Isolated codebase exploration                        |
| `resume`                      | `$resume`                      | Resume from brain/tasks/todo.md                      |
| `mr`                          | `$mr`                          | Generate MR/PR description                           |
| `build`                       | `$build`                       | Build + verify                                       |
| `test`                        | `$test`                        | Run tests + report                                   |
| `lint`                        | `$lint`                        | Lint + format check                                  |
| `maintain`                    | `$maintain`                    | Detect and fix stale brain/\*.md                     |
| `checkpoint`                  | `$checkpoint`                  | Save session state before compaction                 |
| `root-cause-trace`            | `$root-cause-trace`            | 5-step root cause methodology                        |
| `cross-layer-check`           | `$cross-layer-check`           | Verify field/enum across all layers                  |
| `worktree`                    | `$worktree`                    | Manage git worktrees for parallel work               |
| `brainstorming`               | `$brainstorming`               | Design workflow before writing any code              |
| `careful`                     | `$careful`                     | Safety mode for destructive commands                 |
| `changelog`                   | `$changelog`                   | Generate user-facing changelog from git              |
| `receiving-code-review`       | `$receiving-code-review`       | Code review reception protocol                       |
| `repo-recap`                  | `$repo-recap`                  | Repo state summary (PRs, issues, releases)           |
| `subagent-driven-development` | `$subagent-driven-development` | Multi-agent implementation workflow                  |
| `cocoindex-code`              | `$cocoindex-code`              | Semantic search via MCP (find code by meaning)       |
| `code-review-graph`           | `$code-review-graph`           | Pre-PR blast radius + risk score via MCP             |
| `playwright`                  | `$playwright`                  | Browser automation via MCP (accessibility tree)      |
| `serena`                      | `$serena`                      | LSP symbol rename/move across codebase via MCP       |
| `issue-triage`                | `$issue-triage`                | GitHub issue triage — label, prioritize, assign      |
| `pr-triage`                   | `$pr-triage`                   | GitHub PR triage — risk, status, blockers            |
| `writing-skills`              | `$writing-skills`              | Craft effective SKILL.md files (structure + QA)      |
| `$skill-creator` (built-in)   | `$skill-creator`               | Create a new skill interactively (system built-in)   |
| `$skill-installer` (built-in) | `$skill-installer`             | Install a skill from a URL or path (system built-in) |
| `codebase-memory`             | `$codebase-memory`             | Structural graph — call paths, dead code, ADRs       |
| `ask`                         | `$ask`                         | Route codebase questions to MCP structural tools     |
| `clean-worktrees`             | `$clean-worktrees`             | Remove merged git worktrees safely                   |
| `cleanup`                     | `$cleanup`                     | Clean build artifacts, deps cache, docker            |
| `context`                     | `$context`                     | Load domain-specific brain/ files by keyword         |
| `db`                          | `$db`                          | Non-interactive database queries                     |
| `deps`                        | `$deps`                        | Manage dependencies and CVE audit                    |
| `diff`                        | `$diff`                        | Git diff with merge-base (stat/full/files/commits)   |
| `docker`                      | `$docker`                      | Non-interactive Docker operations                    |
| `git`                         | `$git`                         | Git workflow with pre-push safety checklist          |
| `health`                      | `$health`                      | Codex config health check dashboard                  |
| `mcp`                         | `$mcp`                         | MCP server management in config.toml                 |
| `migrate`                     | `$migrate`                     | Database migration workflow with safety rules        |
| `serve`                       | `$serve`                       | Start dev services (reads brain/build.md)            |
| `squad-plan`                  | `$squad-plan`                  | Multi-agent parallel workstream plan                 |
| `status`                      | `$status`                      | Project status dashboard (budget, hooks, plugins)    |
| `ticket`                      | `$ticket`                      | Create ticket description with evidence              |
| `update-code-index`           | `$update-code-index`           | Scan exports → CODE_INDEX.md deduplication           |
| `worktree-status`             | `$worktree-status`             | Show all git worktrees with status                   |

**Disable a skill** without deleting it — add to `~/.codex/config.toml` or `.codex/config.toml`:

```toml
[[skills.config]]
path = "/path/to/.agents/skills/skill-name/SKILL.md"
enabled = false
```

## 🚨 Exit Checklist — BEFORE ending your turn (MANDATORY)

1. **User corrected me or revealed a missed pattern?** → Update `brain/tasks/lessons.md` + relevant `brain/*.md` NOW.
2. **Learned something new about codebase?** → Same.
3. **Open task in `brain/tasks/todo.md`?** → Mark progress.
4. **Did my work touch a domain?** → Verify relevant `brain/*.md` are still accurate. Fix NOW.
5. **Any new pattern, pitfall, or convention discovered?** → Add to most relevant doc + `brain/tasks/lessons.md`.
6. **Used shell commands this turn?** → Verify none triggered pagers, interactive mode, or unbounded output.

Do NOT yield until all six pass.

## Terminal Rules (CRITICAL — #1 cause of session hangs)

> Full reference: `brain/terminal-safety.md`.

- **🚨 PIPE `|` — 5 ABSOLUTE RULES:**
  1. **Shell regex**: `grep -E 'a|b'` ✅ — `grep -E "a|b"` ❌ — ALWAYS single quotes
  2. **Writing files**: use file-writing tool — NEVER heredoc in terminal (strips `|`)
  3. **Verifying files**: `grep -c '|' file` ✅ — `cat file` ❌ — display STRIPS `|`
  4. **Markdown tables**: `\|` inside cells — bare `|` outside tables
  5. **Shell scripts**: `case "$F" in *.js|*.ts)` ✅ — `grep -E '\.(js|ts)$'` ❌
- **NEVER** trigger a pager: always `git --no-pager` or `| cat`
- **NEVER** open interactive programs: no `vi`, `nano`, `psql` without `-c`
- **NEVER** `cd /path && command` — use absolute paths or run from project root
- **NEVER** dump unbounded output: always `| head -N`, `| tail -N`
- **ALWAYS** `--color=never` / `NO_COLOR=1` — disable ANSI codes
- **ALWAYS** `2>&1` — capture stderr alongside stdout
- **Short-lived** (test, grep, git): foreground. **Long-running** (server, watch): background.
- **After any terminal issue** → update `brain/terminal-safety.md` + `brain/tasks/lessons.md` immediately

## Critical Patterns (memorize)

- **Learning loop is an EXIT GATE** — check before every response
- **Explore → Plan → Act** — investigate codebase before coding, write failing tests before implementing
- **Temp files go in `./brain/tasks/`**, never `/tmp/` — clean them when obsolete
- **NEVER `git push` autonomously** — present summary + proposed command, wait for user confirmation
- **All proofs (build, test, scan) MUST pass** before generating any PR description
- **`$ARGUMENTS` in skills** — user input placeholder; explain how it's used if not obvious; always validate
<!-- {{CRITICAL_PATTERNS}} — Add your project-specific non-negotiable patterns here -->

## Key Decisions

> Settled architectural choices — do not re-litigate unless explicitly asked.
> Full rationale in `brain/decisions.md`.

<!-- {{KEY_DECISIONS}} -->

## Review Protocol (10-Point)

Before any PR, perform a full review covering:

1. **Ticket re-read** — verify every scenario addressed
2. **Cross-layer consistency** — DTO → backend → frontend → tests: grep every new field
3. **Enum completeness** — verify `switch`/`case` handles all enum values
4. **Transaction safety** — trace every write caller; confirm read callers don't write
5. **Race condition analysis** — trace concurrent flows
6. **Test scenario completeness** — every new branch/case has a dedicated test
7. **Pre-existing vs introduced** — distinguish lint/type warnings
8. **Cross-branch merge safety** — verify changes apply cleanly
9. **Security & side effects** — new external calls, data exposure, permissions, unsafe defaults
10. **100/100 confidence gate** — do not generate PR description until all above pass

## Hard Constraints (enforced unconditionally)

- **NEVER modify IDE config files** (`.idea/`, `.vscode/settings.json`) unless explicitly asked
- **NEVER `git push` without user confirmation** — present summary and wait
- **NEVER generate PR description before all proofs pass**
<!-- {{HARD_CONSTRAINTS}} -->

## Don't

<!-- {{DONT_LIST}} — Add project-specific anti-patterns here:
- Example: Don't add a new DB column without a migration script
- Example: Don't import ServiceA from ServiceB (creates circular dependency)
- Example: Don't use raw SQL outside of the repository layer
-->

## Compact Instructions

When context is running low, preserve: current task from `brain/tasks/todo.md` (title + unchecked steps), branch name + uncommitted files, which `brain/*.md` files were read, user corrections from this session, test results. Discard verbose tool output and intermediate research.

## Session Continuity Protocol

Before ending a session or when context is running low:

1. Write current state to `brain/tasks/todo.md` — title, checked/unchecked steps, next action.
2. If the user corrected you, update `brain/tasks/lessons.md` NOW (Exit Checklist gate).
3. Tell the user: "Session state saved to `brain/tasks/todo.md`. Next session: use `$resume`."

## Plugin Ecosystem

> Full reference: `brain/plugins.md`.

| Tool                    | Invocation                           | Notes                                                                              |
| ----------------------- | ------------------------------------ | ---------------------------------------------------------------------------------- |
| **MCP servers**         | `.codex/config.toml` `[mcp_servers]` | Declared per project — see brain/plugins.md                                        |
| **cocoindex-code**      | `$cocoindex-code`                    | Semantic search — find code by meaning. Skill: `.agents/skills/cocoindex-code/`    |
| **codebase-memory**     | `$codebase-memory`                   | Structural graph — call paths, dead code. Skill: `.agents/skills/codebase-memory/` |
| **code-review-graph**   | `$code-review-graph`                 | Pre-PR risk score 0–100. Skill: `.agents/skills/code-review-graph/`                |
| **serena**              | `$serena`                            | LSP-backed symbol rename/move. Skill: `.agents/skills/serena/`                     |
| **playwright**          | `$playwright`                        | Browser automation. Skill: `.agents/skills/playwright/`                            |
| **memories** (built-in) | `[features] memories = true`         | Cross-session recall — Codex native feature (not MCP)                              |

## Core Principles

Simplicity · No laziness (root cause, senior standards) · Surgical changes · Evidence-based

> **Personal overrides:** Create `AGENTS.override.md` at the repo root for personal instructions (not committed). Codex checks `AGENTS.override.md` before `AGENTS.md` at every directory level.
>
> **Custom home directory:** Set `CODEX_HOME=/path/to/dir` to point Codex at a different profile (e.g., a project-specific automation user).
>
> **Instruction discovery config** (in `~/.codex/config.toml`):
>
> - `project_doc_fallback_filenames = ["TEAM_GUIDE.md"]` — recognize custom filenames as AGENTS.md equivalents
> - `project_doc_max_bytes = 65536` — raise the 32 KiB default limit for large instruction sets
