---
name: repo-recap
description: Generate a comprehensive repo recap (PRs, issues, releases) ready to share with the team. Pass "fr" for French output (default is English).
---

# $repo-recap — Repository State Summary

Generate a structured recap of the repository state: open PRs, open issues, recent releases, and executive summary. Output is formatted as Markdown with clickable GitHub links, ready to share.

## Language

- `$ARGUMENTS` = `fr` or `french` → produce the recap in French
- `$ARGUMENTS` = `en`, `english`, or empty → English (default)

## Preconditions

Before gathering data, verify:

```bash
git rev-parse --is-inside-work-tree 2>/dev/null && echo "✅ git repo" || echo "❌ not a git repo"
gh auth status 2>&1 | head -3
```

If either fails, stop and tell the user what's missing.

## Steps

### 1. Gather Data

Run these commands via `gh` CLI:

```bash
# Repo identity (for links)
gh repo view --json nameWithOwner -q .nameWithOwner

# Open PRs with metadata
gh pr list --state open --limit 50 --json number,title,author,createdAt,changedFiles,additions,deletions,reviewDecision,isDraft

# Open issues with metadata
gh issue list --state open --limit 50 --json number,title,author,createdAt,labels,assignees

# Recent releases
gh release list --limit 5

# Recently merged PRs (for contributor activity)
gh pr list --state merged --limit 10 --json number,title,author,mergedAt
```

Note: `author` in JSON results is an object `{login: "..."}` — always extract `.author.login`.

### 2. Analyze and Categorize PRs

**Size labels:**

| Label | Additions |
|-------|-----------|
| XS | < 50 |
| S | 50-200 |
| M | 200-500 |
| L | 500-1000 |
| XL | > 1000 |

**Categorize into 3 groups:**

- **Our PRs** (repo collaborator as author) — list with PR number, title, size, status
- **External — Reviewable** (additions ≤ 1000 AND files ≤ 10, no major blockers) — include recommended action
- **External — Problematic** (too large, CI failing, merge conflict, overlap) — include specific problem

**Detect overlaps:** Two PRs overlap if they modify the same files (use `changedFiles`). If >50% file overlap between 2 PRs, flag both.

### 3. Categorize Issues

- **In progress**: has an associated open PR
- **Quick fix**: small scope, actionable (bug reports, small enhancements)
- **Feature request**: larger scope, needs design discussion

### 4. Executive Summary (5-6 bullets)

- Total open PRs and issues
- Active contributors
- Main risks (oversized PRs, CI failures, conflicts)
- Quick wins (small PRs ready to merge)
- Bug fixes needed

### 5. Format and Copy to Clipboard

```bash
# Copy to clipboard (cross-platform)
clip() {
  if command -v pbcopy &>/dev/null; then pbcopy
  elif command -v xclip &>/dev/null; then xclip -selection clipboard
  elif command -v wl-copy &>/dev/null; then wl-copy
  else cat
  fi
}
```

## Output Template (EN)

```markdown
# {Repo Name} — Recap {date}

## Recent Releases

| Version | Date | Highlights |
|---------|------|------------|

---

## Open PRs ({count} total)

### Our PRs

| PR | Title | Size | Status |
|----|-------|------|--------|

### External — Reviewable

| PR | Author | Title | Size | Status | Action |
|----|--------|-------|------|--------|--------|

### External — Problematic

| PR | Author | Title | Size | Problem | Action |
|----|--------|-------|------|---------|--------|

---

## Open Issues ({count} total)

| # | Author | Topic | Priority |
|---|--------|-------|----------|

---

## Executive Summary

- **Point 1**: ...
```

## Notes

- Always use `gh` CLI, not the GitHub API directly
- Keep tables compact — truncate long titles at ~60 chars
- Cross-reference overlapping PRs/issues whenever possible
- `author` in gh JSON is an object — always use `.author.login`
