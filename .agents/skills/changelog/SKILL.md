---
name: changelog
description: Generate a user-facing changelog from git commits — categorize, filter noise, translate to user language. Pass a tag or date as argument (e.g. "$changelog v1.0.0" or "$changelog 2026-01-01").
---

# $changelog — Changelog Generator

Generate a clean, categorized changelog from git commits. `$ARGUMENTS` = starting point (tag or date). Default: last 2 weeks.

## Process

### 1. Gather Commits

```bash
# From a tag
git --no-pager log --oneline --no-merges v1.0.0..HEAD 2>&1 | head -80

# From a date
git --no-pager log --oneline --no-merges --since="$ARGUMENTS" 2>&1 | head -80

# Default (last 2 weeks)
git --no-pager log --oneline --no-merges --since="2 weeks ago" 2>&1 | head -50
```

### 2. Categorize Changes

- **✨ New Features** — new functionality visible to users
- **🔧 Improvements** — enhanced existing functionality
- **🐛 Bug Fixes** — resolved defects
- **🔒 Security** — CVE fixes, dependency upgrades
- **⚠️ Breaking Changes** — API changes, schema migrations
- **📝 Documentation** — doc updates

### 3. Filter Noise

**Exclude**: refactoring, test-only changes, CI/CD changes, merge commits, lint formatting

### 4. Translate to User-Friendly Language

- Remove ticket prefixes (e.g., `[JIRA-123]`)
- Replace internal service names with user-facing terms
- Focus on **what changed for the user**, not how it was implemented

### 5. Output

```markdown
# Release Notes — [Version or Date]

## ✨ New Features
- **[Feature Name]**: [User-facing description]

## 🔧 Improvements
- **[Area]**: [What improved]

## 🐛 Bug Fixes
- Fixed [user-visible issue]

## 🔒 Security
- Updated [dependency] to fix [CVE-ID]
```

Write output to `brain/tasks/changelog-draft.md`.

Then tell the user: "Changelog draft written to `brain/tasks/changelog-draft.md`. Review and edit before publishing."
