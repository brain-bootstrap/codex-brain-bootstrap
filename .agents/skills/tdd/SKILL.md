---
name: tdd
description: Test-Driven Development workflow. Write failing tests FIRST, then implement to make them pass. Use when adding new functionality or fixing bugs. Enforces the red-green-refactor cycle.
---

# TDD Skill

Enforce the write-test-first discipline.

## When to use
- Adding any new function, method, or behavior
- Fixing a bug (write a failing test that reproduces it first)
- Refactoring (tests must already pass before touching implementation)

## Protocol

### 1. Read existing test patterns
Before writing anything, find an existing test file in the same area:
```bash
find . -name '*.test.*' -o -name '*.spec.*' | head -10
```
Read one. Match the exact same structure, imports, and assertion style.

### 2. Write the failing test first (RED)
- The test must fail for the right reason (not because of import errors)
- Name the test with the exact behavior: `it('should return 404 when user not found')`
- Cover the happy path AND at least one failure path
- Do NOT write implementation code yet

### 3. Run the test — verify it fails
```bash
# Replace with your project's test command from brain/build.md
npm test -- --testPathPattern=<filename>
```
If the test passes without implementation: your test is wrong. Fix it.

### 4. Write the minimal implementation (GREEN)
- Write the smallest amount of code that makes the test pass
- No extra features, no speculative code
- Run the test again — it must pass

### 5. Refactor (REFACTOR)
- Clean up the implementation without changing behavior
- Run the tests again after every refactor step
- Tests must still pass

### 6. Repeat for each new behavior
One test → one behavior → minimal implementation → refactor.

## Rules
- NEVER write implementation before the test
- NEVER write a test that stubs everything and asserts nothing useful
- NEVER skip the RED phase — the test MUST fail first
- Every new code path must have a corresponding test
- Tests assert behavior, not implementation details

## Framework selection
Read `brain/build.md` to identify the test framework. Use the same framework and runner as the rest of the project.
