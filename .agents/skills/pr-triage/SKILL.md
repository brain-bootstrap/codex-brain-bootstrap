---
name: pr-triage
description: Use when you have open GitHub PRs that need categorization, overlap detection, risk review, or code review comments — runs 3-phase workflow with mandatory user validation before posting. Args: "all" to review all, PR numbers (e.g. "42 57"), "fr" for French, no arg = audit only.
---

# $pr-triage — GitHub PR Triage

Workflow in 3 phases: automatic audit → opt-in deep review → review comments with **mandatory user validation**.
No comments are posted without your explicit approval.

## When to Use

| Skill          | Usage                                  | Output                                       |
|----------------|----------------------------------------|----------------------------------------------|
| `$pr-triage`   | Triage, review, and comment on PRs     | Action table + reviews + posted comments     |
| `$repo-recap`  | General recap to share with the team   | Markdown summary (PRs + issues + releases)   |

**Triggers**: manually, or proactively when >5 open PRs without review or PR stale >14d.

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
gh pr list --state open --limit 50 \
  --json number,title,author,createdAt,updatedAt,additions,deletions,changedFiles,\
isDraft,mergeable,reviewDecision,statusCheckRollup,body
gh api "repos/{owner}/{repo}/collaborators" --jq '.[].login' 2>/dev/null \
  || gh pr list --state merged --limit 10 --json author --jq '[.[].author.login] | unique | .[]'
# For each PR — files and reviews (N API calls, prioritize overlap candidates):
gh api "repos/{owner}/{repo}/pulls/{num}/reviews" \
  --jq '[.[] | .user.login + ":" + .state] | join(", ")'
gh pr view {num} --json files --jq '[.files[].path] | join(",")'
```

### Size Classification

| Label | Additions |
|-------|-----------|
| XS | < 50 |
| S | 50–200 |
| M | 200–500 |
| L | 500–1000 |
| XL | > 1000 |

### Detections

- **Overlaps**: >50% files in common between 2 PRs → cross-reference
- **Clusters**: author with 3+ open PRs → suggest review order (smallest first)
- **Staleness**: no activity >14d → flag
- **CI**: `statusCheckRollup` → `clean` / `unstable` / `dirty` / `?`
- **PR ↔ Issue links**: scan body for `fixes #N`, `closes #N`, `resolves #N`

### Categorization

- **Our PRs**: author in collaborators list
- **External — Ready**: additions ≤ 1000, files ≤ 10, `mergeable` ≠ `CONFLICTING`, CI clean/unstable
- **External — Problematic**: XL, or merge conflict, or dirty CI, or >50% file overlap

### Output

```
## Open PRs ({count})
### Our PRs      | PR | Title | Size | CI | Status |
### External — Ready    | PR | Author | Title | Size | CI | Reviews | Action |
### External — Problematic   | PR | Author | Title | Size | Problem | Action |
### Summary: quick wins, risks, clusters, stale, overlaps
```

Then copy output to clipboard.

---

## Phase 2 — Deep Review (opt-in)

**If argument passed**: `"all"` = all external PRs; `"42 57"` = specific PRs.
Draft PRs excluded unless explicitly numbered.

**If no argument**: ask user. If "Skip" → end workflow.

Spawn a `reviewer` subagent per PR. Fetch diff via:
```bash
gh pr diff {num}
gh pr view {num} --json body,title,author -q '{body: .body, title: .title, author: .author.login}'
```

Each reviewer returns: Critical Issues 🔴 / Important Issues 🟡 / Suggestions 🟢 / What's Good ✅.
Cite `file.ext:42` for specific issues.

---

## Phase 3 — Comments (mandatory validation)

Show **all drafts** before posting anything. Ask user which to post.

```bash
gh pr comment {num} --body "{comment}"  # after approval only
```

**Rules**: English only for comments. Always include at least 1 positive point. Never post without confirmation.

---

## Edge Cases

| Situation | Behavior |
|-----------|----------|
| 0 open PRs | Display "No open PRs." and finish |
| Draft PR | Flag in table; skip for review unless explicitly numbered |
| `gh pr diff` empty | Skip that PR, notify user |
| Very large PR (>5000 additions) | Warn "Partial review, diff may be truncated" |
| Collaborators API 403 | Fallback to authors of last 10 merged PRs |
| `statusCheckRollup` null | Treat as `?` |
