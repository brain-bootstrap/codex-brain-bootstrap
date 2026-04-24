---
name: writing-skills
description: Use when creating new skill files, editing existing SKILL.md files, or reviewing skills before deployment — covers structure, discoverability, and quality standards for Codex skills.
---

# $writing-skills — Creating & Maintaining Skills

## Overview

A **skill** is a reference guide for proven techniques, patterns, or tools. Skills help Codex find and apply effective approaches without being retrained.

**Skills are:** Reusable techniques, patterns, tools, reference guides  
**Skills are NOT:** Narratives about one-time solutions, project-specific conventions (those go in `AGENTS.md`)

---

## SKILL.md Structure

**Frontmatter (YAML):**
- Required fields: `name`, `description`
- `name`: letters, numbers, hyphens only — no parentheses or special chars
- `description`: describes ONLY when to use (NOT what the skill does) — see Discovery section

```markdown
---
name: skill-name
description: Use when [specific triggering conditions and symptoms]
---

# Skill Name

## Overview
Core principle in 1-2 sentences.

## When to Use
Bullet list with symptoms and use cases. When NOT to use.

## Core Pattern
Workflow steps or before/after comparison.

## Quick Reference
Table or bullets for scanning.

## Common Mistakes
What goes wrong + fixes.
```

---

## Discovery: The `description` Field

**The description is the discovery mechanism.** Codex reads it to decide which skills to load.

### Description = Triggering Conditions ONLY

**NEVER summarize the skill's workflow in the description.**

**Why it matters:** When a description summarizes workflow, Codex follows the description INSTEAD of reading the full skill body. This causes it to skip crucial steps.

```yaml
# BAD: Summarizes workflow — Codex may follow this instead of reading the skill body
description: Use when executing plans - dispatches subagent per task with code review between tasks

# GOOD: Just triggering conditions
description: Use when executing implementation plans with independent tasks in the current session
```

**Rules:**
- Start with "Use when..."
- Include specific symptoms, situations, contexts
- Technology-agnostic unless the skill is technology-specific
- Keep under 500 characters

---

## Keyword Coverage

Include words Codex would search for:
- Error messages: "race condition", "hook timed out"
- Symptoms: "flaky tests", "hanging session", "zombie process"
- Tools: actual command names (`gh`, `git`, `uvx`)

---

## Token Efficiency

Skills that load frequently must be concise.

| Skill type | Target word count |
|------------|-------------------|
| Frequently-loaded workflows | < 200 words |
| Reference skills | < 500 words |

Techniques:
- Reference `--help` instead of documenting all flags
- Cross-reference other skills instead of repeating content
- One excellent code example beats five mediocre ones

---

## Skill Types

| Type | Description | Examples |
|------|-------------|---------|
| Technique | Concrete method with steps | `root-cause-trace`, `cross-layer-check` |
| Pattern | Way of thinking about problems | `careful`, `tdd` |
| Reference | API docs, tool documentation | `playwright`, `cocoindex-code` |

---

## Directory Structure

```
.agents/skills/
  skill-name/
    SKILL.md              # Main reference (required)
    supporting-file.*     # Only if needed for heavy reference or reusable tools
    agents/
      openai.yaml         # Optional: UI metadata, invocation policy, tool deps
```

**`agents/openai.yaml` (optional)** — adds Codex app UI metadata and invocation control:

```yaml
interface:
  display_name: "Optional user-facing name"
  short_description: "Optional short description"
  icon_small: "./assets/small-logo.svg"
  default_prompt: "Optional default prompt when skill is invoked"

policy:
  allow_implicit_invocation: false  # Default: true. Set false to disable auto-trigger

dependencies:
  tools:
    - type: "mcp"
      value: "openaiDeveloperDocs"
      description: "OpenAI Docs MCP server"
      transport: "streamable_http"
      url: "https://developers.openai.com/mcp"
```

> `allow_implicit_invocation: false` prevents Codex from automatically choosing this skill — explicit `$skill-name` invocation still works. Use for skills that must only run on demand.

Keep inline: concepts, code patterns < 50 lines.  
Separate file for: heavy reference (100+ lines), reusable scripts/templates.

---

## Quality Checklist

Before deploying any skill:

- [ ] `name` uses only letters, numbers, hyphens
- [ ] `description` starts with "Use when..." — no workflow summary
- [ ] Description is under 500 characters
- [ ] Keywords throughout for discoverability
- [ ] Clear overview with core principle
- [ ] No narrative storytelling ("in session 2026-01-03 we found...")
- [ ] One excellent example (not multi-language)
- [ ] New skill added to Skills Roster in `AGENTS.md`

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Description summarizes workflow | Rewrite as triggering conditions only |
| Multiple language examples | Pick the most relevant language |
| Narrative storytelling | Convert to reusable technique/pattern |
| Project-specific rules in skill | Move to `AGENTS.md` |
| Skill not listed in AGENTS.md | Add to Skills Roster immediately |

---

## When to Create a Skill

**Create when:**
- Technique wasn't intuitively obvious
- You'd reference this again across projects
- Pattern applies broadly (not project-specific)

**Don't create for:**
- One-off solutions
- Standard practices documented elsewhere
- Project-specific conventions → `AGENTS.md` instead
