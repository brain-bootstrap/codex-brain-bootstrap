# Changelog

All notable changes to Codex Brain Bootstrap are documented here.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)  
Versioning: [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

---

## [1.2.0] — 2026-04-25 — Skills Parity, Hooks Coverage & Install SOLO/TEAM

### Added

#### Skills

- **`.agents/skills/codeburn/`** — new skill: manage codeburn budget (token burn tracking, session cost awareness, context efficiency)

#### Hooks — 5 new event scripts (6 → 8 event types covered)

- **`.codex/hooks/subagent-stop.sh`** — SubagentStop event: log subagent completion, update token counters, surface findings summary
- **`.codex/hooks/permission-denied.sh`** — PermissionDenied event: log blocked operations, surface alternatives, prevent silent failures
- **`.codex/hooks/pre-compact.sh`** — PreCompact event: checkpoint current task state to brain/tasks/todo.md before context compaction
- **`.codex/hooks/on-compact.sh`** — OnCompact event: restore session context and task state after compaction completes
- **`.codex/hooks/edit-accumulator.sh`** — EditAccumulator event: track cumulative edit size across session, warn at thresholds

### Fixed

- **`.codex/hooks.json`** — added 5 new hook registrations for SubagentStop, PermissionDenied, PostToolUse, PreCompact, OnCompact, and EditAccumulator; hooks.json now covers all 8 event types (was 6)
- **`install.sh`** — SOLO/TEAM mode detection added: when `AGENTS.md` is already gitignored (SOLO repo), also gitignore `AGENTS.local.md` and `.codex/settings.local.toml`; TEAM repos leave these unignored for sharing
- **`brain/scripts/_platform.sh`** — `supports_unicode()` now detects `*utf8*` locale variant, macOS auto-pass, and `WT_SESSION` Windows Terminal; aligns with Claude reference implementation
- **`brain/scripts/validate.sh`** — domain-free check and template integrity section added; now validates `AGENTS.md` references no foreign platform terms

---

## [1.1.0] — 2026-04-24 — Full Parity & Audit Pass

### Fixed (Critical)

- `.codex/hooks.json` — **INVALID JSON** (trailing comma after PostToolUse array) prevented ALL 10 hooks from loading. Fixed.
- `.codex/hooks/prompt-guard.sh` — stdin field was `.userPrompt` (wrong); corrected to `.prompt` per official Codex API spec. Hook was silently non-functional.
- `brain/docs/DETAILED_GUIDE.md` — Hook registration example used a fictitious flat format; replaced with correct nested hooks.json structure.
- `brain/docs/DETAILED_GUIDE.md` — Blocking description corrected: `{"decision":"block","reason":"..."}` or exit code 2 (not "non-zero exit").

### Added

- `.codex/hooks/pre-commit-quality.sh` — PreToolUse hook that catches debugger statements, secrets, and merge conflict markers before commit.
- `.codex/hooks/permission-audit.sh` — PermissionRequest hook that logs permission escalation attempts.
- `.codex/hooks/prompt-guard.sh` — UserPromptSubmit hook that scans user prompts for accidentally pasted API keys and secrets (OpenAI, GitHub, AWS, Google, Anthropic, PEM keys) and blocks the prompt with a warning.
- `.codex/hooks/warn-missing-test.sh` — Stop hook that warns when source files were modified but no test files were touched (strict profile).
- `.agents/skills/` expanded from 16 to 48 skills — added: git, cocoindex-code, codebase-memory, code-review-graph, serena, playwright, ask, brainstorming, build, careful, changelog, clean-worktrees, cleanup, context, cross-layer-check, db, debug, deps, diff, docker, health, issue-triage, lint, maintain, mcp, migrate, plan, pr-triage, receiving-code-review, repo-recap, research, root-cause-trace, serve, squad-plan, status, subagent-driven-development, tdd, test, ticket, update-code-index, worktree-status, writing-skills.
- `.agents/skills/writing-skills/SKILL.md` — Added `agents/openai.yaml` optional metadata section (`allow_implicit_invocation`, UI metadata, tool dependencies).
- `brain/docs/DETAILED_GUIDE.md` — In-depth guide covering hooks, skills, subagents, configuration, MCP plugins, and best practices.
- `AGENTS.md` — Built-in system skills (`$skill-creator`, `$skill-installer`); `spawn_agents_on_csv` experimental batch; `agents.job_max_runtime_seconds`; `CODEX_HOME`; `project_doc_fallback_filenames`; `project_doc_max_bytes`; `[[skills.config]]` disable mechanism; `AGENTS.override.md`.
- `brain/plugins.md` — Full MCP config option reference: `tool_timeout_sec`, `enabled`, `required`, `enabled_tools`, `disabled_tools`, `env_vars`; `codex mcp add` CLI; `codex mcp login` OAuth.
- `.agents/skills/mcp/SKILL.md` — `codex mcp add` CLI usage; full STDIO and HTTP server config with all options.
- `brain/bootstrap/_config.toml.template` — Added `model`, `model_reasoning_effort`, `approval_policy`, `sandbox_mode`, `web_search`, `[agents]` section with `max_threads`/`max_depth`/`job_max_runtime_seconds`; `undo`, `memories`, `shell_snapshot` feature flags.

### Changed

- `.codex/hooks.json` — Updated hook count from 6 to 10 (added pre-commit-quality, permission-audit, prompt-guard, warn-missing-test).

---

## [1.0.0] — Initial Release

### Added

- `AGENTS.md` — Core brain file auto-loaded by Codex. Operating protocol, mandatory reads, subagent roster, skills roster, exit checklist, terminal rules, review protocol.
- `.codex/config.toml` — Project-level Codex configuration with hooks, MCP, and reasoning settings.
- `.codex/hooks.json` — Lifecycle hook registration for all 6 hook scripts.
- `.codex/hooks/session-start.sh` — Injects brain context (todo.md, lessons.md, git status) at session start.
- `.codex/hooks/config-protection.sh` — PreToolUse hook that blocks edits to protected config files.
- `.codex/hooks/terminal-safety-gate.sh` — PreToolUse hook that blocks dangerous terminal patterns.
- `.codex/hooks/post-bash-review.sh` — PostToolUse hook that injects failure context.
- `.codex/hooks/tdd-loop-check.sh` — Stop hook that prevents stopping when test failures are detected.
- `.codex/hooks/exit-nudge.sh` — Stop hook that emits the 6-item exit checklist.
- `.codex/rules/default.rules` — Starlark command approval rules (FORBIDDEN / PROMPT / ALLOW).
- `.codex/agents/` — 5 subagent definitions: explorer, reviewer, plan-challenger, security-auditor, session-reviewer.
- `.agents/skills/` — 16 skill files: bootstrap, plan, review, tdd, debug, research, resume, mr, build, test, lint, maintain, checkpoint, root-cause-trace, cross-layer-check, worktree.
- `brain/` — Knowledge layer: architecture, rules, build, terminal-safety, templates, plugins, cve-policy, decisions.
- `brain/tasks/` — Task state files: todo.md, lessons.md, CODEX_ERRORS.md.
- `brain/scripts/` — Bootstrap machinery: discover.sh, populate-templates.sh, validate.sh, bootstrap.sh, setup-plugins.sh.
- `install.sh` — Smart installer with FRESH/UPGRADE detection and safe merge logic.
- `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `LICENSE`.

### Added

- `AGENTS.md` — Core brain file auto-loaded by Codex. Operating protocol, mandatory reads, subagent roster, skills roster, exit checklist, terminal rules, review protocol.
- `.codex/config.toml` — Project-level Codex configuration with hooks, MCP, and reasoning settings.
- `.codex/hooks.json` — Lifecycle hook registration for all 6 hook scripts.
- `.codex/hooks/session-start.sh` — Injects brain context (todo.md, lessons.md, git status) at session start.
- `.codex/hooks/config-protection.sh` — PreToolUse hook that blocks edits to protected config files.
- `.codex/hooks/terminal-safety-gate.sh` — PreToolUse hook that blocks dangerous terminal patterns.
- `.codex/hooks/post-bash-review.sh` — PostToolUse hook that injects failure context.
- `.codex/hooks/tdd-loop-check.sh` — Stop hook that prevents stopping when test failures are detected.
- `.codex/hooks/exit-nudge.sh` — Stop hook that emits the 6-item exit checklist.
- `.codex/rules/default.rules` — Starlark command approval rules (FORBIDDEN / PROMPT / ALLOW).
- `.codex/agents/` — 5 subagent definitions: explorer, reviewer, plan-challenger, security-auditor, session-reviewer.
- `.agents/skills/` — 16 skill files: bootstrap, plan, review, tdd, debug, research, resume, mr, build, test, lint, maintain, checkpoint, root-cause-trace, cross-layer-check, worktree.
- `brain/` — Knowledge layer: architecture, rules, build, terminal-safety, templates, plugins, cve-policy, decisions.
- `brain/tasks/` — Task state files: todo.md, lessons.md, CODEX_ERRORS.md.
- `brain/scripts/` — Bootstrap machinery: discover.sh, populate-templates.sh, validate.sh, bootstrap.sh, setup-plugins.sh.
- `install.sh` — Smart installer with FRESH/UPGRADE detection and safe merge logic.
- `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `LICENSE`.
