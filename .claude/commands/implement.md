# /implement Command

Implements a feature or requirement using the full agent workflow.

## Usage

```
/implement <description>
```

## Examples

```
/implement user authentication with JWT
/implement CRUD endpoints for products
/implement file upload to S3
```

## Workflow

This command orchestrates the following agents in sequence:

1. **@plan**: Analyze requirements and create implementation plan
2. **@edit**: Implement the code changes
3. **@test**: Generate and run tests
4. **@review**: Review code quality
5. **@commit**: Create conventional commit

## Process

1. Parse the implementation request
2. Invoke @plan to create detailed tasks
3. For each task:
   - @edit implements the change
   - @test verifies the implementation
4. @review validates the complete change
5. @commit creates the final commit

## Options

| Option | Description |
|--------|-------------|
| `--skip-tests` | Skip test generation (not recommended) |
| `--dry-run` | Plan only, no implementation |
| `--scope <path>` | Limit changes to specific path |

## Output

- Implementation plan
- Changed files
- Test results
- Review summary
- Commit hash
