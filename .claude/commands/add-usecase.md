# /add-usecase Command

Adds a new use case following Clean Architecture patterns.

## Usage

```
/add-usecase <domain> <action> [options]
```

## Examples

```
/add-usecase user create
/add-usecase order process --with-events
/add-usecase product search --with-cache
```

## Generated Structure

### Go

```
internal/
├── domain/<domain>/
│   └── entity.go           # Domain entity (if new)
├── usecase/<domain>/
│   ├── <action>.go         # Use case implementation
│   ├── <action>_test.go    # Unit tests
│   └── interface.go        # Repository interface
└── adapter/
    ├── controller/<domain>_controller.go
    └── repository/<domain>_repository.go
```

### TypeScript

```
src/
├── domain/<domain>/
│   ├── entity.ts
│   └── repository.interface.ts
├── application/<domain>/
│   ├── <action>.usecase.ts
│   └── <action>.usecase.test.ts
└── infrastructure/<domain>/
    ├── <domain>.controller.ts
    └── <domain>.repository.ts
```

## Template Components

### Use Case Interface

```go
type <Action><Domain>UseCase interface {
    Execute(ctx context.Context, input <Action><Domain>Input) (<Action><Domain>Output, error)
}
```

### Input/Output DTOs

```go
type <Action><Domain>Input struct {
    // Input fields
}

type <Action><Domain>Output struct {
    // Output fields
}
```

### Repository Interface

```go
type <Domain>Repository interface {
    // CRUD methods
}
```

## Options

| Option | Description |
|--------|-------------|
| `--with-events` | Add domain events |
| `--with-cache` | Add caching layer |
| `--with-validation` | Add input validation |
| `--http` | Generate HTTP handler |
| `--grpc` | Generate gRPC handler |

## Workflow

1. Create domain entity (if needed)
2. Define repository interface
3. Implement use case
4. Generate unit tests
5. Create adapter layer
6. Wire up dependencies
7. Run tests

## Output

- New files created
- Dependency injection setup
- Test coverage report
- API endpoint (if applicable)
