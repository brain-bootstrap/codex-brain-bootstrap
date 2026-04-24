# Terminal Safety Reference

> **Critical read.** Terminal misuse is the #1 cause of stuck sessions. Read this before running any shell command.

---

## Environment Detection

Determine your shell and OS before running shell commands:

- **Shell**: `echo $SHELL` — typically `bash`, `zsh`, or `fish`
- **OS**: `uname -s` → `Darwin` (macOS) or `Linux`
- **zsh-specific**: glob no-match is FATAL (`ls *.xyz` fails if no match — use `2>/dev/null || true`); `!` expands in double quotes; arrays are 1-based
- **bash-specific**: more lenient glob; `!` less aggressive; arrays are 0-based; bash 3.2 on macOS lacks `declare -A` (no associative arrays)
- **macOS vs Linux**: no `readlink -f`, no `stat -c`, no `grep -P` on macOS — always test cross-platform

---

## 🚨 PIPE `|` — THE SESSION KILLER

The pipe character causes silent failures in two contexts:

### Context 1: Running a command

```
✅ grep -E 'pattern1|pattern2' file       (single quotes — always safe)
❌ grep -E "pattern1|pattern2" file       (double quotes — shell may misinterpret |)
```

### Context 2: Writing shell scripts

```
✅ case "$FILE" in *.js|*.ts|*.tsx) ;;    (case separator — always pipe-immune)
❌ echo "$FILE" | grep -E "\.(js|ts)$"    (| in double quotes — corruption risk)
```

**ABSOLUTE RULES:**

1. **Single quotes** for all regex containing `|` in terminal commands
2. **`case` statement** for file extension matching in shell scripts — never `grep -E`
3. **File tool** for writing files — NEVER heredoc in terminal (strips `|`)
4. **`grep -c '|' file`** to verify `|` in files — NOT `cat file` (display strips `|`)

---

## 🚨 PAGER — THE OTHER SESSION KILLER

```
❌ git log            → ✅ git --no-pager log --oneline -20
❌ git show           → ✅ git --no-pager show HEAD | head -50
❌ git stash list     → ✅ git --no-pager stash list
❌ git diff           → ✅ git --no-pager diff | head -100
❌ helm template      → ✅ helm template . | cat
❌ kubectl describe   → ✅ kubectl describe pod xyz | cat
❌ man command        → ✅ man command | head -60
```

---

## 🚨 INTERACTIVE PROGRAMS — INSTANT HANG

```
❌ vi, vim, nano, emacs       → use file editing tools
❌ psql (no -c)               → psql -c "SELECT ..." dbname
❌ node (no script)           → node -e "console.log(...)"
❌ python (REPL)              → python3 -c "print(...)"
❌ docker exec -it            → docker exec container command
❌ ssh (no command)           → ssh host "command"
❌ npm init (interactive)     → use non-interactive flags
```

---

## MANDATORY CHECKLIST before every terminal command

1. ✅ `--no-pager` for git log/show/stash/diff?
2. ✅ `| cat` for helm/kubectl/man?
3. ✅ SINGLE QUOTES for any regex with `|`?
4. ✅ `| head -N` or redirect to limit output?
5. ✅ `2>&1` to capture stderr?
6. ✅ `--color=never` / `NO_COLOR=1`?
7. ✅ Absolute path (not `cd /path &&`)?
8. ✅ `|| true` for grep in `&&` chains?
9. ✅ `-u` flag for Python (`python3 -u`)?
10. ✅ Non-interactive (no vi/psql/node REPL)?

---

## ALWAYS

- `git --no-pager` for git log/diff/show/branch
- `--color=never` / `NO_COLOR=1` — disable ANSI escape codes
- `2>&1` — capture stderr alongside stdout
- `| head -N` or `> brain/tasks/out.txt` — limit or redirect large output
- `grep 'pattern' file || true` — suppress exit code 1 (single quotes!)

---

## NEVER

- `cd /path && command` — use absolute paths
- `sleep N` as a standalone wait command
- Unbounded output — always pipe to `head -N` or redirect
- `rm -i`, `apt install` without `-y` — avoid interactive prompts
- `vi`, `nano` or any editor in terminal

---

## Quick Reference: Large Output Commands

| Command          | Safe version                       |
| ---------------- | ---------------------------------- | ---------- |
| `git log`        | `git --no-pager log --oneline -20` |
| `git diff`       | `git --no-pager diff HEAD          | head -100` |
| `git show`       | `git --no-pager show HEAD          | head -50`  |
| `git stash list` | `git --no-pager stash list`        |
| `find .`         | `find . -maxdepth 3 -name '\*.ts'  | head -30`  |
| `grep -r`        | `grep -rn 'pattern' .              | head -40`  |

---

## After any terminal issue

Update this file AND `brain/tasks/lessons.md` with the new pattern immediately.
