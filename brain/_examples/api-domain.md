# API Domain Rules

<!-- Template — fill with your project's actual API conventions -->

## Authentication

- **Method**: {{AUTH_METHOD}} (JWT / OAuth2 / API key / session cookie)
- **Token location**: {{TOKEN_LOCATION}} (Authorization header / cookie / query param)
- **Expiry**: {{TOKEN_EXPIRY}}
- **Refresh**: {{REFRESH_STRATEGY}}

## Endpoint Conventions

- **Base URL pattern**: `{{BASE_URL_PATTERN}}`
- **Versioning**: `{{VERSIONING_STRATEGY}}` (path prefix / header / none)
- **Pagination**: `{{PAGINATION_STRATEGY}}` (cursor / offset-limit)
- **Error format**: `{"error": "...", "code": "...", "details": {...}}`

## Rate Limits

- **Default**: {{RATE_LIMIT_DEFAULT}} req/min per API key
- **Burst**: {{RATE_LIMIT_BURST}}
- **Headers**: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

## Common Pitfalls

<!-- Add non-obvious API behaviors that cause bugs -->
<!-- Example: "Endpoint X returns 200 even on partial failure — check `data.errors` field" -->

## Key Endpoints

| Endpoint | Method | Auth required | Notes |
| -------- | ------ | ------------- | ----- |

<!-- Add your project's key endpoints -->
