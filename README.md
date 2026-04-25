<p align="center">
  <a href="https://github.com/brain-bootstrap">
    <img src="https://raw.githubusercontent.com/brain-bootstrap/.github/main/profile/brain-bootstrap-logo.svg" alt="Brain Bootstrap" width="480" />
  </a>
</p>

<h1 align="center">ᗺB - Brain Bootstrap for OpenAI Codex</h1>
<p align="center"><em>Your AI coding assistant is brilliant.<br>It just resets every session, ignores your conventions, and reinvents your patterns.<br><strong>Brain doesn't hope Codex behaves — it makes it. Permanently.</strong></em></p>
<p align="center"><sub>by <a href="https://github.com/brain-bootstrap">brain-bootstrap</a> · no third-party installs without your explicit approval</sub></p>
<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="MIT License"></a>
  <a href="https://github.com/brain-bootstrap/codex-brain-bootstrap/actions/workflows/ci.yml"><img src="https://github.com/brain-bootstrap/codex-brain-bootstrap/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="#"><img src="https://img.shields.io/badge/OpenAI_Codex-Ready-10A37F" alt="OpenAI Codex"></a>
  <a href="#-write-once-read-everywhere"><img src="https://img.shields.io/badge/Knowledge-Portable_Across_Tools-ff6f00" alt="Knowledge Portable"></a>
</p>

<p align="center">
  <a href="#-what-this-is">What This Is</a> &nbsp;·&nbsp;
  <a href="#-not-suggestions--guarantees">Guarantees</a> &nbsp;·&nbsp;
  <a href="#-what-changes-when-you-add-a-brain">Before & After</a> &nbsp;·&nbsp;
  <a href="#-get-started-in-5-minutes">5 Min Setup</a> &nbsp;·&nbsp;
  <a href="#-how-it-works-under-the-hood">Under the Hood</a> &nbsp;·&nbsp;
  <a href="#-whats-inside">120+ Files</a> &nbsp;·&nbsp;
  <a href="#-it-gets-smarter-over-time">Gets Smarter</a> &nbsp;·&nbsp;
  <a href="#-safety-defense-in-depth">Guardrails</a> &nbsp;·&nbsp;
  <a href="#-plugin-ecosystem">Superpowers</a> &nbsp;·&nbsp;
  <a href="#-make-it-yours">Make It Yours</a> &nbsp;·&nbsp;
  <a href="#-faq">FAQ</a> &nbsp;·&nbsp;
  <a href="#-contributing">Contribute</a>
</p>

---

## 💡 What This Is

**Brain Bootstrap is not a template to copy and forget. It's a behavioral enforcement layer for OpenAI Codex — lifecycle hooks that block violations before they execute, a persistent knowledge base that survives every session reset, and 49 skills purpose-built for recurring engineering tasks. Install it once. OpenAI Codex stops guessing and starts knowing.**

---

**The problem it solves:**

You fire up `codex` to add a feature. It uses `pnpm build` — but you use `yarn turbo build`. It installs `date-fns` even though `@company/utils` already has `formatDate()`. It edits `tsconfig.json` to silence a type error — the file you explicitly said never to touch.

You write an `AGENTS.md`. You correct it. It apologizes. Next session: same mistakes.

Codex is stateless by design — each session starts blank. So you end up re-explaining your stack, re-enforcing the same rules, re-correcting the same errors. Every. Single. Session. **You become the AI's memory.**

---

**What Brain Bootstrap gives you instead:**

- **Persistent memory** — conventions, architecture, past mistakes embedded once and never forgotten
- **Enforced rules** — 10 lifecycle hooks that block violations _before_ they run, no AI judgment involved
- **Ready-to-use workflows** — 49 skills, 5 specialist agents covering every common task
- **Self-updating knowledge** — the knowledge layer grows with your codebase, session by session

**Install once. Correct once. It never happens again.**

---

## 🔒 Not Suggestions — Guarantees

Every other instruction system hopes the AI complies. Brain doesn't hope — it **enforces**.

Corrections become permanent rules. Forbidden patterns get blocked _before_ they run — by deterministic bash scripts, not AI judgment. The knowledge base updates itself as your codebase evolves. The same mistake cannot happen twice.

**You stop babysitting — the AI just knows.**

---

## ✨ What Changes When You Add a Brain

Every AI coding tool reads instructions. None of them enforce those instructions on themselves. You write _"never edit tsconfig.json"_ — it edits `tsconfig.json` anyway. You correct it — same mistake next session.

**Instructions are text. Text is advisory. Advisory gets overridden.** Brain replaces text with mechanisms — hooks that block before execution, memory that persists across sessions, knowledge that stays current:

| 🔁 Every session today                                                                            | 🧠 With Brain — once, forever                                                                                              |
| :------------------------------------------------------------------------------------------------ | :------------------------------------------------------------------------------------------------------------------------- |
| You repeat your conventions every session — package manager, build commands, code style           | Knows your entire toolchain from day one — conventions are documented, not repeated                                        |
| You re-explain your architecture after every context reset                                        | `brain/architecture.md` is injected by the session-start hook — survives compaction, restarts, everything                  |
| You correct a mistake, it apologizes, then does it again tomorrow                                 | Corrections are captured in `brain/tasks/lessons.md` — read at every session start, never repeated                         |
| The AI modifies config files to "fix" issues — linter settings, compiler configs, toolchain files | **Config protection** hook blocks edits to any protected file — forces fixing source code, not bypassing the toolchain     |
| A command opens a pager, launches an editor, or dumps unbounded output — session hangs            | **Terminal safety** hook intercepts dangerous patterns before they execute — pagers, `vi`, unbounded output, all blocked   |
| Code reviews vary wildly depending on how you prompted                                            | `$review` runs a consistent 10-point protocol every time — same rigor, zero prompt engineering                             |
| Research eats your main context window and you lose track                                         | `$research` subagent explores in an **isolated** context — your main window stays clean                                    |
| Knowledge docs slowly rot as the code evolves                                                     | Self-maintenance rule + `$maintain` skill detect drift and fix stale references automatically                              |
| You're locked into one model — switching models means reconfiguring everything                    | Subagents pick the best reasoning level per task — **falls back** to any provider gracefully                               |
| You push a PR and discover too late that your change broke 14 other files                         | **`$code-review-graph`** scores every diff 0–100 before you push — blast radius, breaking changes, risk verdict in seconds |

**After a few sessions, your AI will know things about your codebase that even some team members don't.**

---

> 🎯 **120+ files isn't complexity. It's the minimum architecture where instructions become guarantees.**

---

## 🚀 Get Started in 5 Minutes

### Step 1 — Install the template

**Prerequisites:** Codex CLI (latest, with hooks support), `git`, `bash` ≥ 4.0 (macOS ships 3.2 — `brew install bash`), `jq` ([install jq](https://jqlang.github.io/jq/download/) if missing — `brew install jq` / `apt install jq`).

```bash
git clone https://github.com/brain-bootstrap/codex-brain-bootstrap.git /tmp/codex-brain
bash /tmp/codex-brain/install.sh your-repo/
rm -rf /tmp/codex-brain
```

> 🔍 **Pre-flight check:** `bash /tmp/codex-brain/install.sh --check` — verifies all prerequisites (git, bash, jq, uvx) before touching your repo. Runs in 1 second, no side effects.

The installer **auto-detects** fresh install vs. upgrade — it never overwrites your knowledge (`AGENTS.md`, lessons, architecture docs). Existing files stay untouched; only missing pieces are added.

### Step 2 — Let the AI configure itself

Open a new Codex session in your project and run:

```
$bootstrap
```

The `$bootstrap` skill runs the discovery engine (`discover.sh` — pure bash, zero tokens), detects your entire stack, fills 70+ placeholders, then has the AI write architecture docs and domain knowledge specific to your codebase. Fully automated, ~5 minutes.

> 💡 **Why `$skill-name`?** Skills live in `.agents/skills/` — Codex discovers and invokes them when you prefix with `$`. No configuration needed; they're just there, ready to run.

The discovery engine detects 25+ languages, 1,100+ frameworks, 21 package managers in ~2 seconds. Then the AI fills in what requires _reasoning_: architecture, domain knowledge, critical patterns.

---

## 🧠 How It Works Under the Hood

Codex Brain Bootstrap is **120+ files** of structured configuration that live in your repo, version-controlled alongside your code. It's not a wrapper, not a plugin, not a SaaS product — it's **a knowledge architecture** that teaches your AI assistant how your project actually works.

```
Your repo
├── 📋 AGENTS.md                    ← Operating protocol (auto-loaded by Codex every session)
├── ⚙️ .codex/
│   ├── config.toml                 ← Project-level Codex configuration + MCP servers
│   ├── hooks.json                  ← Lifecycle hook registration
│   ├── hooks/                      ← 10 lifecycle hooks (safety, quality, recovery, audit)
│   ├── rules/                      ← Starlark command approval rules
│   └── agents/                     ← 5 AI subagents (explorer, reviewer, plan-challenger...)
├── 🎓 .agents/
│   └── skills/                     ← 49 invocable skills ($bootstrap, $review, $tdd, $mr...)
├── 📚 brain/
│   ├── architecture.md             ← Your project's architecture (injected on session start)
│   ├── rules.md                    ← 25 golden rules (auto-imported)
│   ├── build.md                    ← Build/test/lint/serve commands for your stack
│   ├── terminal-safety.md          ← Shell anti-patterns that cause session hangs
│   ├── cve-policy.md               ← Security decision tree
│   ├── plugins.md                  ← MCP tool catalog
│   ├── scripts/                    ← 16 bootstrap & maintenance scripts
│   ├── tasks/lessons.md            ← 🧠 Accumulated wisdom (persists across sessions)
│   ├── tasks/todo.md               ← 📝 Current task plan (survives session boundaries)
│   └── tasks/CODEX_ERRORS.md       ← 🐛 Error log (promotes to rules after 3+ recurrences)
├── 🗃️ .serena/                     ← LSP refactoring config (serena MCP plugin)
├── 🔎 .cocoindex_code/             ← Semantic search config (cocoindex-code MCP plugin)
├── 🤖 .github/
│   ├── workflows/ci.yml            ← Automated quality gates (validate, integration tests)
│   └── ISSUE_TEMPLATE/             ← Bug report and feature request templates
└── 🚫 .codexignore                 ← Context exclusions (lock files, binaries, etc.)
```

**Write your knowledge once. Every AI tool reads it.** ✍️

Because it lives in your repo, it's version-controlled, PR-reviewed, and shared across your team automatically — no SaaS account, no sync, no drift.

### 🎯 The Three-Layer Context Strategy

The system is designed to **minimize token cost** while maximizing context — your AI doesn't drown in 50K tokens when you ask it to fix a typo:

| Layer                | What                                                               | When loaded               |                  Cost                  |
| :------------------- | :----------------------------------------------------------------- | :------------------------ | :------------------------------------: |
| 🟢 **Always on**     | `AGENTS.md` — operating protocol, critical patterns                | Every session             |              ~3-4K tokens              |
| 🟡 **Auto-injected** | `todo.md` + `lessons.md` + git status — via session-start hook     | Every session start       |              ~1-2K tokens              |
| 🔵 **On-demand**     | Full domain docs — architecture, build, auth, database             | When the task requires it |               ~1-2K each               |
| 🗺️ **Graph**         | Structural graph via codebase-memory MCP — call paths, communities | Before file traversals    | **120× fewer tokens** vs reading files |

---

## 📦 What's Inside

| Category                 | Count | Highlights                                                                                                     |
| :----------------------- | :---: | :------------------------------------------------------------------------------------------------------------- |
| 📚 **Knowledge docs**    |   8   | Architecture, rules, build, CVE policy, terminal safety, templates, decisions + 3 worked domain examples       |
| 🎓 **Skills**            |  49   | Bootstrap, plan, review, TDD, debug, research, MR, changelog, squad-plan — the full dev lifecycle              |
| 🪝 **Lifecycle hooks**   |  10   | Config protection, terminal safety, commit quality, prompt guard, TDD loop check, exit checklist               |
| 🤖 **AI subagents**      |   5   | Explorer, reviewer, plan-challenger, session-reviewer, security-auditor — each picks the right reasoning level |
| 🔧 **Brain scripts**     |  16   | Stack discovery (3800-line detector), template population, validation, plugin setup, portability lint          |
| 🔌 **MCP plugins**       |   5   | code-review-graph, codebase-memory, cocoindex-code, serena, playwright                                         |
| ✅ **Validation checks** | 105+  | File existence, hook executability, content integrity, settings consistency, cross-reference checks            |

---

### 🔀 Write Once, Read Everywhere

| Tool                 | What it reads                                   |           Depth           |
| :------------------- | :---------------------------------------------- | :-----------------------: |
| **Codex CLI**        | `AGENTS.md` + `.codex/` + `.agents/` + `brain/` |       🟢 Everything       |
| **Claude Code**      | `brain/*.md` as domain knowledge                |    🟡 Knowledge layer     |
| **Any AI assistant** | `brain/*.md` — plain Markdown, zero setup       | 🔵 Drop-in knowledge base |

Subagents declare their optimal reasoning level (`high` for review/security, `medium` for exploration). Falls back gracefully to whatever you're running — any Codex-compatible provider, any local endpoint.

---

## 🔄 It Gets Smarter Over Time

This isn't a static config that rots. It's a **living system** with six feedback loops:

1. 📋 **Exit checklist** — captures corrections at the end of every turn, so they stick
2. 🧠 **`lessons.md`** — accumulated wisdom, injected at every session start — impossible to skip
3. 🐛 **Error promotion** — same mistake 3 times? Becomes a permanent rule automatically
4. 🔁 **Session hooks** — context survives restarts, compaction, resume — nothing gets lost
5. 🔍 **`$maintain`** — audits all docs for stale paths, dead references, drift
6. 📊 **Structured error tracker** — `CODEX_ERRORS.md` with date, area, type, root cause, fix applied

---

## 🛡️ Safety: Defense in Depth

Security isn't one mechanism — it's **two layers** working together:

### 🚫 Layer 1: Permissions — What the AI Can't Even Attempt

`.codex/rules/default.rules` defines hard boundaries via Starlark. The AI **can never push code** without your confirmation. Destructive commands (`rm -rf /`, `DROP DATABASE`, deployment scripts) require explicit approval. Only explicitly allowed tool patterns run; everything else prompts for your decision.

These aren't suggestions — they're **hard permission boundaries** enforced before the AI even sees the command.

### 🪝 Layer 2: Hooks — What Gets Intercepted at Runtime

10 lifecycle hooks add runtime guardrails — deterministic bash scripts, zero tokens, zero AI reasoning:

| Hook                        | What it prevents                                                                                      |
| :-------------------------- | :---------------------------------------------------------------------------------------------------- |
| 🔒 **Config protection**    | Blocks editing `biome.json`, `tsconfig.json`, linter configs — forces fixing source code instead      |
| 🚧 **Terminal safety gate** | Blocks `vi`/`nano`, pagers, `docker exec -it`, unbounded output — 3 profiles: minimal/standard/strict |
| 🧹 **Commit quality**       | Catches `debugger`, `console.log`, hardcoded secrets, `TODO FIXME` in staged files                    |
| 🔐 **Prompt guard**         | Scans prompts for accidentally pasted secrets before they reach the model                             |

Plus 6 more — session context injection, failure recovery, TDD loop enforcement, permission audit, exit checklist, and missing-test warnings.

---

## 🔌 Plugin Ecosystem

Five MCP plugins available — pick what fits your stack. Run `bash brain/scripts/setup-plugins.sh --all`:

| Tool                                                                       | Axis                                                                                      |      Requires      |               Impact                |
| :------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------- | :----------------: | :---------------------------------: |
| **[code-review-graph](https://github.com/tirth8205/code-review-graph)**    | 🔴 Change risk analysis — risk score 0–100, blast radius, breaking changes from git diffs |    Python 3.10+    |         Pre-PR safety gate          |
| **[codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp)** | 🔍 Live structural graph — call traces, blast radius, dead code, Cypher queries           |        curl        | **120× fewer tokens** vs file reads |
| **[cocoindex-code](https://github.com/cocoindex-io/cocoindex-code)**       | 🔎 Semantic search — find code by meaning via local vector embeddings (no API key)        |    Python 3.11+    |      Finds what grep/AST miss       |
| **[serena](https://github.com/oraios/serena)**                             | 🔧 LSP symbol refactoring — rename/move/inline across entire codebase atomically          | uvx + Python 3.11+ |           Low — on-demand           |
| **[playwright](https://github.com/microsoft/playwright-mcp)**              | 🌐 Browser automation — navigate, click, fill, snapshot web pages                         |    Node.js 18+     |    Replaces manual browser steps    |

> 📚 **Full plugin reference:** [brain/plugins.md](brain/plugins.md) — usage examples, install commands, token economics.

---

## ⚙️ Make It Yours

Extending the Brain is simple — one file, one registration:

| To add…             | Create…                          | Registration                    |
| :------------------ | :------------------------------- | :------------------------------ |
| 📚 Domain knowledge | `brain/<domain>.md`              | Add to `AGENTS.md` lookup table |
| 🎓 Skill            | `.agents/skills/<name>/SKILL.md` | Automatic (discovered by Codex) |
| 🪝 Lifecycle hook   | `.codex/hooks/<name>.sh`         | Register in `.codex/hooks.json` |
| 🤖 AI subagent      | `.codex/agents/<name>.toml`      | Automatic (discovered by Codex) |

Three worked examples in `brain/_examples/` — API domain, database domain, messaging domain.

### Personal override

Copy `AGENTS.override.md.example` → `AGENTS.override.md` (gitignored) for personal instructions that don't belong in the shared `AGENTS.md`.

---

## ❓ FAQ

<details>
<summary><strong>💻 What platforms and languages are supported?</strong></summary>

**Platforms:** Linux ✅, macOS ✅, Windows WSL2 ✅. Codex CLI requires a Unix shell.

**Prerequisites:** Codex CLI (latest, with hooks support), `git`, `bash` ≥ 4.0 (macOS ships 3.2 — `brew install bash`), `jq`. Optional: `uvx` + Python 3.10+ for MCP plugins.

**Languages:** 25+ — TypeScript, Python, Go, Rust, Java, Kotlin, Ruby, PHP, C#, C/C++, Swift, Dart, Elixir, and more. The knowledge docs are language-agnostic; stack-specific details are auto-detected by the discovery engine.

> 💡 Run `bash install.sh --check` to verify all prerequisites in 1 second.

</details>

<details>
<summary><strong>🔄 I already have an AGENTS.md / brain/ config — will this overwrite it?</strong></summary>

Never. The installer detects your existing config and enters **upgrade mode** — it adds only what's missing and never touches your knowledge files (`AGENTS.md`, `lessons.md`, architecture docs). Existing files stay untouched.

</details>

<details>
<summary><strong>💰 How much does it cost in tokens?</strong></summary>

Very little. The system is designed to be **cheap by default** — your AI doesn't load 50K tokens when you ask it to fix a typo:

- **Always on:** ~3-4K tokens (`AGENTS.md` — operating protocol + critical rules)
- **Auto-injected:** ~1-2K tokens (session-start hook: `todo.md` + `lessons.md` + git status)
- **On-demand:** ~1-2K tokens per doc (only when the task needs it)

The codebase-memory MCP plugin can replace raw file traversal with structured queries — **120× fewer tokens** for architecture questions.

</details>

<details>
<summary><strong>⚙️ What is hooks support and do I need it?</strong></summary>

Hooks are experimental Codex CLI features that fire bash scripts at key lifecycle events (session start, before/after tool use, before stopping). They're what make Brain's guarantees possible — config protection, terminal safety, exit checklist.

Enable with `[features] codex_hooks = true` in `.codex/config.toml` (enabled by default in this template). Without hooks, the knowledge base and skills still work — you just lose the deterministic safety layer.

</details>

<details>
<summary><strong>🤖 Does it work with local LLMs / Ollama / LM Studio?</strong></summary>

Yes, if Codex CLI supports the endpoint. Subagents declare their preferred reasoning level but fall back gracefully. The knowledge docs are plain Markdown — any model can read them. No API keys required for the core system.

</details>

<details>
<summary><strong>👥 Is this just for solo developers?</strong></summary>

Works great solo, but it's designed for teams. Everything is version-controlled and shared by default (**TEAM mode**).

Not ready to share your Brain with the team? Switch to **SOLO mode**: add `AGENTS.md`, `brain/`, `.codex/`, `.agents/` to `.codexignore` — only the CI and GitHub templates stay committed for everyone.

</details>

<details>
<summary><strong>⚖️ How is this different from just writing a good AGENTS.md?</strong></summary>

Scope. A hand-written `AGENTS.md` is a flat instruction file — the AI reads it _if it feels like it_. Brain is a **multi-layered enforcement architecture** with lifecycle hooks that block before execution, subagents that run in isolated contexts, 49 skills that activate per task, session memory that persists across restarts, and self-maintenance that keeps docs current.

It's the difference between a sticky note and an operating system.

</details>

---

## 🤝 Contributing

PRs welcome! All contributions must be **domain-agnostic**.

👉 **[Full guide → CONTRIBUTING.md](CONTRIBUTING.md)** · 🐛 **[Report a bug](https://github.com/brain-bootstrap/codex-brain-bootstrap/issues/new/choose)** · CI runs 5 checks on every PR.

---

## 📄 License

MIT — see [LICENSE](LICENSE).
