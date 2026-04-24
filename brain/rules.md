# Golden Rules (Non-Negotiable Working Standards)

> These rules apply to every task, every file, every layer, regardless of language or framework.

---

## Working Methodology

### Never Skip Planning

- Do not start any non-trivial task (3+ steps or architectural decisions) without `$plan` first.
- Do not keep pushing if something goes wrong — stop and re-plan immediately.
- Do not limit planning to building — use it for verification steps too.

### Never Underuse Subagents

- Do not pollute the main context window with research and exploration — spawn an explorer.
- Do not hesitate to throw more compute at complex problems via subagents.
- Do not mix concerns — one subagent per job for focused execution.

### Never Repeat the Same Mistake

- After ANY user correction, update `brain/tasks/lessons.md` with the pattern.
- Start every session by reviewing `brain/tasks/lessons.md`.
- Do NOT yield without running the Exit Checklist.

### Never Mark a Task Complete Without Proof

- Do not claim done without running tests, checking logs, and demonstrating correctness.
- Ask: "Would a staff engineer approve this?"

### Never Ship Hacky Solutions

- Ask "is there a more elegant way?" before committing non-trivial changes.

### Never Ask for Hand-Holding on Bugs

- Do not ask the user how to fix a bug — just fix it (`$debug`).

---

## Rule 1 — Never block critical flows for non-critical features

Secondary/optional failures must not impede the primary flow.

## Rule 2 — Never allow cross-layer inconsistency

No data field may be inconsistent across any layer it touches: DB → service → API → tests.
Run `$cross-layer-check` after every field/enum change.

## Rule 3 — Never invent a pattern when one already exists

Read existing files in the affected area first. Match conventions precisely.

## Rule 4 — Never over-engineer

No dead code, useless abstractions, or speculative features.
Every line must serve a clear, immediate purpose.

## Rule 5 — Never implement without a plan and agreement

For non-trivial tasks: present a full plan (exact file list, exact change per file, rationale) before touching anything.

## Rule 6 — Never deliver a shallow review

Read every affected file in full. Run all affected tests. Report exact pass/fail counts.

## Rule 7 — Never write meaningless tests

No tests that skip real scenarios, edge cases, or failure paths.
No stub with no assertion — that's dead test code.

## Rule 8 — Never make non-surgical changes

Do not modify anything not required for the current task.
Do not rename any symbol without grepping every caller first.

## Rule 9 — Never hedge or guess

Verify before stating. Distinguish pre-existing issues from introduced ones.

## Rule 10 — Never act without understanding the full data flow

Trace the complete path end-to-end before proposing changes.

## Rule 11 — Never produce external side effects inside a DB transaction

A DB transaction can roll back. External calls (HTTP, queue, email, file write) will NOT roll back.
Always ask: "Is this code inside a transaction? If yes, defer it."

## Rule 12 — Never write code without finding an existing example first

Search the codebase for an existing file that solves the same problem. Reproduce the exact approach.

## Rule 13 — Never mutate state from a listener or side-effect layer

Listeners must only react — emit notifications, trigger messages. Fix state where it is computed.

## Rule 14 — Never resolve configuration at the side-effect layer

When a domain decision depends on data from multiple sources, resolve it once at data-loading time. One query, one resolution, one place.

## Rule 15 — Never re-query the DB for data already in memory

Check what the caller already has in scope before writing a DB query.

## Rule 16 — Never delete or rename without verifying the entire scope

Run grep across the codebase for every removed symbol.
Run the production build — dev tools are lenient; production builds are strict.

## Rule 17 — Never trust specification values blindly

Search the codebase for actual definitions. The codebase is the source of truth, not the spec.

## Rule 18 — Never add error handling without matching it to criticality

Ask: "If this fails, is it acceptable to continue silently?"
If no → let it throw. If yes → catch, log, continue with safe fallback.

## Rule 19 — Never assume documentation is correct

Cross-check every concrete value against the codebase. Fix wrong docs with evidence.

## Rule 20 — Never resolve a merge conflict without scanning the full repo

Run: `grep -rn '<<<<<<<\|=======\|>>>>>>>' .` before declaring resolved.
Run the production build and tests after resolution.

## Rule 21 — Never finish a task without updating the knowledge base

After any task that involved learning something new:

1. Update `brain/tasks/lessons.md` (pattern, not incident).
2. If general enough, update the relevant `brain/*.md` file.
3. Only add lessons that would save ≥5 minutes in a future task.

**This rule is enforced by the Exit Checklist in `AGENTS.md`.**

## Rule 22 — Never assume external provider contracts are stable

Handle both current and deprecated states/events.
Read provider changelogs before touching integration code.

## Rule 23 — Never infer UI success from flow progression

Derive displayed state from actual domain/backend outcome, not from step completion.
If the API returned an error, the UI must reflect it — regardless of how far the flow progressed.

## Rule 24 — Never skip test verification after any code change

Run relevant test suites after every change.
Compare against `main` for non-trivial changes — never assume green without running.

## Rule 25 — Never mark complete without running the Exit Checklist

The Exit Checklist is an **active exit gate**, not a suggestion.
Do NOT yield back to the user without verifying all 6 checklist items in `AGENTS.md`.

---

## Quality Thresholds

### Code Quality

| Metric                    | Threshold                       | Enforcement     |
| ------------------------- | ------------------------------- | --------------- |
| Max function length       | 50 lines                        | Review          |
| Max file length           | 400 lines                       | Review          |
| Max cyclomatic complexity | 15 per function                 | Static analysis |
| Max function parameters   | 4 (use options object beyond)   | Review          |
| Max nesting depth         | 3 levels (early return instead) | Review          |
| Test coverage (new code)  | ≥80% line coverage              | CI gate         |
| Lint violations           | 0 introduced                    | CI gate         |

### Architecture Quality

| Metric                        | Threshold                                         | Enforcement       |
| ----------------------------- | ------------------------------------------------- | ----------------- |
| DTO↔DB field alignment        | 100% — every DTO field traces to a source         | Cross-layer check |
| `brain/tasks/lessons.md` size | <500 lines (archive to `lessons-archive-YYYY.md`) | Exit checklist    |

### AI Self-Assessment Quality

| Metric                    | Threshold        | Action                                |
| ------------------------- | ---------------- | ------------------------------------- |
| Confidence in answer      | ≥0.8             | Below → retry with more research      |
| Tool calls on tangent     | ≤3               | Above → yak shaving detected, refocus |
| Files read without acting | ≤5 per task step | Above → gold plating, simplify        |

## Test Quality Standards

- Every new code path (branch, loop, edge case, error handler) must have a corresponding test.
- Coverage percentages are a lagging signal — write tests for **behavior**, not to hit a number.
- Every test must have at least one meaningful assertion.

<!-- {{PROJECT_SPECIFIC_RULES}} — Add project-specific rules below this line -->
