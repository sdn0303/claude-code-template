# General Coding Standards

These rules apply to all code in this project regardless of language.

## Code Quality Principles

### Readability First
- Code is read more often than written
- Use descriptive names over comments
- Keep functions short and focused
- Avoid clever tricks that sacrifice clarity

### Single Responsibility
- Each function/method does one thing
- Each file has a clear purpose
- Each module has defined boundaries

### Explicit Over Implicit
- Prefer explicit error handling
- Avoid magic numbers and strings
- Document non-obvious decisions

## Naming Conventions

### General Rules
- Names should reveal intent
- Avoid abbreviations unless universally known
- Be consistent within the codebase

### Specific Patterns
```
# Variables: what it contains
userCount, orderTotal, isActive

# Functions: what it does
calculateTotal(), fetchUser(), validateInput()

# Booleans: is/has/can/should prefix
isValid, hasPermission, canEdit, shouldRetry

# Constants: UPPER_SNAKE_CASE
MAX_RETRY_COUNT, DEFAULT_TIMEOUT
```

## Error Handling

### Principles
1. Handle errors at the appropriate level
2. Don't swallow errors silently
3. Provide context in error messages
4. Use structured errors when possible

### Anti-patterns to Avoid
```go
// Bad: Silent error
result, _ := doSomething()

// Good: Explicit handling
result, err := doSomething()
if err != nil {
    return fmt.Errorf("failed to do something: %w", err)
}
```

## Comments

### When to Comment
- Complex algorithms or business logic
- Non-obvious "why" decisions
- Public API documentation
- TODO/FIXME with ticket references

### When NOT to Comment
- Explaining "what" the code does (code should be self-documenting)
- Commented-out code (use version control)
- Obvious statements

## File Organization

### File Length
- Target: < 300 lines
- Warning: > 500 lines
- Must refactor: > 1000 lines

### Function Length
- Target: < 30 lines
- Warning: > 50 lines
- Must refactor: > 100 lines

## Dependencies

### Principles
- Minimize external dependencies
- Pin dependency versions
- Audit security regularly
- Prefer well-maintained packages

### Adding New Dependencies
1. Check if existing dependency can serve the need
2. Evaluate maintenance status and security
3. Consider bundle size impact
4. Document the reason for addition

## Testing Requirements

### Coverage Targets
- Minimum: 70%
- Target: 80%
- Critical paths: 90%+

### Test Types Required
- Unit tests for all business logic
- Integration tests for external interfaces
- E2E tests for critical user flows

## Git Practices

### Commit Messages
- Use Conventional Commits format
- Reference issue numbers when applicable
- Keep subject line < 50 characters

### Branch Naming
```
feature/<issue-id>-<short-description>
fix/<issue-id>-<short-description>
refactor/<short-description>
docs/<short-description>
```

## Security Requirements

### Secrets Management
- Never commit secrets to repository
- Use environment variables or secret managers
- Rotate credentials regularly

### Input Validation
- Validate all external input
- Sanitize data before storage
- Use parameterized queries

### Authentication/Authorization
- Use established auth libraries
- Implement proper session management
- Apply principle of least privilege
