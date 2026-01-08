# /fix Command

Fixes bugs, errors, or issues in the codebase.

## Usage

```
/fix <issue-description>
/fix <error-message>
/fix #<issue-number>
```

## Examples

```
/fix null pointer exception in user service
/fix "cannot read property 'id' of undefined"
/fix #123
```

## Workflow

1. **Analyze**: Understand the issue from description or error
2. **Locate**: Find the source of the problem
3. **Diagnose**: Determine root cause
4. **Fix**: Implement the correction
5. **Verify**: Run tests to confirm fix
6. **Review**: Validate the fix doesn't break other things

## Process

### From Error Message

1. Parse error message and stack trace
2. Locate error origin in codebase
3. Analyze surrounding context
4. Identify root cause
5. Implement fix
6. Add regression test

### From Issue Number

1. Fetch issue details (if available)
2. Reproduce the issue
3. Debug and trace
4. Implement fix
5. Reference issue in commit

## Output Format

```markdown
## Fix Summary

### Issue
[Description of the problem]

### Root Cause
[What caused the issue]

### Solution
[How it was fixed]

### Files Changed
- [file1]: [change description]

### Regression Test
- [test name]: [what it verifies]

### Verification
- [ ] Tests pass
- [ ] No new warnings
- [ ] Issue resolved
```

## Options

| Option | Description |
|--------|-------------|
| `--no-test` | Skip regression test (not recommended) |
| `--verbose` | Show detailed debugging output |

## Commit Format

```
fix(<scope>): <brief description>

<detailed explanation>

Fixes #<issue-number>
```
