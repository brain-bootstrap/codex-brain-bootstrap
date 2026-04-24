---
name: careful
description: Activate safety mode — review every destructive command before running. Use before working on production infrastructure, migration scripts, or any task where a typo could be catastrophic.
---

# $careful — Destructive Command Safety Mode

Activate this skill before any high-stakes operation. It triggers a mandatory self-check before every potentially destructive command.

## What This Skill Does

When you invoke `$careful`, you commit to the following protocol for the rest of the task:

**Before running ANY command matching the patterns below, STOP and explicitly ask the user for confirmation:**

| Pattern | Risk |
|---------|------|
| `rm -rf /` or `rm -rf *` | Filesystem destruction |
| `DROP TABLE` / `DROP DATABASE` / `TRUNCATE` | Data loss |
| `git push --force` / `git push -f` | Rewrites shared history |
| `kubectl delete namespace` | Destroys entire cluster namespace |
| `docker system prune` / `docker volume prune` | Removes images, volumes |
| `npm publish` / `pip publish` / `cargo publish` | Accidental public release |
| `git reset --hard` | Discards uncommitted work |
| Any `DELETE FROM` without a `WHERE` clause | Full table deletion |
| Any migration `down` / `rollback` command | Data schema revert |

## Activation Protocol

When the user types `$careful`:
1. Acknowledge: "Safety mode active. I will confirm before running any destructive command."
2. For the rest of this task, before any matching command, output: `⚠️ DESTRUCTIVE: [command]. Proceed? (yes/no)`
3. Wait for explicit confirmation before running.
4. NEVER auto-approve. NEVER reason that "context makes it safe."

## When to Use

Activate before:
- Production infrastructure work
- Database migrations (especially down/rollback)
- Bulk file operations
- Release / publish workflows
- Any task where "undo" doesn't exist

## How to Deactivate

Safety mode ends when:
- The user says "deactivate careful" or "cancel careful"
- The session ends

## Relationship to Pre-commit-quality Hook

The `.codex/hooks/pre-commit-quality.sh` hook already blocks secrets/debugger commits automatically.
`$careful` extends safety to all interactive destructive commands — complementary, not redundant.
