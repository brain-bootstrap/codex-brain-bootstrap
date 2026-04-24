---
name: cross-layer-check
description: Verify that a new field, enum value, or status code exists consistently across all layers. Use after adding new fields to prevent cross-layer inconsistency (DB → service → API → tests).
---

# Cross-Layer Check Skill

Verify a symbol is consistently propagated across all layers.

## When to use
- Added a new field to a model/schema
- Added a new enum value
- Added a new API endpoint or status code
- Renamed a field anywhere in the stack
- After any change that touches a shared data contract

## Protocol

### 1. Identify the symbol
What is the exact name of the new/changed field, enum value, or endpoint?

### 2. Grep across all layers
```bash
# Search for the symbol everywhere
grep -rn --color=never '<symbol_name>' . \
  --include='*.ts' \
  --include='*.js' \
  --include='*.py' \
  --include='*.go' \
  --include='*.java' \
  --include='*.sql' \
  | grep -v 'node_modules\|.git\|dist\|build' \
  | head -50
```

### 3. Verify presence in each layer
Check the following layers (adapt to your stack):

| Layer | What to check |
|-------|--------------|
| DB schema | Migration file, model definition |
| Repository/DAO | Query selects/inserts include the field |
| Service | Business logic handles the new field |
| Mapper/Serializer | Field mapped in both directions |
| DTO/Type | Type definition includes the field |
| Validator | Field validated if required |
| API response | Field included in response schema |
| API tests | Tests assert the field in responses |
| Unit tests | Tests cover the new enum value/case |
| Docs/OpenAPI | Spec updated (if applicable) |

### 4. Identify gaps
For each layer where the symbol is missing:
- Is the absence intentional (the layer doesn't need it)?
- Or is it a bug (it was forgotten)?

### 5. Fix the gaps
For each genuine gap, apply the minimal fix to add the symbol.

### 6. Re-run grep to confirm coverage
```bash
grep -rn --color=never '<symbol_name>' . | grep -v 'node_modules\|.git' | head -50
```

### 7. Run tests
```bash
# (use the test command from brain/build.md)
```

## Output
```
Cross-Layer Check: <symbol_name>
✅ DB schema
✅ Repository
❌ Service — MISSING: field not handled in processOrder()
✅ DTO
❌ Tests — MISSING: no test asserts <symbol_name> in response
```
