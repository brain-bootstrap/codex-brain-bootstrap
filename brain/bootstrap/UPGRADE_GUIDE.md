# Bootstrap Upgrade Guide

> **Read this ONLY when performing an UPGRADE** (existing Codex Brain install detected).
> Follow these steps, then return to `brain/bootstrap/PROMPT.md` → Phase 3.

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

## Step 0: Dry Run Preview (MANDATORY)

> **See what will change BEFORE changing anything.**

```bash
bash brain/scripts/dry-run.sh . 2>&1
```

Review the output. If anything looks wrong, stop and investigate. The dry run changes nothing on disk.

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

## Step 4: Fill Remaining Placeholders

For any `{{PLACEHOLDER}}` tokens still present after the upgrade, do NOT re-run `$bootstrap` — that would loop back to discovery. Instead:

1. Run discovery directly: `bash brain/scripts/discover.sh . > brain/tasks/.discovery.env 2>&1`
2. Run populate: `bash brain/scripts/populate-templates.sh brain/tasks/.discovery.env .`
3. Then complete Phase 4 (domain detection + creative work) from `brain/bootstrap/PROMPT.md`

For AGENTS.md `{{CRITICAL_PATTERNS}}` — fill manually from codebase analysis (no script can do this).

---

## Step 5: Commit

```bash
git add AGENTS.md .codexignore .codex/ .agents/ brain/bootstrap/
git commit -m "chore: upgrade Codex Brain Bootstrap to latest"
```

---

> ✅ **Phase 2 complete.** Return to `brain/bootstrap/PROMPT.md` → Phase 3.

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
