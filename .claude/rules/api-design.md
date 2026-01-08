# REST API Design Rules

Standards for designing consistent, maintainable REST APIs.

## URL Design

### Resource Naming
- Use **nouns**, not verbs
- Use **plural** for collections
- Use **kebab-case** for multi-word resources

```
✓ GET  /users
✓ GET  /users/123
✓ GET  /users/123/orders
✓ GET  /order-items

✗ GET  /getUsers
✗ GET  /user/123
✗ GET  /users/123/getOrders
✗ GET  /orderItems
```

### Hierarchical Resources
Express relationships through nesting (max 2 levels):

```
GET  /users/123/orders          # User's orders
GET  /orders/456/items          # Order's items

# Avoid deep nesting:
✗ GET /users/123/orders/456/items/789
✓ GET /order-items/789
```

### Query Parameters
Use for filtering, sorting, pagination:

```
GET /users?status=active&sort=-created_at&page=2&limit=20
GET /orders?user_id=123&from=2024-01-01&to=2024-12-31
```

## HTTP Methods

| Method | Purpose | Idempotent | Safe |
|--------|---------|------------|------|
| GET | Retrieve resource(s) | Yes | Yes |
| POST | Create resource | No | No |
| PUT | Replace resource entirely | Yes | No |
| PATCH | Partial update | Yes | No |
| DELETE | Remove resource | Yes | No |

### Method Guidelines

```
GET    /users          # List all users
GET    /users/123      # Get specific user
POST   /users          # Create new user
PUT    /users/123      # Replace user entirely
PATCH  /users/123      # Update user partially
DELETE /users/123      # Delete user
```

## HTTP Status Codes

### Success (2xx)
| Code | Usage |
|------|-------|
| 200 | Successful GET, PUT, PATCH, DELETE |
| 201 | Successful POST (resource created) |
| 202 | Accepted (async processing) |
| 204 | Successful DELETE (no content) |

### Client Errors (4xx)
| Code | Usage |
|------|-------|
| 400 | Bad request (validation error) |
| 401 | Unauthorized (not authenticated) |
| 403 | Forbidden (not authorized) |
| 404 | Resource not found |
| 409 | Conflict (duplicate, version mismatch) |
| 422 | Unprocessable entity (semantic error) |
| 429 | Too many requests (rate limited) |

### Server Errors (5xx)
| Code | Usage |
|------|-------|
| 500 | Internal server error |
| 502 | Bad gateway |
| 503 | Service unavailable |
| 504 | Gateway timeout |

## Request/Response Format

### Request Headers

```
Content-Type: application/json
Accept: application/json
Authorization: Bearer <token>
X-Request-ID: <uuid>
```

### Response Structure

**Success Response:**
```json
{
  "data": {
    "id": "123",
    "name": "John Doe",
    "email": "john@example.com"
  },
  "meta": {
    "request_id": "req_abc123"
  }
}
```

**Collection Response:**
```json
{
  "data": [
    { "id": "1", "name": "Item 1" },
    { "id": "2", "name": "Item 2" }
  ],
  "meta": {
    "total": 100,
    "page": 1,
    "limit": 20,
    "has_more": true
  }
}
```

**Error Response:**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request parameters",
    "details": [
      {
        "field": "email",
        "message": "must be a valid email address"
      }
    ]
  },
  "meta": {
    "request_id": "req_abc123"
  }
}
```

## Versioning

### URL Path Versioning (Recommended)
```
GET /api/v1/users
GET /api/v2/users
```

### Version Lifecycle
1. Announce deprecation with timeline
2. Add `Deprecation` header to responses
3. Support old version for minimum 6 months
4. Remove after migration period

```
Deprecation: true
X-API-Version: v1
X-API-Deprecation-Date: 2025-06-01
```

## Pagination

### Offset-Based
```
GET /users?page=2&limit=20
```

Response:
```json
{
  "meta": {
    "total": 100,
    "page": 2,
    "limit": 20,
    "total_pages": 5
  }
}
```

### Cursor-Based (for large datasets)
```
GET /users?cursor=eyJpZCI6MTIzfQ&limit=20
```

Response:
```json
{
  "meta": {
    "next_cursor": "eyJpZCI6MTQzfQ",
    "has_more": true
  }
}
```

## Filtering & Sorting

### Filtering
```
GET /orders?status=pending
GET /orders?status=pending,processing
GET /orders?created_at[gte]=2024-01-01
GET /orders?price[lt]=100
```

### Sorting
```
GET /users?sort=name              # Ascending
GET /users?sort=-created_at       # Descending
GET /users?sort=status,-name      # Multiple fields
```

## Authentication & Security

### Authentication Methods
- **Bearer Token** (JWT): `Authorization: Bearer <token>`
- **API Key**: `X-API-Key: <key>`
- **OAuth 2.0**: For third-party access

### Security Headers
```
Strict-Transport-Security: max-age=31536000
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Content-Security-Policy: default-src 'self'
```

### Rate Limiting Headers
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640995200
```

## Idempotency

For non-idempotent operations (POST), support idempotency keys:

```
POST /payments
X-Idempotency-Key: <unique-uuid>
```

## Documentation

### Required Documentation
- OpenAPI/Swagger specification
- Authentication guide
- Rate limiting details
- Error code reference
- Changelog

### OpenAPI Example
```yaml
openapi: 3.0.3
info:
  title: API Name
  version: 1.0.0
paths:
  /users:
    get:
      summary: List users
      parameters:
        - name: page
          in: query
          schema:
            type: integer
      responses:
        '200':
          description: Success
```
