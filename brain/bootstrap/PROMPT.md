# Bootstrap Prompt

Use this prompt when starting Codex Brain Bootstrap for the first time in a new project. Paste it into a Codex session after running `install.sh`.

---

## The Prompt

````
You are bootstrapping the Codex Brain for this project. Your job is to fill in the knowledge base so future Codex sessions can work effectively without re-discovering the codebase.

## Step 1 — Discover the project

Run the discovery script:
```bash
bash brain/scripts/discover.sh . > brain/tasks/.discovery.env 2>&1
````

Then read the output.

## Step 2 — Populate mechanical placeholders

Run:

```bash
bash brain/scripts/populate-templates.sh brain/tasks/.discovery.env .
```

## Step 3 — Fill in architecture knowledge (your job, not a script)

Read the codebase (top-level dirs, key files, README if any) and fill in brain/architecture.md:

- Service/module catalog
- Directory layout
- Key infrastructure (DB, queue, cache)
- Data flow summary

Do NOT guess — only write what you can verify from the codebase.

## Step 4 — Fill in build commands

Read package.json / Makefile / pyproject.toml and verify the commands in brain/build.md are accurate.
Run each command to confirm it works. Fix any that don't.

## Step 5 — Identify project-specific rules

Are there any critical constraints unique to this project that should be in AGENTS.md?
Examples:

- "Never emit side effects inside a DB transaction"
- "Two DBs: write (mutations) + read (queries) — never mix"
- "Service X must not be imported by Service Y"

Add them to AGENTS.md → ## Critical Patterns section.

## Step 6 — Validate

Run:

```bash
bash brain/scripts/validate.sh
```

All checks must pass before you declare bootstrap complete.

## Step 7 — Report

Tell me:

1. What you found (services, tech stack, key patterns)
2. What you filled in
3. Any {{PLACEHOLDER}} tokens still remaining and why
4. Any warnings or gaps in the knowledge base

```

---

## What the Bootstrap Produces

After a successful bootstrap:
- `brain/architecture.md` — filled with real service map and data flow
- `brain/build.md` — filled with verified commands
- `AGENTS.md` — {{PROJECT_NAME}} replaced, project-specific rules added
- `brain/tasks/todo.md` — initial "Bootstrap complete" entry
- `brain/scripts/validate.sh` — all checks green
```
