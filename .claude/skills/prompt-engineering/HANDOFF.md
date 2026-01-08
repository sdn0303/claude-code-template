# Agent Handoff Templates

Standardized templates for transitioning work between agents.

## @plan → @edit

```xml
<handoff>
<from>plan</from>
<to>edit</to>
<status>success</status>
<summary>
Implementation plan created for [feature]. [N] tasks identified.
</summary>
<artifacts>
- Implementation plan (recorded in TodoWrite)
</artifacts>
<context_for_next>
## Implementation Tasks

### Task 1: [Task Name]
- **Files**: [file paths]
- **Changes**: [specific changes]
- **Notes**: [important considerations]

### Task 2: [Task Name]
...

## Architecture Notes
- [Pattern to follow]
- [Dependencies to consider]
</context_for_next>
<action_required>
Implement tasks sequentially. Verify build after each task.
</action_required>
</handoff>
```

## @edit → @test

```xml
<handoff>
<from>edit</from>
<to>test</to>
<status>success</status>
<summary>
Implemented [feature]. [N] files changed/created.
</summary>
<artifacts>
- [file1.go] (new)
- [file2.go] (modified)
</artifacts>
<context_for_next>
## Changes Made
- [Description of change 1]
- [Description of change 2]

## Test Focus Areas
- [Scenario requiring tests]
- [Edge case to verify]

## Build Status
- Build: ✓ Passing
</context_for_next>
<action_required>
1. Run existing tests
2. Add tests for new functionality
3. Verify coverage
</action_required>
</handoff>
```

## @test → @review (Success)

```xml
<handoff>
<from>test</from>
<to>review</to>
<status>success</status>
<summary>
All [N] tests passing. Coverage: [X]%.
</summary>
<artifacts>
- coverage.out
- test_results.log
</artifacts>
<context_for_next>
## Test Results
- Total: [N] tests
- Passed: [N]
- Coverage: [X]%

## Files to Review
- [file1]: [change summary]
- [file2]: [change summary]
</context_for_next>
<action_required>
Review code quality and architecture compliance.
</action_required>
</handoff>
```

## @test → @edit (Failure)

```xml
<handoff>
<from>test</from>
<to>edit</to>
<status>needs_revision</status>
<summary>
[N] test failures requiring fixes.
</summary>
<artifacts>
- test_output.log
</artifacts>
<context_for_next>
## Failing Tests

### Test: [TestName]
- **File**: [path:line]
- **Error**: [error message]
- **Analysis**: [probable cause]

### Test: [TestName]
...
</context_for_next>
<action_required>
Fix failing tests. Re-run @test after fixes.
</action_required>
</handoff>
```

## @review → @commit (Approved)

```xml
<handoff>
<from>review</from>
<to>commit</to>
<status>success</status>
<summary>
Review passed. No critical issues.
</summary>
<artifacts>
- review_report.md
</artifacts>
<context_for_next>
## Change Summary
[Description of the overall change]

## Commit Details
- **Type**: feat | fix | refactor
- **Scope**: [component]
- **Breaking**: No

## Files Changed
- [file1]: [summary]
- [file2]: [summary]
</context_for_next>
<action_required>
Create Conventional Commit with appropriate type and scope.
</action_required>
</handoff>
```

## @review → @edit (Changes Requested)

```xml
<handoff>
<from>review</from>
<to>edit</to>
<status>needs_revision</status>
<summary>
[N] issues require attention before approval.
</summary>
<artifacts>
- review_report.md
</artifacts>
<context_for_next>
## Required Changes

### Issue 1: [Title] (HIGH)
- **File**: [path]
- **Problem**: [description]
- **Fix**: [specific action]

### Issue 2: [Title] (MEDIUM)
...
</context_for_next>
<action_required>
Address review feedback. Re-submit for review.
</action_required>
</handoff>
```

## @commit → User

```xml
<handoff>
<from>commit</from>
<to>user</to>
<status>success</status>
<summary>
Changes committed: [commit message]
</summary>
<artifacts>
- Commit: [hash]
</artifacts>
<context_for_next>
## Commit Details
- **Hash**: [short hash]
- **Branch**: [branch name]
- **Files**: [N] changed

## Next Steps
- Push: `git push origin [branch]`
- PR: Create pull request if ready
</context_for_next>
<action_required>
Push changes when ready for remote.
</action_required>
</handoff>
```
