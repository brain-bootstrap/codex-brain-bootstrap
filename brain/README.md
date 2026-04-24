# brain/ — Knowledge Base Overview

The `brain/` directory is the **persistent knowledge layer** for this project. Codex reads these files on demand (and the session-start hook injects the most critical ones automatically).

## File Index

| File                 | Purpose                                     | Read when...                              |
| -------------------- | ------------------------------------------- | ----------------------------------------- |
| `architecture.md`    | Service map, directory structure, data flow | Any task touching project structure       |
| `rules.md`           | 25 golden rules + quality thresholds        | Every session                             |
| `build.md`           | Build, test, lint commands                  | Building, testing, CI                     |
| `terminal-safety.md` | Full terminal safety reference              | Any shell command                         |
| `templates.md`       | PR/MR/commit/ticket templates               | Opening a PR, writing a commit            |
| `plugins.md`         | MCP tool catalog and configuration          | Using semantic search, review graph, etc. |
| `cve-policy.md`      | CVE triage and dependency upgrade rules     | Security scans, dependency updates        |
| `decisions.md`       | Append-only architectural decision log      | Making a significant tech choice          |

## Task Files

| File                    | Purpose                                                     |
| ----------------------- | ----------------------------------------------------------- |
| `tasks/todo.md`         | Current task state — updated every session                  |
| `tasks/lessons.md`      | Accumulated wisdom — patterns discovered across sessions    |
| `tasks/CODEX_ERRORS.md` | Bug tracker — structured error log with promotion lifecycle |

## Docs

| File                     | Purpose                                                       |
| ------------------------ | ------------------------------------------------------------- |
| `docs/DETAILED_GUIDE.md` | Comprehensive deep-dive guide — architecture, config, plugins |

## Scripts

| Script                               | Purpose                                            |
| ------------------------------------ | -------------------------------------------------- |
| `scripts/validate.sh`                | Full project health check (104+ checks)            |
| `scripts/canary-check.sh`            | Quick session-start health pulse                   |
| `scripts/discover.sh`                | Auto-discover project structure                    |
| `scripts/populate-templates.sh`      | Fill {{PLACEHOLDER}} tokens in templates           |
| `scripts/dry-run.sh`                 | Preview bootstrap migration (no writes)            |
| `scripts/migrate-tasks.sh`           | Migrate task files to new structure                |
| `scripts/merge-agents-md.sh`         | Merge AGENTS.md from multiple sources              |
| `scripts/merge-codexignore.sh`       | Merge .codexignore from multiple sources           |
| `scripts/post-bootstrap-validate.sh` | Run after bootstrap to confirm everything is wired |
| `scripts/generate-service-agents.sh` | Generate AGENTS.md stubs for monorepo services     |
| `scripts/phase2-verify.sh`           | Phase 2 deep verification                          |
| `scripts/setup-plugins.sh`           | Install and configure MCP plugins                  |
| `scripts/portability-lint.sh`        | Check for non-portable shell patterns              |
| `scripts/integration-test.sh`        | End-to-end integration tests                       |
| `scripts/_platform.sh`               | Shared platform detection utilities                |

## Domain Files (optional)

Place domain-specific knowledge in `brain/domain/`:

- `brain/domain/api.md` — API conventions, auth patterns, rate limits
- `brain/domain/database.md` — Schema conventions, migration rules, query patterns
- `brain/domain/messaging.md` — Queue/event patterns, retry policies

See `brain/_examples/` for templates.

## Conventions

- All files use Markdown
- Keep each file under 200 lines — split by responsibility if larger
- Files with `{{PLACEHOLDER}}` tokens need to be filled in (run `$bootstrap`)
- Update `tasks/lessons.md` after every session where something new was learned
