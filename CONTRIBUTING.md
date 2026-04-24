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
