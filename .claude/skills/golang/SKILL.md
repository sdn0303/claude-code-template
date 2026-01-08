---
name: golang
description: Go language best practices, idioms, and patterns. Use when writing, reviewing, or refactoring Go code.
---

# Go Development Skill

Best practices for writing idiomatic, maintainable Go code.

## Project Structure

```
project/
├── cmd/                    # Entry points
│   └── api/
│       └── main.go
├── internal/               # Private code
│   ├── domain/            # Business entities
│   ├── usecase/           # Application logic
│   ├── adapter/           # Interface adapters
│   │   ├── controller/
│   │   └── repository/
│   └── infrastructure/    # External services
├── pkg/                   # Public libraries
├── api/                   # API definitions (OpenAPI, proto)
├── configs/               # Configuration files
├── scripts/               # Build/deploy scripts
├── go.mod
└── go.sum
```

## Naming Conventions

### Packages
- Short, lowercase, no underscores
- Singular nouns preferred
- Avoid generic names (`util`, `common`, `helper`)

```go
package user      // ✓
package userutils // ✗
package user_service // ✗
```

### Variables & Functions
- MixedCaps (not snake_case)
- Short names for short scopes
- Descriptive names for exported items

```go
// Local variables
for i := 0; i < len(items); i++ {}
for _, v := range values {}

// Package-level
var defaultTimeout = 30 * time.Second

// Exported
func NewUserService(repo Repository) *UserService {}
```

### Interfaces
- End with `-er` for single-method interfaces
- Describe behavior, not implementation

```go
type Reader interface { Read(p []byte) (n int, err error) }
type UserRepository interface { /* ... */ }
```

## Error Handling

### Always Check Errors
```go
result, err := doSomething()
if err != nil {
    return fmt.Errorf("failed to do something: %w", err)
}
```

### Error Wrapping
```go
// Add context with %w
if err != nil {
    return fmt.Errorf("creating user %s: %w", userID, err)
}

// Check wrapped errors
if errors.Is(err, ErrNotFound) {}
var targetErr *ValidationError
if errors.As(err, &targetErr) {}
```

### Custom Errors
```go
var (
    ErrNotFound = errors.New("not found")
    ErrInvalidInput = errors.New("invalid input")
)

type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("%s: %s", e.Field, e.Message)
}
```

## Context Usage

### Always First Parameter
```go
func ProcessOrder(ctx context.Context, orderID string) error {
    // Use context for cancellation and values
}
```

### Propagate Context
```go
func (s *Service) Create(ctx context.Context, input Input) error {
    // Pass to all downstream calls
    user, err := s.repo.FindByID(ctx, input.UserID)
    if err != nil {
        return err
    }
    return s.publisher.Publish(ctx, event)
}
```

## Concurrency Patterns

### Goroutines with WaitGroup
```go
var wg sync.WaitGroup
for _, item := range items {
    wg.Add(1)
    go func(item Item) {
        defer wg.Done()
        process(item)
    }(item)
}
wg.Wait()
```

### Channels for Communication
```go
results := make(chan Result, len(items))
for _, item := range items {
    go func(item Item) {
        results <- process(item)
    }(item)
}

for i := 0; i < len(items); i++ {
    result := <-results
    // handle result
}
```

### Error Group
```go
g, ctx := errgroup.WithContext(ctx)
for _, item := range items {
    item := item // capture
    g.Go(func() error {
        return process(ctx, item)
    })
}
if err := g.Wait(); err != nil {
    return err
}
```

## Testing

### Table-Driven Tests
```go
func TestCalculate(t *testing.T) {
    tests := []struct {
        name    string
        input   int
        want    int
        wantErr bool
    }{
        {"positive", 5, 10, false},
        {"zero", 0, 0, false},
        {"negative", -1, 0, true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := Calculate(tt.input)
            if (err != nil) != tt.wantErr {
                t.Errorf("error = %v, wantErr %v", err, tt.wantErr)
                return
            }
            if got != tt.want {
                t.Errorf("got %v, want %v", got, tt.want)
            }
        })
    }
}
```

### Test Helpers
```go
func setupTest(t *testing.T) (*Service, func()) {
    t.Helper()
    // setup
    return service, func() {
        // cleanup
    }
}
```

## Common Patterns

### Constructor Functions
```go
func NewService(repo Repository, opts ...Option) *Service {
    s := &Service{
        repo:    repo,
        timeout: defaultTimeout,
    }
    for _, opt := range opts {
        opt(s)
    }
    return s
}
```

### Functional Options
```go
type Option func(*Service)

func WithTimeout(d time.Duration) Option {
    return func(s *Service) {
        s.timeout = d
    }
}
```

### Repository Interface
```go
type UserRepository interface {
    Create(ctx context.Context, user *User) error
    FindByID(ctx context.Context, id string) (*User, error)
    Update(ctx context.Context, user *User) error
    Delete(ctx context.Context, id string) error
}
```

## Tools

```bash
# Format
gofmt -w .
goimports -w .

# Lint
golangci-lint run

# Test
go test ./... -v -cover

# Build
go build -o bin/app ./cmd/api
```

## Dependencies

```bash
# Add dependency
go get github.com/package/name@latest

# Update
go get -u ./...

# Tidy
go mod tidy
```
