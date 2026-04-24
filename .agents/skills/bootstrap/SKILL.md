---
name: bootstrap
description: Auto-configure AGENTS.md and brain/ knowledge docs for a new project. Use when setting up Brain Bootstrap in a new repository. Discovers the codebase, fills in templates, and writes project-specific configuration.
---

# Bootstrap Skill

Auto-configure Codex Brain for a new project.

## When to use
- First time setting up Brain Bootstrap in a repository
- After running `install.sh` in a fresh repo
- When architecture docs are empty (`{{PLACEHOLDER}}` still present)

## Steps

### 1. Discover the codebase structure
```
Run: bash brain/scripts/discover.sh
```
This generates a JSON snapshot of directories, package managers, tech stack, and key entry points.

### 2. Read the discovery output
Open `brain/tasks/discovery.json` and analyze:
- Primary language(s) and frameworks
- Package manager (`npm`, `yarn`, `pnpm`, `pip`, `cargo`, `go mod`, etc.)
- Monorepo vs. single-service layout
- Build commands
- Test commands
- Key directories (src, lib, api, services, packages, etc.)

### 3. Fill in AGENTS.md
Replace all `{{PLACEHOLDER}}` tokens using the discovery data:
- `{{PROJECT_NAME}}` → actual project name
- `{{CRITICAL_PATTERNS}}` → project-specific rules discovered
- `{{KEY_DECISIONS}}` → any architectural decisions evident from the code

### 4. Fill in brain/architecture.md
Replace placeholders with actual:
- Directory layout table
- Service/module catalog
- Package aliases
- Infrastructure components

### 5. Fill in brain/build.md
Discover and document:
- Build commands (how to build)
- Test commands (how to run tests)
- Lint/format commands
- Development server commands
- Database migration commands (if applicable)

### 6. Fill in brain/rules.md
Add project-specific rules beyond the golden rules:
- Any patterns evident from existing code style
- Any non-obvious conventions in the codebase

### 7. Verify
Run `bash brain/scripts/validate.sh` to confirm all critical placeholders are resolved.

### 8. Commit
```
git add AGENTS.md brain/
git commit -m "chore: configure Brain Bootstrap for {{PROJECT_NAME}}"
```

## Output
- Updated `AGENTS.md` with project-specific content
- Updated `brain/architecture.md`, `brain/build.md`, `brain/rules.md`
- Populated `brain/tasks/todo.md` with first tasks
