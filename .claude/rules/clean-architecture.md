# Clean Architecture Rules

These rules enforce Clean Architecture / Onion Architecture patterns.

## The Dependency Rule

**Dependencies must point inward.** Inner layers must not know about outer layers.

```
┌──────────────────────────────────────────────────┐
│                   Frameworks                      │
│  ┌──────────────────────────────────────────┐    │
│  │             Interface Adapters            │    │
│  │  ┌──────────────────────────────────┐    │    │
│  │  │         Application Layer         │    │    │
│  │  │  ┌──────────────────────────┐    │    │    │
│  │  │  │      Domain Layer        │    │    │    │
│  │  │  │     (Entities/Core)      │    │    │    │
│  │  │  └──────────────────────────┘    │    │    │
│  │  └──────────────────────────────────┘    │    │
│  └──────────────────────────────────────────┘    │
└──────────────────────────────────────────────────┘

Dependency Direction: Outside → Inside
```

## Layer Definitions

### Domain Layer (Innermost)
- **Contains**: Entities, Value Objects, Domain Services, Domain Events
- **Depends on**: Nothing (pure business logic)
- **No imports from**: usecase, adapter, infrastructure, frameworks

```go
// domain/user/entity.go
package user

type User struct {
    ID    UserID
    Email Email
    Name  string
}

// Domain methods - pure business logic
func (u *User) CanPerformAction(action Action) bool {
    // Business rules only
}
```

### Application Layer (Use Cases)
- **Contains**: Use Cases, Application Services, DTOs, Interfaces
- **Depends on**: Domain layer only
- **No imports from**: adapter, infrastructure, frameworks

```go
// usecase/user/create.go
package user

type CreateUserUseCase interface {
    Execute(ctx context.Context, input CreateUserInput) (CreateUserOutput, error)
}

type CreateUserInput struct {
    Email string
    Name  string
}

type CreateUserOutput struct {
    UserID string
}
```

### Interface Adapters Layer
- **Contains**: Controllers, Presenters, Gateways, Repository Implementations
- **Depends on**: Application and Domain layers
- **No imports from**: Specific frameworks (abstract them)

```go
// adapter/controller/user_controller.go
package controller

type UserController struct {
    createUser usecase.CreateUserUseCase
}

func (c *UserController) Create(ctx echo.Context) error {
    // Convert HTTP request to use case input
    // Call use case
    // Convert output to HTTP response
}
```

### Infrastructure Layer (Outermost)
- **Contains**: Database, External APIs, Frameworks, Configuration
- **Depends on**: All inner layers (implements their interfaces)

```go
// infrastructure/repository/user_repository.go
package repository

type PostgresUserRepository struct {
    db *sql.DB
}

func (r *PostgresUserRepository) Save(ctx context.Context, user *domain.User) error {
    // Database-specific implementation
}
```

## Directory Structure

### Backend (Go/Python)

```
project/
├── cmd/                    # Entry points
│   └── api/
│       └── main.go
├── internal/               # Private application code
│   ├── domain/            # Domain layer
│   │   └── user/
│   │       ├── entity.go
│   │       ├── value_object.go
│   │       └── repository.go  # Interface only
│   ├── usecase/           # Application layer
│   │   └── user/
│   │       ├── create.go
│   │       ├── create_test.go
│   │       └── interface.go
│   ├── adapter/           # Interface adapters
│   │   ├── controller/
│   │   ├── presenter/
│   │   └── gateway/
│   └── infrastructure/    # External concerns
│       ├── database/
│       ├── external/
│       └── config/
└── pkg/                   # Public libraries
```

### Frontend (TypeScript)

```
src/
├── app/                   # Framework (Next.js routes)
├── domain/               # Domain layer
│   └── user/
│       ├── entity.ts
│       └── repository.interface.ts
├── application/          # Use cases
│   └── user/
│       ├── createUser.usecase.ts
│       └── createUser.usecase.test.ts
├── infrastructure/       # External
│   ├── api/
│   └── storage/
└── presentation/         # UI layer
    ├── components/
    └── hooks/
```

## Import Rules

### Allowed Imports

| From Layer | Can Import From |
|------------|-----------------|
| Domain | (nothing external) |
| UseCase | Domain |
| Adapter | UseCase, Domain |
| Infrastructure | All layers |
| Main/Entry | All layers |

### Forbidden Imports

```go
// ❌ FORBIDDEN: Domain importing from UseCase
package domain

import "project/internal/usecase" // VIOLATION!

// ❌ FORBIDDEN: UseCase importing from Adapter
package usecase

import "project/internal/adapter" // VIOLATION!

// ❌ FORBIDDEN: UseCase importing framework directly
package usecase

import "github.com/labstack/echo/v4" // VIOLATION!
```

## Interface Placement

Interfaces belong to the **consumer**, not the provider:

```go
// ✓ CORRECT: Interface in use case layer (consumer)
// internal/usecase/user/interface.go
package user

type UserRepository interface {
    Save(ctx context.Context, user *domain.User) error
    FindByID(ctx context.Context, id domain.UserID) (*domain.User, error)
}

// Implementation in infrastructure (provider)
// internal/infrastructure/repository/user.go
package repository

type PostgresUserRepository struct { /* ... */ }
func (r *PostgresUserRepository) Save(/* ... */) error { /* ... */ }
```

## Data Transfer Rules

### Between Layers

Each layer should have its own data structures:

```go
// Domain entity
type User struct { /* domain fields */ }

// Use case DTO
type CreateUserInput struct { /* input fields */ }
type CreateUserOutput struct { /* output fields */ }

// HTTP request/response
type CreateUserRequest struct { /* JSON fields */ }
type CreateUserResponse struct { /* JSON fields */ }
```

### Conversion Responsibility

- Controllers convert HTTP ↔ UseCase DTOs
- Use Cases convert DTOs ↔ Domain
- Repositories convert Domain ↔ Database models

## Testing Strategy

### Domain Layer
- Pure unit tests
- No mocks needed
- Test business logic directly

### Use Case Layer
- Unit tests with mocked repositories
- Test orchestration logic
- Verify correct method calls

### Adapter Layer
- Integration tests
- Test data conversion
- Test error handling

### Infrastructure Layer
- Integration tests with real/test databases
- Contract tests for external APIs
