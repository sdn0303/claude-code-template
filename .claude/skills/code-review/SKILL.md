---
name: code-review
description: Code review best practices, checklist, and automated review patterns. Use when reviewing code changes or PRs.
---

# Code Review Skill

Systematic approach to code review for quality, security, and maintainability.

## Review Checklist

### 1. Correctness
- [ ] Logic implements requirements correctly
- [ ] Edge cases handled (null, empty, boundaries)
- [ ] Error handling is appropriate
- [ ] No off-by-one errors
- [ ] Concurrent access is safe

### 2. Security
- [ ] Input validation present
- [ ] No SQL/command injection vulnerabilities
- [ ] Sensitive data not logged or exposed
- [ ] Authentication/authorization checked
- [ ] No hardcoded secrets

### 3. Performance
- [ ] No N+1 queries
- [ ] Appropriate indexing considered
- [ ] No unnecessary allocations in hot paths
- [ ] Caching strategy appropriate
- [ ] Resource cleanup (connections, files)

### 4. Maintainability
- [ ] Code is readable and self-documenting
- [ ] Functions are focused (single responsibility)
- [ ] No excessive nesting (max 3 levels)
- [ ] DRY principle followed (no copy-paste)
- [ ] Dependencies are appropriate

### 5. Testing
- [ ] Tests cover happy path
- [ ] Tests cover error cases
- [ ] Tests are deterministic (no flakiness)
- [ ] Mocks are appropriate
- [ ] Test names describe behavior

## Review Workflow

```
1. Understand Context
   ├── Read PR description
   ├── Understand the "why"
   └── Check related issues/tickets

2. High-Level Review
   ├── Architecture alignment
   ├── Breaking changes
   └── API compatibility

3. Detailed Review
   ├── Logic correctness
   ├── Error handling
   ├── Security implications
   └── Performance impact

4. Code Quality
   ├── Readability
   ├── Naming clarity
   ├── Documentation
   └── Test coverage

5. Final Checks
   ├── CI passing
   ├── No merge conflicts
   └── Changelog updated
```

## Review Comments

### Comment Types
```
# Blocking (must fix)
🔴 BLOCKER: SQL injection vulnerability in user input handling

# Suggestion (should consider)
🟡 SUGGESTION: Consider extracting this into a separate function for reusability

# Nitpick (optional)
🟢 NIT: Variable name could be more descriptive

# Question (clarification)
❓ QUESTION: What happens if this returns nil?

# Praise (positive feedback)
👍 NICE: Clean implementation of the retry logic
```

### Comment Structure
```markdown
**Issue**: Brief description of the problem
**Why**: Explanation of why this matters
**Suggestion**: Specific recommendation
**Example**: (optional) Code example

---

**Issue**: Potential race condition in counter increment
**Why**: Multiple goroutines may read/write simultaneously
**Suggestion**: Use atomic operations or mutex
**Example**:
```go
// Before
counter++

// After
atomic.AddInt64(&counter, 1)
```
```

## Language-Specific Checks

### Go
- [ ] Error wrapping with context (`fmt.Errorf("%w", err)`)
- [ ] Context propagation in long operations
- [ ] Goroutine lifecycle management
- [ ] Defer for cleanup
- [ ] Interface satisfaction at compile time

### TypeScript/JavaScript
- [ ] Strict null checks handled
- [ ] Proper async/await error handling
- [ ] No any types without justification
- [ ] React hooks dependencies correct
- [ ] Memory leaks (event listeners, subscriptions)

### Python
- [ ] Type hints present
- [ ] Exception handling specific (not bare except)
- [ ] Resource management (context managers)
- [ ] No mutable default arguments
- [ ] Async code properly awaited

## Security Review

### OWASP Top 10 Checks
```
1. Injection
   - Parameterized queries
   - Input sanitization
   - Command escaping

2. Broken Authentication
   - Password hashing (bcrypt, argon2)
   - Session management
   - MFA considerations

3. Sensitive Data Exposure
   - Encryption at rest/transit
   - No secrets in code
   - PII handling

4. XXE
   - XML parser configuration
   - Entity expansion disabled

5. Broken Access Control
   - Authorization checks
   - Resource ownership validation
   - RBAC implementation

6. Security Misconfiguration
   - Debug mode disabled
   - Default credentials changed
   - CORS configuration

7. XSS
   - Output encoding
   - CSP headers
   - Sanitization libraries

8. Insecure Deserialization
   - Type validation
   - Signature verification
   - Allow-list approach

9. Known Vulnerabilities
   - Dependencies updated
   - CVE checks
   - Security advisories

10. Insufficient Logging
    - Security events logged
    - No sensitive data in logs
    - Log injection prevention
```

## Performance Review

### Database
```sql
-- Check for missing indexes
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';

-- Look for
-- ❌ Seq Scan on large tables
-- ❌ Nested Loop with high row estimates
-- ✓ Index Scan / Index Only Scan
```

### API Response Times
```
Target thresholds:
- P50: < 100ms
- P95: < 500ms
- P99: < 1000ms

Red flags:
- Multiple sequential external calls
- Large payload serialization
- Missing pagination
```

### Memory
```
Watch for:
- Unbounded slice growth
- Large object allocations in loops
- Unclosed resources
- Circular references (GC issues)
```

## Automated Review Integration

### Pre-Review Automation
```yaml
# .github/workflows/pr-checks.yml
on: [pull_request]
jobs:
  automated-review:
    steps:
      - uses: actions/checkout@v4
      - name: Lint
        run: make lint
      - name: Security Scan
        run: make security-scan
      - name: Test Coverage
        run: make test-coverage
      - name: Complexity Check
        run: make complexity-check
```

### Review Criteria
```
Auto-approve if:
- Only documentation changes
- Test-only changes
- Dependency updates (minor/patch)

Require senior review if:
- Database migrations
- Authentication/authorization changes
- API breaking changes
- Infrastructure modifications
```

## Review Metrics

### Health Indicators
```
Good:
- PR size: < 400 lines changed
- Review turnaround: < 24 hours
- Comments resolved: 100%
- Test coverage: > 80%

Warning:
- PR size: 400-800 lines
- Review turnaround: 24-48 hours
- Multiple review rounds: > 3

Critical:
- PR size: > 800 lines
- Review turnaround: > 48 hours
- Unresolved comments merged
```

## Constructive Feedback

### DO
- Be specific and actionable
- Explain the "why"
- Offer alternatives
- Acknowledge good work
- Ask questions instead of demands

### DON'T
- Be condescending
- Make it personal
- Nitpick excessively
- Block without explanation
- Ignore context
