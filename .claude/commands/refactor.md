# /refactor Command

Refactors code while preserving behavior.

## Usage

```
/refactor <target> [strategy]
```

## Examples

```
/refactor internal/user/service.go extract-method
/refactor src/components/Dashboard simplify
/refactor internal/repository consolidate
```

## Refactoring Strategies

### extract-method
Extract repeated code into a new function.

### extract-interface
Create interface from concrete implementation.

### rename
Rename symbols with all references.

### move
Move code to appropriate location.

### simplify
Reduce complexity and improve readability.

### consolidate
Merge duplicate implementations.

### decompose
Break down large functions/classes.

## Safety Checklist

Before refactoring:
- [ ] All tests pass
- [ ] Understand current behavior
- [ ] Identify all callers/dependencies

After refactoring:
- [ ] All tests still pass
- [ ] No behavior changes
- [ ] Code is cleaner/simpler

## Process

1. **Analyze**: Understand current code structure
2. **Plan**: Identify refactoring steps
3. **Test**: Ensure current tests pass
4. **Refactor**: Make incremental changes
5. **Verify**: Run tests after each change
6. **Review**: Validate improvements

## Output Format

```markdown
## Refactoring Summary

### Target
[File/Component being refactored]

### Strategy
[Refactoring strategy applied]

### Changes

#### Step 1: [Description]
- Before: [code snippet]
- After: [code snippet]
- Reason: [why this change]

#### Step 2: [Description]
...

### Metrics
- Lines before: N
- Lines after: N
- Complexity before: X
- Complexity after: X

### Verification
- [ ] Tests pass
- [ ] No behavior change
- [ ] Improved readability
```

## Options

| Option | Description |
|--------|-------------|
| `--dry-run` | Show plan without executing |
| `--step-by-step` | Pause after each change |
| `--preserve-tests` | Don't modify test files |

## Commit Format

```
refactor(<scope>): <brief description>

- [Change 1]
- [Change 2]

No behavior changes.
```

## Constraints

- DO NOT change external behavior
- DO NOT skip test verification
- Make atomic, reversible changes
- Document reasoning for changes
