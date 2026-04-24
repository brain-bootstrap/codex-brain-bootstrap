# Bootstrap Prompt — ᗺB Brain Bootstrap (Codex Edition)

> **Read and executed by Codex when `$bootstrap` skill is invoked.** Works on both fresh repos and repos with an existing Codex Brain install.
> Powered by [Brain Bootstrap](https://github.com/brain-bootstrap/codex-brain-bootstrap) · by brain-bootstrap
> Codex will detect your tech stack, then either install from scratch or **intelligently upgrade** your existing config — preserving all your domain knowledge, lessons, and customizations.

---

## ⛔ READ THIS FIRST — FILES YOU MUST NEVER CREATE

Bootstrap is **READ + CONFIGURE**. You document what exists. You do NOT scaffold the project.

**Never create these files:**

- Any `*.lock` file (`yarn.lock`, `package-lock.json`, `pnpm-lock.yaml`, `bun.lockb`)
- Package manager configs for tools **not already in the project**
- Any `.env*` file (blocked by approval rules)

The ONLY paths you write to: `brain/`, `AGENTS.md`, `.codex/`, `.agents/`, `.codexignore`.

---

## ⭐ START HERE — READ · PLAN · EXECUTE (mandatory before any tool call)

**Three rules that govern the entire bootstrap:**

**1. SCAN EVERYTHING FIRST** — before any command, skim all `### Phase` headings below. Full mental model before the first tool call. 30 seconds. Prevents skipping steps.

**2. WRITE YOUR PLAN FIRST** — your very first action is to create `brain/tasks/.bootstrap-plan.txt`:

```
MODE: TBD (Phase 1 will set this)
P1: discover.sh → read MODE= line
P2: IF UPGRADE → read+execute brain/bootstrap/UPGRADE_GUIDE.md (ALL steps 1-5) — HARD GATE, cannot skip
    IF FRESH  → skip Phase 2 entirely, go directly to Phase 3
P3: bootstrap.sh (single command: discover + populate + validate)
P4: domain detection + AGENTS.md critical patterns + brain/architecture.md
P5: post-bootstrap-validate.sh · report from brain/bootstrap/REFERENCE.md
Risk: [one specific risk for THIS repo — fill in after Phase 1]
```

**You may NOT run any other command until the plan exists.** Update `Risk:` and `P2:` after Phase 1.

**3. ALWAYS BATCH PARALLEL READS** — reading N files sequentially costs N×3s. Reading N in parallel costs 3s once. Whenever you need ≥2 files: read them all in one parallel batch.

---

## ⚡ AUTONOMOUS EXECUTION MODE — MANDATORY

**Execute all operations immediately. Do NOT ask "shall I proceed?". Do NOT pause between phases.**

If you hit ambiguity, make the best choice and document it in the report. Only stop for genuine blockers.

---

## 📋 Phase Map

| Phase             | Applies to          | Core action                                       | Expected AI-work |
| :---------------- | :------------------ | :------------------------------------------------ | :--------------: |
| **1** Discovery   | Both                | `discover.sh` → sets MODE                         |       ~2s        |
| **2** Smart Merge | **UPGRADE ONLY** ⛔ | Read guide → preserve + enhance — **HARD GATE**   |     1–3 min      |
| **3** Populate    | Both                | `bootstrap.sh` (1 command)                        |       ~5s        |
| **4** Creative    | Both                | Domain detection + AGENTS.md + architecture.md    |     3–5 min      |
| **5** Validate    | Both                | `post-bootstrap-validate.sh` · report + REFERENCE |       30s        |

> ⚠️ **Phase 2 is mandatory for UPGRADE mode.** FRESH installs jump Phase 1 → Phase 3 directly.

---

## 🔴 Quality Standards — memorize, apply every phase

- **NEVER lose user data** — lessons, domain docs, task state are irreplaceable. No exceptions.
- **Real patterns only** — read actual source files. Generic filler defeats the purpose.
- **First-session productive** — every file must work immediately after bootstrap.
- **UPGRADE = additive** — never remove or overwrite existing user-written content.
- **Stack-aware, not kitchen-sink** — only document tools ACTUALLY detected.
- **No phantom files** — NEVER create empty placeholder files to test detection heuristics.

---

### Phase 1: Discovery

```bash
bash brain/scripts/discover.sh . > brain/tasks/.discovery.env 2>&1
cat brain/tasks/.discovery.env
```

Auto-detects in ~2s: project name, languages (with file counts), package manager, runtime, formatter/linter, test framework, build/test/lint/serve commands, CI, database/ORM, Docker, monorepo tools, 1100+ frameworks.

**Read the output.** The `MODE=` line tells you FRESH or UPGRADE. Update `Risk:` in your plan file now.

Then read in parallel (if they exist):

- `brain/tasks/lessons.md`
- `brain/tasks/todo.md`
- `AGENTS.md` (first 60 lines)

> **⚠️ SELF-BOOTSTRAP CHECK (mandatory):** If `IS_TEMPLATE_REPO=true`, **STOP**. You are running inside the template repo itself. Copy files into your target project first, then re-run.

**After Phase 1: What is MODE?**

- MODE=FRESH → proceed to Phase 3 (skip Phase 2 entirely)
- MODE=UPGRADE → **you MUST do Phase 2 before Phase 3. Do NOT skip it.**

---

### Phase 2: Smart Merge — 🚨 UPGRADE ONLY (FRESH: skip to Phase 3)

> ⛔ **HARD GATE — DO NOT PROCEED TO PHASE 3 UNTIL THIS IS COMPLETE.**
> This phase exists to protect user data. Skipping it will overwrite or erase domain knowledge.

**If MODE=UPGRADE:**

Read the full upgrade guide now and follow ALL steps before continuing:

```bash
cat brain/bootstrap/UPGRADE_GUIDE.md
```

Execute every step in the guide. Do not summarize or abbreviate — follow each step literally.

**✅ Phase 2 is complete when:**

- `bash brain/scripts/validate.sh` passes
- No user-written content was modified or removed
- All remaining `{{PLACEHOLDER}}` tokens are identified (Phase 4 will fill them)

Only after all three conditions are met: proceed to Phase 3.

---

### Phase 3: Populate (1 command)

> TL;DR: One script covers discover → template population → validate.

```bash
bash brain/scripts/bootstrap.sh . 2>&1
```

> **UPGRADE note:** `bootstrap.sh` re-runs `discover.sh` — this is safe and expected (idempotent). `populate-templates.sh` only fills unfilled `{{PLACEHOLDER}}` tokens and never overwrites content already written during Phase 2.

**Read the output.** Note any remaining `{{PLACEHOLDER}}` tokens — they are your Phase 4 work list.

---

### Phase 4: Domain Detection + Creative Work

> 🧠 **Most important phase.** Real patterns from real source files. Generic advice is worthless.

> **⚠️ DEPTH RULE**: Read 2–3 actual implementation files per detected domain. A 20-line doc with 3 real patterns beats 100 lines of filler.

#### Step 4A: Domain Detection — run all greps in parallel

```bash
# Messaging (Kafka/RabbitMQ/SQS/NATS)
grep -rl 'KafkaConsumer\|KafkaProducer\|createTopic\|RabbitMQ\|SQSClient\|NATS\|publishMessage' . --include='*.js' --include='*.ts' --include='*.py' 2>/dev/null | head -5 || true
# DB / multi-connection
grep -rl 'knex\|\.db\.\|createConnection\|getRepository\|DataSource\|prisma\.' . --include='*.js' --include='*.ts' --include='*.py' 2>/dev/null | head -5 || true
# State machine / lifecycle
grep -rl 'StatusCode\|StatusEnum\|\.state\b\|transition\|workflow.*state\|state.*machine' . --include='*.js' --include='*.ts' --include='*.py' 2>/dev/null | head -5 || true
# Auth / identity
grep -rl 'keycloak\|realm\|grant_type\|jwt\|bearer\|guard\|protect\|token.*verify' . --include='*.js' --include='*.ts' --include='*.py' 2>/dev/null | head -5 || true
# Webhooks / callbacks
grep -rl 'onConflict\|delivery.*id\|idempotent\|webhook.*url\|callback.*endpoint' . --include='*.js' --include='*.ts' 2>/dev/null | head -5 || true
# API / HTTP layer
grep -rl 'router\.\|app\.get\|app\.post\|fastify\|express\|koa\|flask\|fastapi\|django' . --include='*.js' --include='*.ts' --include='*.py' 2>/dev/null | head -5 || true
# Adapters / external integrations
grep -rl 'adapter\|Adapter\|BaseAdapter\|ApiClient\|integration\|ExternalAPI' . --include='*.js' --include='*.ts' --include='*.py' 2>/dev/null | head -5 || true
```

For each domain that returns hits: read 2–3 actual source files → create `brain/<domain>.md` with REAL patterns (≥5 rules specific to this codebase).

Detection → doc name mapping:

- Messaging → `brain/messaging.md`
- DB / multi-connection → `brain/database.md`
- State machine → `brain/lifecycle.md`
- Auth / identity → `brain/auth.md`
- Webhooks → `brain/webhooks.md`
- API / HTTP → `brain/api.md`
- Adapters → `brain/adapters.md`

#### Step 4B: Fill AGENTS.md Critical Patterns

Read `AGENTS.md` and fill `<!-- {{CRITICAL_PATTERNS}} -->` with 3–5 rules specific to THIS codebase.

Examples of good patterns:

- "Never emit side effects inside a DB transaction"
- "Two DBs: write (mutations) + read (queries) — never mix"
- "Service X must not be imported by Service Y (enforced by `brain/rules.md`)"

#### Step 4C: Fill brain/architecture.md

Read top-level directories and key source files:

```bash
ls -d */ 2>/dev/null | head -20
```

Document:

- **Service/module catalog** — every top-level dir with its role
- **Directory layout** — which dir contains what
- **Key infrastructure** — DB, queue, cache, external APIs
- **Data flow** — how a typical request flows through the system

For monorepos: check each dir for `package.json`, `Cargo.toml`, `go.mod`, `pom.xml`.

#### Step 4D: Verify brain/build.md

Confirm every command in `brain/build.md` is accurate. Check against `package.json` scripts, `Makefile`, `pyproject.toml`, etc. Fix any mismatches.

#### Step 4E: Update AGENTS.md Domain Lookup Table

For each domain doc created, add one row to the lookup table in `AGENTS.md`:

| Domain | File                | When to read        |
| ------ | ------------------- | ------------------- |
| [name] | `brain/<domain>.md` | [trigger condition] |

#### Step 4F: Verify `brain/plugins.md` MCP Tool Status

`brain/plugins.md` documents the MCP tool stack. After discovery, check which tools are actually configured:

```bash
# Check .codex/config.toml for MCP server declarations
grep -A2 '\[mcp_servers\.' .codex/config.toml 2>/dev/null | head -40 || echo "No config.toml found"
```

For each of the 5 MCP tools (cocoindex-code, codebase-memory-mcp, code-review-graph, serena, playwright):

- If declared in `.codex/config.toml` → mark as **CONFIGURED** in `brain/plugins.md` status table
- If missing → mark as **NOT CONFIGURED** + include install command from the tool's details section

This tells the user what tools are ready to use immediately vs what requires setup.

---

### Phase 4.5: MCP Stack Suggestions (note in report only — no user input)

> **Do NOT configure MCP servers during bootstrap.** Scan discovery output for stack-matched suggestions to include in the final report.

- `DATABASE` detected → suggest `postgres` or `mysql` MCP server
- `CI_SYSTEM=github-actions` or GitHub remote → suggest `github` MCP server
- Web frontend detected → suggest `web-search` MCP server
- `DOCKER=true` or Kubernetes manifests found → suggest `filesystem` MCP server

Add a **"💡 MCP Suggestions"** section to the final report. User installs post-bootstrap: `uvx <server>@latest`. Browse all: [registry.smithery.ai](https://registry.smithery.ai).

---

### Phase 5: Validate + Report

> 🧠 **The report is the user's first impression of the bootstrap.** Enthusiastic, emoji-rich, specific — not clinical.

```bash
bash brain/scripts/post-bootstrap-validate.sh . 2>&1
```

**If failures remain**: fix immediately, re-run. Do not proceed until clean.

Read the report template:

```bash
cat brain/bootstrap/REFERENCE.md
```

Write the full report (FRESH INSTALL or UPGRADE template from `brain/bootstrap/REFERENCE.md`) to `brain/tasks/bootstrap-report.md` and present it to the user.

**Collaboration mode** — default: TEAM (committed, shared with team). Include in report:

```
🤝 Mode: TEAM (default)
   → Commit: git add AGENTS.md .codexignore .codex/ .agents/ brain/
   → Switch to SOLO later: echo -e '\nAGENTS.md\n.codex/\n.agents/\nbrain/\n.codexignore' >> .gitignore
```

**Do NOT commit autonomously.** Present the summary and wait for user confirmation.

---

### Performance Budget

- **Phase 1 (Discovery):** ~2s
- **Phase 2 (Smart Merge):** ~1–3 min (UPGRADE only)
- **Phase 3 (Populate):** ~5s (1 script)
- **Phase 4 (Creative):** ~3–5 min
- **Phase 5 (Validate + Report):** ~30s
- **AI-work total: ~4–8 min** · **Wall-clock total: ~6–12 min**

---

> 💡 **After bootstrap:** Every correction you make gets captured in `brain/tasks/lessons.md`. The brain literally cannot make the same mistake twice.
