# Build, Test & CI Reference — {{PROJECT_NAME}}

<!-- BOOTSTRAP: Run $bootstrap to fill in the placeholders automatically. -->

## Package Manager & Runtime

- **Package manager**: {{PACKAGE_MANAGER}} (version: {{PACKAGE_MANAGER_VERSION}})
- **Runtime**: {{RUNTIME}} (version: {{RUNTIME_VERSION}})
<!-- Examples: pnpm 10+, npm 10+, pip 24+, cargo 1.75+, go 1.22+, maven 3.9+ -->

## Build Commands

| Scope                 | Command                |
| --------------------- | ---------------------- |
| All                   | `{{BUILD_CMD_ALL}}`    |
| Single service/module | `{{BUILD_CMD_SINGLE}}` |
| Type-check only       | `{{TYPECHECK_CMD}}`    |

<!-- Examples: pnpm build, cargo build --release, mvn clean install -DskipTests -->

## Test Commands

| Scope              | Command                 |
| ------------------ | ----------------------- |
| All tests          | `{{TEST_CMD_ALL}}`      |
| Single file        | `{{TEST_CMD_SINGLE}}`   |
| CI mode (no watch) | `{{TEST_CMD_CI}}`       |
| With coverage      | `{{TEST_CMD_COVERAGE}}` |

<!-- Examples: pnpm test, pytest, cargo test, mvn test -->

## Lint & Format Commands

| Action              | Command                |
| ------------------- | ---------------------- |
| Check (report only) | `{{LINT_CHECK_CMD}}`   |
| Fix (auto-fix)      | `{{LINT_FIX_CMD}}`     |
| Format check        | `{{FORMAT_CHECK_CMD}}` |
| Format fix          | `{{FORMAT_FIX_CMD}}`   |

<!-- Examples: biome check, eslint ., ruff check, cargo clippy -->

## CI Pipeline

<!-- Describe CI stages in order -->
<!-- Example:
1. Install dependencies
2. Lint / format check
3. Build
4. Unit tests
5. Integration tests
6. Security scan
-->

## Local Development

### Prerequisites

<!-- Required tools and versions -->
<!-- Example: Node 22+, pnpm 10+, Docker, PostgreSQL 16+ -->

### Quick Start

```bash
# {{INSTALL_CMD}}
# {{DEV_CMD}}
```

### Database Setup (if applicable)

```bash
# {{DB_MIGRATE_CMD}}
# {{DB_SEED_CMD}}
```

### ⚠️ Known Pitfalls

<!-- Add gotchas discovered during development -->
<!-- Example: "Service X imports process.exit in test — run it in isolation" -->
