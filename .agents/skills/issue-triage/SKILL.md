---
name: issue-triage
description: Use when you have open GitHub issues that need categorization, duplicate detection, staleness review, or triage comments — runs 3-phase workflow with mandatory user validation before posting. Args: "all" for deep analysis, issue numbers (e.g. "42 57"), "fr" for French, no arg = audit only.
---

# $issue-triage — GitHub Issue Triage

Workflow in 3 phases: automatic audit → opt-in deep analysis → actions with **mandatory user validation**.
No comments are posted without your explicit approval.

## When to Use

| Skill            | Usage                                    | Output                                         |
|------------------|------------------------------------------|------------------------------------------------|
| `$issue-triage`  | Triage, analyze, and comment on issues   | Action tables + deep analysis + posted comments |
| `$repo-recap`    | General recap to share with the team     | Markdown summary (PRs + issues + releases)     |

**Triggers**: manually, or proactively when >10 open issues without triage.

---

## Language

- Argument `fr` or `french` → output in French
- `en`, `english`, or no argument → English (default)
- GitHub comments (Phase 3) are **always in English** (international audience)

---

## Preconditions

```bash
git rev-parse --is-inside-work-tree
gh auth status
```

If either fails, stop and explain what's missing.

---

## Phase 1 — Audit (always runs)

### Data Gathering

```bash
gh repo view --json nameWithOwner -q .nameWithOwner
gh issue list --state open --limit 100 \
  --json number,title,author,createdAt,updatedAt,labels,assignees,body,comments
gh pr list --state open --limit 50 --json number,title,body
gh issue list --state closed --limit 20 --json number,title,labels,closedAt
gh api "repos/{owner}/{repo}/collaborators" --jq '.[].login' 2>/dev/null \
  || gh pr list --state merged --limit 10 --json author --jq '[.[].author.login] | unique | .[]'
```

**Note**: `author` is an object `{login: "..."}` — always extract `.author.login`.

### Analysis — 6 Dimensions

1. **Categorization**: Bug / Feature / Enhancement / Question / Duplicate Candidate
   - Bug: `crash`, `error`, `fail`, `broken`, `regression`, `wrong`, `unexpected`
   - Feature: `add`, `implement`, `support`, `new`, `feat:`
2. **Cross-ref PRs**: scan PR bodies for `fixes #N`, `closes #N`, `resolves #N`
3. **Duplicate detection**: Jaccard similarity > 60% on normalized titles = duplicate candidate
4. **Risk**: Red (CVE/auth bypass/injection), Yellow (breaking change/migration), Green (other)
5. **Staleness**: >30d no activity = Stale; >90d = Very Stale
6. **Action**: Accept / Label needed / Comment needed / Linked to PR / Duplicate / Close candidate

### Output — 5 Tables

```
## Open Issues ({count})
### Critical (red risk)
### Linked to a PR
### Active
### Duplicate Candidates
### Stale
### Summary: total, critical, duplicate candidates, stale, quick wins
```

Then copy output to clipboard (pbcopy / xclip / wl-copy fallback chain).

---

## Phase 2 — Deep Analysis (opt-in)

**If argument passed**: `"all"` = all issues; `"42 57"` = specific issues.

**If no argument**: ask user which to analyze. If "Skip" → end workflow.

Spawn a `research` subagent per issue. Each returns:
- Scope Assessment, Missing Info, Risk & Impact, Effort (XS/S/M/L/XL), Priority (P0-P3), Recommended Action, Draft Comment.

---

## Phase 3 — Actions (mandatory validation)

Show **all drafts** before executing anything. Ask user which to execute.

```bash
gh issue comment {num} --body "{comment}"  # after approval
gh issue edit {num} --add-label "{label}"  # skip if already present
gh issue close {num} --reason "not planned"  # only after explicit approval
```

**Rules**: Never close a collaborator's issue. Never re-label. Never post without confirmation.

---

## Edge Cases

| Situation | Behavior |
|-----------|----------|
| 0 open issues | Display "No open issues." and finish |
| Issue without body | Categorize by title only |
| Collaborators API 403 | Fallback to authors of last 10 merged PRs |
| PR merged → issue open | Recommend closing |
| False positive duplicate | Phase 2 confirms — never act on suspicion alone |
