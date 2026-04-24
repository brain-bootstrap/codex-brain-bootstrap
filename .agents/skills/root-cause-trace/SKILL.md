---
name: root-cause-trace
description: 5-step root cause trace for errors deep in execution. Use when the error surface is far from the actual trigger. Trace backwards from the symptom to the origin.
---

# Root Cause Trace Skill

Trace errors from symptom to origin in 5 steps.

## When to use
- Error message is in a library/framework, not your code
- Test is failing but the failure is in a utility method far from the real bug
- Behavior changed after a commit but the commit seems unrelated
- "It works on my machine" — environment-specific failure

## 5-Step Protocol

### Step 1 — OBSERVE: Capture the exact symptom
```bash
# Run the failing command and capture output
<test or command> 2>&1 | head -80
```
Record:
- Exact error message (word-for-word, not paraphrased)
- Exact stack trace (which file, which line)
- Exact input that triggers it
- Is it deterministic or flaky?

### Step 2 — HYPOTHESIZE: List possible origins
Based on the stack trace, generate hypotheses from most to least likely:
1. Most likely: code you changed most recently
2. Second: code the error path touches that you're unfamiliar with
3. Third: configuration or environment differences

For each hypothesis, write what evidence would confirm or deny it.

### Step 3 — TRACE BACKWARDS: Follow the call stack up
Starting at the error line, trace each caller:
```bash
grep -rn --color=never '<error_function>' . | head -20
```
Go up level by level. At each level ask: "Could this be where the wrong value was introduced?"

### Step 4 — BINARY SEARCH: Narrow to one function
If the trace is long (>5 levels):
- Identify the midpoint of the call chain
- Add a temporary debug assertion or log at that midpoint
- If the value is wrong there: bug is in the top half
- If the value is right there: bug is in the bottom half
- Repeat until you've narrowed to one function

### Step 5 — PROVE: Write a reproducing test before fixing
```bash
# Write a test that:
# 1. Inputs the exact triggering value
# 2. Asserts the correct output
# 3. Currently fails (red)
# Then apply the fix and verify it passes (green)
```

## Output
After tracing:
```
Root Cause: <function_name> in <file>:<line>
Trigger: <what causes this function to receive the wrong input>
Fix: <minimal change needed>
Test: <test that reproduces and verifies the fix>
```
