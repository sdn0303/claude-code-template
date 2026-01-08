# Prompt Engineering Examples

Concrete examples for common development scenarios.

## 1. Code Review Request

```xml
<context>
Project: [project-name]
Component: [component-name]
Language: Go 1.23
Architecture: Clean Architecture

Files to Review:
- internal/usecase/user/create.go
- internal/usecase/user/create_test.go
</context>

<instructions>
Review the code for:

1. **Correctness**
   - Logic validity
   - Edge case handling
   - Error management

2. **Go Idioms**
   - Naming (MixedCaps, short names for short scopes)
   - Immediate error checks
   - Context propagation

3. **Architecture**
   - Dependency direction
   - Layer data conversion
   - Interface design

4. **Testability**
   - Interface segregation
   - Dependency injection
   - Mock capability
</instructions>

<output_format>
## Review Summary
- Strengths: [count]
- Issues: [count] (Critical: X, High: X, Medium: X, Low: X)

## Strengths
- ...

## Issues
1. [HIGH] Issue Title
   - **Problem**: What's wrong
   - **Recommendation**: How to fix
   - **Location**: file:line
   - **Reason**: Why it matters
</output_format>
```

## 2. Test Generation

```xml
<context>
Target: usecase.CreateUserUseCase.Execute
Framework: Go testing + testify
Mocks: mockery-generated

Dependencies:
- UserRepository (data persistence)
- EventPublisher (domain events)
</context>

<instructions>
Generate table-driven tests for:

1. Success: Valid user creation
2. Error: Invalid email format
3. Error: Duplicate email exists
4. Error: Repository failure
5. Edge: Empty optional fields
</instructions>

<output_format>
func TestCreateUser(t *testing.T) {
    tests := []struct {
        name      string
        input     CreateUserInput
        setupMock func(*mocks.MockUserRepository)
        want      CreateUserOutput
        wantErr   error
    }{
        // Test cases
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Arrange
            // Act
            // Assert
        })
    }
}
</output_format>
```

## 3. Error Design

```xml
<context>
Component: Order Service
Target: Payment processing
Error Types:
- Retryable (exponential backoff)
- Non-retryable (user action needed)
Logging: Structured JSON
Correlation: trace_id, request_id
</context>

<instructions>
Design error handling for:

1. Payment gateway timeout
2. Insufficient funds
3. Invalid card number
4. Internal processing error
</instructions>

<examples>
<example>
<scenario>Resource not found</scenario>
<log>
{
  "severity": "WARNING",
  "component": "order-service",
  "error_code": "ORDER_NOT_FOUND",
  "message": "order not found",
  "order_id": "ord_xxx",
  "trace_id": "trace_xxx",
  "retryable": false
}
</log>
</example>
</examples>
```

## 4. API Endpoint Design

```xml
<context>
API: REST
Framework: Echo v4
Auth: JWT Bearer
</context>

<instructions>
Design endpoint for user profile update:

- Partial updates allowed
- Email change requires verification
- Profile picture upload separate
</instructions>

<output_format>
## Endpoint

PATCH /api/v1/users/{id}/profile

### Request
```json
{
  "name": "string (optional)",
  "bio": "string (optional)",
  "preferences": {
    "notifications": "boolean (optional)"
  }
}
```

### Response

**200 OK**
```json
{
  "data": {
    "id": "user_xxx",
    "name": "Updated Name",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

**Errors**
- 400: Validation error
- 401: Not authenticated
- 403: Not authorized
- 404: User not found
</output_format>
```

## 5. Refactoring Request

```xml
<context>
Target: internal/service/order.go
Problem: Function too long (150 lines), multiple responsibilities
Constraint: Maintain API compatibility
</context>

<instructions>
Propose refactoring for:

1. Code structure improvement
2. Readability enhancement
3. Testability increase
</instructions>

<output_format>
## Refactoring Plan

### Overview
[Strategy summary]

### Step 1: [Change]

**Before:**
```go
// Current code
```

**After:**
```go
// Improved code
```

**Impact:** [What this achieves]

### Step 2: [Change]
...

### Verification
- [ ] Tests pass
- [ ] API unchanged
- [ ] Complexity reduced
</output_format>
```

## 6. Architecture Decision

```xml
<context>
Decision: Message queue selection
Stakeholders: Backend team, DevOps
Constraints:
- GCP hosted
- < 10k messages/second
- At-least-once delivery required
</context>

<instructions>
Create ADR comparing:
- Google Cloud Pub/Sub
- Cloud Tasks
- Redis Streams
</instructions>

<output_format>
# ADR-XXX: Message Queue Selection

## Status
Proposed

## Context
[Background and requirements]

## Decision
[Selected option and reasoning]

## Options Considered

### Option A: Pub/Sub
- **Pros**: ...
- **Cons**: ...

### Option B: Cloud Tasks
- **Pros**: ...
- **Cons**: ...

## Consequences
- **Benefits**: ...
- **Risks**: ...
- **Trade-offs**: ...
</output_format>
```

## 7. Documentation Generation

```xml
<context>
Target: internal/usecase/payment/process.go
Doc Type: Technical reference
Audience: Backend developers
</context>

<instructions>
Generate documentation:

1. Overview (purpose, architecture position)
2. Dependencies (required packages)
3. Basic usage (minimal example)
4. API reference (methods, params)
5. Error handling (common errors)
6. Examples (practical usage)
</instructions>
```

## Usage Guidelines

1. **Be Specific**: Include concrete context
2. **Set Constraints**: Define boundaries clearly
3. **Specify Output**: Show expected format
4. **Provide Examples**: Include samples when complex
