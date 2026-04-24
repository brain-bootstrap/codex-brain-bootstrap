---
name: context
description: Load all relevant brain/ knowledge files for a domain area. Use at session start or when switching to a new topic. Accepts a domain keyword like api, database, auth, build, security.
---

# Context Skill

Load all relevant brain/ knowledge files for a domain area before starting work.

## Usage

```
$context               # Load core context (architecture + rules + lessons)
$context api           # Load API-specific context
$context database      # Load database-specific context
$context auth          # Load auth-specific context
$context build         # Load build/CI context
$context security      # Load security/CVE context
```

## Domain → Files Mapping

Always read:
1. `brain/tasks/lessons.md` — accumulated wisdom from past sessions
2. `brain/architecture.md` — system overview
3. `brain/rules.md` — golden rules

Then based on keyword:

| Keyword | Files to read |
|---------|---------------|
| `build` / `test` / `CI` / `lint` | `brain/build.md` |
| `MR` / `PR` / `ticket` / `template` | `brain/templates.md` |
| `CVE` / `security` / `dependency` | `brain/cve-policy.md` |
| `terminal` / `command` / `shell` | `brain/terminal-safety.md` |
| `plugin` / `MCP` / `tool` | `brain/plugins.md` |

<!-- Add domain mappings as you create domain docs:
- `api` → `brain/domain/api.md`
- `database` → `brain/domain/database.md`
- `messaging` → `brain/domain/messaging.md`
-->

## After Loading

Provide a brief summary of the loaded context and ask what task to perform.
