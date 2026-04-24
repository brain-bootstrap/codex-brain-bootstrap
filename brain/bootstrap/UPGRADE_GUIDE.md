# Bootstrap Upgrade Guide

> **Read this ONLY when performing an UPGRADE** (existing Codex Brain install detected).
> Follow these steps, then return to `brain/bootstrap/PROMPT.md` → Step 6 (Verify).

---

> **SACRED RULE: NEVER LOSE USER DATA.** Domain knowledge in `brain/*.md`, lessons, task state, and error logs are irreplaceable. The upgrade NEVER touches them.

## Pre-Upgrade Safety Check

`install.sh` creates a backup automatically before touching anything. Verify it exists:

```bash
ls -lh brain/tasks/.pre-upgrade-backup.tar.gz 2>/dev/null && echo "✅ Backup exists" || echo "⚠️  No backup found"
```

If no backup exists (you copied files manually without `install.sh`), create one now:

```bash
tar czf brain/tasks/.pre-upgrade-backup.tar.gz AGENTS.md .codexignore .codex/ .agents/ brain/ 2>/dev/null || true
echo "✅ Pre-upgrade backup saved to brain/tasks/.pre-upgrade-backup.tar.gz"
```

Restore at any time:

```bash
tar xzf brain/tasks/.pre-upgrade-backup.tar.gz
```

---

## Step 1: Review What Changed

```bash
# See which infrastructure files were updated
git diff HEAD -- .codex/ .agents/ brain/bootstrap/ AGENTS.md .codexignore
```

Look for:

- New hooks added to `.codex/hooks/` → verify they're registered in `.codex/hooks.json`
- New skills added to `.agents/skills/` → verify they're listed in `AGENTS.md` Skills Roster
- New agents added to `.codex/agents/` → verify they're listed in `AGENTS.md` Subagent Roster
- Changes to `.codex/rules/default.rules` → review new approval rules carefully

---

## Step 2: Merge Any New AGENTS.md Sections

The `install.sh` upgrade mode DOES NOT overwrite your `AGENTS.md` — it preserves your customizations.

But new sections may have been added to the template. Compare yours against the template:

```bash
diff AGENTS.md brain/bootstrap/_AGENTS.md.template | head -60
```

For each section present in the template but missing in your AGENTS.md:

1. Decide if it's relevant to your project
2. If yes: copy the section into your AGENTS.md and fill in `{{PLACEHOLDERS}}`

---

## Step 3: Validate

```bash
bash brain/scripts/validate.sh
```

All checks must pass (0 failures). Warnings about unfilled `{{PLACEHOLDER}}` tokens are expected if you haven't run `$bootstrap` yet.

---

## Step 4: Fill New Placeholders

If new sections were added with `{{PLACEHOLDER}}` tokens, run the bootstrap skill to fill them:

```
$bootstrap
```

---

## Step 5: Commit

```bash
git add AGENTS.md .codexignore .codex/ .agents/ brain/bootstrap/
git commit -m "chore: upgrade Codex Brain Bootstrap to latest"
```

---

## What the Upgrade Preserves (NEVER touched)

| File / Directory              | Contents               | Protected            |
| ----------------------------- | ---------------------- | -------------------- |
| `brain/architecture.md`       | Your architecture docs | ✅ Never overwritten |
| `brain/build.md`              | Your build commands    | ✅ Never overwritten |
| `brain/rules.md`              | Your project rules     | ✅ Never overwritten |
| `brain/plugins.md`            | Your plugin config     | ✅ Never overwritten |
| `brain/tasks/todo.md`         | Current task state     | ✅ Never overwritten |
| `brain/tasks/lessons.md`      | Accumulated wisdom     | ✅ Never overwritten |
| `brain/tasks/CODEX_ERRORS.md` | Bug history            | ✅ Never overwritten |
| `AGENTS.md`                   | Your customized brain  | ✅ Never overwritten |

## What the Upgrade Updates

| File / Directory             | Contents            | Upgrade behavior              |
| ---------------------------- | ------------------- | ----------------------------- |
| `.codex/hooks/*.sh`          | Hook scripts        | Updated to latest version     |
| `.codex/hooks.json`          | Hook registration   | Updated to register new hooks |
| `.codex/rules/default.rules` | Approval rules      | Updated to latest policies    |
| `.codex/agents/*.toml`       | Agent definitions   | Updated instructions          |
| `.agents/skills/*/SKILL.md`  | Skill definitions   | Updated workflows             |
| `brain/bootstrap/`           | Bootstrap templates | Updated templates             |
| `install.sh`                 | Installer           | Updated                       |
