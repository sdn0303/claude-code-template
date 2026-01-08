---
name: api-design
description: API design patterns including REST, GraphQL, versioning, error handling, and documentation. Use when designing or reviewing API endpoints.
---

# API Design Skill

Comprehensive API design patterns and best practices.

## REST API Design Principles

### URL Structure
```
# Resource naming (plural nouns, kebab-case)
GET    /api/v1/users                    # List users
GET    /api/v1/users/{id}               # Get user
POST   /api/v1/users                    # Create user
PUT    /api/v1/users/{id}               # Replace user
PATCH  /api/v1/users/{id}               # Update user
DELETE /api/v1/users/{id}               # Delete user

# Nested resources (max 2 levels)
GET    /api/v1/users/{userId}/orders    # User's orders
GET    /api/v1/orders/{orderId}/items   # Order items

# Actions on resources (verb suffix when necessary)
POST   /api/v1/users/{id}/activate      # Action on user
POST   /api/v1/orders/{id}/cancel       # Cancel order

# Filtering, sorting, pagination
GET    /api/v1/users?status=active&sort=-createdAt&limit=20&offset=0
```

### HTTP Methods Semantics
| Method  | Idempotent | Safe | Request Body | Response Body |
|---------|------------|------|--------------|---------------|
| GET     | Yes        | Yes  | No           | Yes           |
| POST    | No         | No   | Yes          | Yes           |
| PUT     | Yes        | No   | Yes          | Yes           |
| PATCH   | No         | No   | Yes          | Yes           |
| DELETE  | Yes        | No   | No           | Optional      |
| HEAD    | Yes        | Yes  | No           | No            |
| OPTIONS | Yes        | Yes  | No           | Yes           |

### HTTP Status Codes
```
# Success (2xx)
200 OK                  # GET, PUT, PATCH success
201 Created             # POST success (include Location header)
202 Accepted            # Async operation accepted
204 No Content          # DELETE success, no body

# Client Errors (4xx)
400 Bad Request         # Malformed request, validation error
401 Unauthorized        # Missing/invalid authentication
403 Forbidden           # Authenticated but not authorized
404 Not Found           # Resource doesn't exist
405 Method Not Allowed  # HTTP method not supported
409 Conflict            # State conflict (duplicate, version mismatch)
422 Unprocessable Entity# Valid syntax but semantic error
429 Too Many Requests   # Rate limit exceeded

# Server Errors (5xx)
500 Internal Server Error  # Unexpected server error
502 Bad Gateway            # Upstream service error
503 Service Unavailable    # Temporary overload/maintenance
504 Gateway Timeout        # Upstream timeout
```

## Request/Response Design

### Request Headers
```http
# Authentication
Authorization: Bearer <jwt-token>
X-API-Key: <api-key>

# Content negotiation
Accept: application/json
Content-Type: application/json

# Request identification
X-Request-ID: uuid-v4
X-Correlation-ID: uuid-v4

# Conditional requests
If-Match: "etag-value"
If-None-Match: "etag-value"
If-Modified-Since: Wed, 21 Oct 2024 07:28:00 GMT
```

### Response Headers
```http
# Caching
Cache-Control: private, max-age=3600
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
Last-Modified: Wed, 21 Oct 2024 07:28:00 GMT

# Rate limiting
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1698307200
Retry-After: 60

# CORS
Access-Control-Allow-Origin: https://example.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization

# Security
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Strict-Transport-Security: max-age=31536000; includeSubDomains
```

### Standard Response Envelope
```json
// Success response
{
  "data": {
    "id": "usr_123",
    "type": "user",
    "attributes": {
      "name": "John Doe",
      "email": "john@example.com"
    }
  },
  "meta": {
    "requestId": "req_abc123",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}

// Collection response
{
  "data": [
    { "id": "usr_123", "name": "John" },
    { "id": "usr_456", "name": "Jane" }
  ],
  "meta": {
    "total": 100,
    "page": 1,
    "pageSize": 20
  },
  "links": {
    "self": "/api/v1/users?page=1",
    "next": "/api/v1/users?page=2",
    "last": "/api/v1/users?page=5"
  }
}
```

## Error Handling

### Error Response Format
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "email",
        "code": "INVALID_FORMAT",
        "message": "Email format is invalid"
      },
      {
        "field": "age",
        "code": "OUT_OF_RANGE",
        "message": "Age must be between 0 and 150"
      }
    ],
    "requestId": "req_abc123",
    "documentationUrl": "https://api.example.com/docs/errors#VALIDATION_ERROR"
  }
}
```

### Error Code Convention
```
# Format: DOMAIN_ACTION_REASON
AUTH_TOKEN_EXPIRED
AUTH_TOKEN_INVALID
AUTH_PERMISSION_DENIED

USER_NOT_FOUND
USER_ALREADY_EXISTS
USER_EMAIL_DUPLICATE

ORDER_INSUFFICIENT_STOCK
ORDER_PAYMENT_FAILED
ORDER_ALREADY_CANCELLED

VALIDATION_REQUIRED_FIELD
VALIDATION_INVALID_FORMAT
VALIDATION_OUT_OF_RANGE

RATE_LIMIT_EXCEEDED
SYSTEM_INTERNAL_ERROR
SYSTEM_SERVICE_UNAVAILABLE
```

## Pagination Patterns

### Offset Pagination
```http
GET /api/v1/users?limit=20&offset=40

Response:
{
  "data": [...],
  "meta": {
    "total": 150,
    "limit": 20,
    "offset": 40
  }
}
```
**Pros**: Simple, supports random access
**Cons**: Inconsistent with concurrent writes, slow for large offsets

### Cursor Pagination
```http
GET /api/v1/users?limit=20&cursor=eyJpZCI6MTAwfQ==

Response:
{
  "data": [...],
  "meta": {
    "hasMore": true,
    "nextCursor": "eyJpZCI6MTIwfQ=="
  }
}
```
**Pros**: Consistent, performant for large datasets
**Cons**: No random access, no total count

### Keyset Pagination
```http
GET /api/v1/users?limit=20&after_id=100&after_created=2024-01-15T10:00:00Z

Response:
{
  "data": [...],
  "meta": {
    "hasMore": true
  }
}
```
**Pros**: Most performant, stable
**Cons**: Complex for multi-column sorting

## Versioning Strategies

### URL Path Versioning (Recommended)
```
GET /api/v1/users
GET /api/v2/users
```
**Pros**: Clear, cacheable, easy routing
**Cons**: URL changes between versions

### Header Versioning
```http
GET /api/users
Accept: application/vnd.api+json; version=2
# or
X-API-Version: 2
```
**Pros**: Clean URLs
**Cons**: Less discoverable, harder to test

### Query Parameter
```
GET /api/users?version=2
```
**Pros**: Simple, easy testing
**Cons**: Can break caching, less conventional

## API Security

### Authentication Patterns
```go
// JWT Bearer Token
type JWTClaims struct {
    UserID    string   `json:"sub"`
    Email     string   `json:"email"`
    Roles     []string `json:"roles"`
    ExpiresAt int64    `json:"exp"`
}

// API Key (for service-to-service)
// Header: X-API-Key: sk_live_xxxxx

// OAuth 2.0 Scopes
// Scope: users:read users:write orders:read
```

### Rate Limiting
```go
// Token bucket algorithm
type RateLimiter struct {
    tokens     float64
    maxTokens  float64
    refillRate float64 // tokens per second
    lastRefill time.Time
}

// Sliding window
type SlidingWindowLimiter struct {
    windowSize time.Duration
    maxRequests int
    requests    []time.Time
}
```

### Input Validation
```go
// Validate at API boundary
type CreateUserRequest struct {
    Email    string `json:"email" validate:"required,email,max=255"`
    Password string `json:"password" validate:"required,min=8,max=128"`
    Name     string `json:"name" validate:"required,min=1,max=100"`
    Age      int    `json:"age" validate:"gte=0,lte=150"`
}

// Sanitize outputs
func sanitizeUser(u *User) *UserResponse {
    return &UserResponse{
        ID:    u.ID,
        Email: u.Email,
        Name:  u.Name,
        // Exclude: password, internalFlags, etc.
    }
}
```

## GraphQL Patterns

### Schema Design
```graphql
type Query {
  user(id: ID!): User
  users(filter: UserFilter, pagination: Pagination): UserConnection!
}

type Mutation {
  createUser(input: CreateUserInput!): CreateUserPayload!
  updateUser(id: ID!, input: UpdateUserInput!): UpdateUserPayload!
  deleteUser(id: ID!): DeleteUserPayload!
}

type User {
  id: ID!
  email: String!
  name: String!
  orders(first: Int, after: String): OrderConnection!
  createdAt: DateTime!
}

# Relay-style pagination
type UserConnection {
  edges: [UserEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type UserEdge {
  node: User!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}

# Input types
input CreateUserInput {
  email: String!
  password: String!
  name: String!
}

# Payload types (for mutations)
type CreateUserPayload {
  user: User
  errors: [UserError!]
}

type UserError {
  field: String
  message: String!
  code: ErrorCode!
}
```

### DataLoader Pattern
```typescript
// N+1 problem solution
const userLoader = new DataLoader<string, User>(async (ids) => {
  const users = await userRepository.findByIds(ids);
  const userMap = new Map(users.map(u => [u.id, u]));
  return ids.map(id => userMap.get(id) ?? new Error(`User ${id} not found`));
});

// Usage in resolver
const resolvers = {
  Order: {
    user: (order, _, { loaders }) => loaders.userLoader.load(order.userId),
  },
};
```

## OpenAPI Documentation

### Specification Structure
```yaml
openapi: 3.1.0
info:
  title: User API
  version: 1.0.0
  description: API for managing users

servers:
  - url: https://api.example.com/v1
    description: Production

paths:
  /users:
    get:
      operationId: listUsers
      summary: List all users
      tags: [Users]
      parameters:
        - $ref: '#/components/parameters/limitParam'
        - $ref: '#/components/parameters/offsetParam'
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserListResponse'
        '401':
          $ref: '#/components/responses/Unauthorized'

components:
  schemas:
    User:
      type: object
      required: [id, email, name]
      properties:
        id:
          type: string
          format: uuid
          example: "123e4567-e89b-12d3-a456-426614174000"
        email:
          type: string
          format: email
        name:
          type: string
          maxLength: 100

  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

security:
  - bearerAuth: []
```

## API Best Practices Checklist

### Design
- [ ] Use nouns for resources, verbs for actions
- [ ] Consistent naming (plural, kebab-case)
- [ ] Max 2 levels of nesting
- [ ] Meaningful HTTP status codes
- [ ] Consistent error response format

### Security
- [ ] HTTPS only
- [ ] Authentication on all endpoints
- [ ] Rate limiting implemented
- [ ] Input validation at boundary
- [ ] Output sanitization

### Performance
- [ ] Pagination for collections
- [ ] Partial responses (fields parameter)
- [ ] ETags for caching
- [ ] Compression (gzip/brotli)
- [ ] Connection pooling

### Operations
- [ ] Request ID tracing
- [ ] Health check endpoint
- [ ] Structured logging
- [ ] API versioning strategy
- [ ] Deprecation policy documented
