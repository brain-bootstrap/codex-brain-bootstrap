# Codex Errors Log

> Structured bug tracker. Read before modifying any code in the affected area.
> When the same error type appears 3+ times, promote the derived rule to `AGENTS.md` or a domain file.

---

## Format

```
### YYYY-MM-DD — [Error title]
**Area:** <service or file>
**Type:** syntax | logic | integration | config | security
**Root cause:** <one sentence>
**Fix applied:** <what was done>
**Derived rule:** <single-sentence rule to prevent recurrence>
```

---

## Errors

_No errors logged yet._

---

## Promotion Lifecycle

```
Bug discovered → CODEX_ERRORS.md entry
  → Recurs 3+ times → Extract pattern → AGENTS.md (Critical Patterns section)
  → Pattern is universal → brain/rules.md
```
