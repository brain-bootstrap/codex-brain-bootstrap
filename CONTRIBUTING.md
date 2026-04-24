# Contributing to Codex Brain Bootstrap

Thanks for your interest in contributing!

## Philosophy

This project is a productivity system for Codex CLI. Contributions should make Codex sessions more effective, safer, or more ergonomic — not more complex.

**Guiding principle: Less is more.** Every new file, hook, or skill adds cognitive overhead for users. New additions must earn their place.

## Types of Contributions

### Hooks

New hooks should:

- Solve a specific, recurring problem (not a hypothetical one)
- Handle `jq` being absent gracefully (fail open, not closed)
- Be idempotent and safe to run on every tool call

### Skills

New skills should:

- Encode a reusable workflow, not a one-off task
- Be self-contained (readable without context)
- Include clear "when to use" guidance

### Brain docs

Updates to `brain/*.md` should:

- Be based on real-world experience with Codex sessions
- Be factual and concise (no filler)
- Keep files under 200 lines

### Bug fixes

Bug reports and fixes are always welcome. Please include:

- Codex CLI version
- OS and shell
- Exact steps to reproduce
- Expected vs actual behavior

## Development Workflow

```bash
# Clone the repo
git clone https://github.com/brain-bootstrap/codex-brain-bootstrap.git
cd codex-brain-bootstrap

# Validate your changes
bash brain/scripts/validate.sh

# Test install in a temp project
mkdir /tmp/test-project && git init /tmp/test-project
bash install.sh /tmp/test-project
bash /tmp/test-project/brain/scripts/validate.sh
```

## Contribution Standards

All contributions must:

1. **Follow the existing file format** — read 2-3 existing files before writing a new one
2. **Pass validation** — `bash brain/scripts/validate.sh` must pass
3. **Be cross-platform** — test on macOS and Linux; see Cross-Platform Requirements below
4. **Include a clear `description:`** in YAML frontmatter for skills, agents, and prompts
5. **Be named correctly** — skill names must match the directory name

## Skill Requirements

```yaml
---
name: my-skill # MUST match parent directory name exactly
description: 'What this skill does and when to use it'
invocation: '$my-skill' # how users invoke it in Codex chat
---
```

Invoke with `$skill-name` in Codex chat. For example, `$bootstrap` runs the bootstrap process.

Example — adding a new language (Kotlin):

```bash
# 1. Create skill directory
mkdir -p brain/skills/kotlin

# 2. Write the skill
cat > brain/skills/kotlin/SKILL.md << 'EOF'
---
name: kotlin
description: Kotlin-specific idioms — data classes, coroutines, extension functions
invocation: '$kotlin'
---
# Kotlin Skill
Use data classes instead of POJOs. Prefer coroutines over callbacks.
EOF

# 3. Validate
bash brain/scripts/validate.sh
```

## Hook Requirements

JSON format in `brain/hooks/` (snake_case event names for Codex CLI):

```json
{
  "hooks": {
    "pre_tool_use": [
      { "type": "command", "command": "bash brain/hooks/scripts/my-check.sh" }
    ]
  }
}
```

Hook scripts must:

- Use `set -uo pipefail`
- Handle `jq` being absent gracefully (fail open, not closed)
- Exit code 2 to block tool use
- Print reason to stderr when blocking
- Be idempotent and safe to run on every tool call

Codex CLI currently supports 10 hooks across 5 lifecycle events:
`pre_tool_use` · `post_tool_use` · `session_start` · `stop` · `subagent_stop`

## Code Style

- **Shell scripts**: `set -uo pipefail`; quote all variables; use `[[ ]]` not `[ ]`
- **Markdown**: ATX headings (`#`), no trailing spaces, one blank line between sections
- **YAML frontmatter**: always use single quotes for values with colons
- **JSON hooks**: 2-space indent, no trailing commas

## Cross-Platform Requirements

All shell scripts must run on:

- macOS (zsh default, bash available)
- Linux (bash, POSIX sh)

Portability rules:

- Use `#!/usr/bin/env bash` (never `#!/bin/bash` — not present on all macOS)
- No GNU-specific flags (e.g., `sed -i ''` on macOS vs `sed -i` on Linux)
- Use `command -v tool` not `which tool` for binary detection
- Test on both platforms before submitting

## CI Pipeline

The CI runs 5 checks on Ubuntu and macOS:

| Check          | Command                                                  | What it verifies                          |
| :------------- | :------------------------------------------------------- | :---------------------------------------- |
| Validation     | `bash brain/scripts/validate.sh`                         | All files present, no broken placeholders |
| ShellCheck     | `shellcheck brain/scripts/*.sh brain/hooks/scripts/*.sh` | Shell script quality                      |
| Portability    | `bash -n` on all scripts                                 | Syntax valid on bash                      |
| Cross-platform | macOS + Ubuntu matrix                                    | Scripts run on both platforms             |
| Install smoke  | Install to temp project                                  | Full install cycle works end-to-end       |

## Pull Request Process

1. Fork and create a branch: `feat/my-feature` or `fix/my-bug`
2. Make changes — read existing files first, match conventions
3. Run `bash brain/scripts/validate.sh` — all checks must pass
4. Run `shellcheck` on any `.sh` files you added or modified
5. Test install in a temp project (see Development Workflow above)
6. Open a PR — describe what changed and why

## Release Process (Maintainers only)

1. Update `CHANGELOG.md` — add version entry following Keep a Changelog format
2. Run full validation on macOS and Linux
3. Tag the release: `git tag vX.Y.Z -m "Release vX.Y.Z"`
4. Push tag — CI creates the GitHub release automatically

## Code of Conduct

Be kind. We're all here to make developer tooling better.

## Code Style

- Shell scripts: `set -euo pipefail`, quote all variables
- Markdown: clear headings, no walls of text
- No emoji in scripts (portability)
- Test on macOS (bash 3.2 compat via `#!/usr/bin/env bash` + auto-upgrade) and Linux

## Pull Requests

- One concern per PR
- Include a before/after for behavior changes
- Update CHANGELOG.md under `## [Unreleased]`
- Validate with `bash brain/scripts/validate.sh` before submitting
