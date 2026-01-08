# Documentation Standards

Rules for writing consistent, maintainable documentation.

## Markdown Formatting

### Headings
- Use ATX-style headings (`#`)
- Include blank line before and after headings
- Don't skip heading levels

```markdown
# Title (H1 - one per document)

## Section (H2)

### Subsection (H3)

#### Details (H4)
```

### Lists
- Use `-` for unordered lists
- Use `1.` for ordered lists (auto-numbered)
- Include blank line before lists

```markdown
Unordered:

- Item one
- Item two
  - Nested item

Ordered:

1. First step
2. Second step
3. Third step
```

### Code Blocks
- Use fenced code blocks with language identifier
- Include blank lines before and after

````markdown
```go
func main() {
    fmt.Println("Hello")
}
```
````

### Inline Elements
```markdown
**bold** for emphasis
`code` for inline code
[link text](url) for links
```

## Document Structure

### README.md Template

```markdown
# Project Name

Brief description of the project.

## Overview

What this project does and why it exists.

## Prerequisites

- Requirement 1
- Requirement 2

## Installation

```bash
# Installation commands
```

## Usage

```bash
# Usage examples
```

## Configuration

Description of configuration options.

## Development

### Setup

Development setup instructions.

### Testing

```bash
# Test commands
```

## Contributing

Contribution guidelines.

## License

License information.
```

### API Documentation Template

```markdown
# API Name

## Overview

Brief description of the API.

## Authentication

How to authenticate.

## Endpoints

### Resource Name

#### List Resources

```
GET /resources
```

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| page | int | No | Page number |

**Response:**

```json
{
  "data": []
}
```

## Error Codes

| Code | Description |
|------|-------------|
| 400 | Bad request |
```

### Architecture Decision Record (ADR)

```markdown
# ADR-001: Title

## Status

Proposed | Accepted | Deprecated | Superseded

## Context

What is the issue we're addressing?

## Decision

What is the change we're proposing?

## Alternatives Considered

### Option A
- Pros
- Cons

### Option B
- Pros
- Cons

## Consequences

- Positive outcomes
- Negative outcomes
- Risks
```

## Writing Style

### Principles
- Be concise and clear
- Use active voice
- Write for your audience
- Include examples

### Technical Writing
- Define acronyms on first use
- Use consistent terminology
- Explain the "why" not just "what"
- Update docs with code changes

### Tone
- Professional but approachable
- Helpful and instructive
- Neutral and inclusive

## Code Examples

### Guidelines
- Keep examples minimal but complete
- Use realistic, meaningful values
- Show both input and output
- Include error handling when relevant

```go
// Example: Creating a user
user := &User{
    Name:  "John Doe",
    Email: "john@example.com",
}

err := userService.Create(ctx, user)
if err != nil {
    log.Error("failed to create user", "error", err)
    return err
}
```

## Tables

### Formatting
- Align columns for readability
- Use header row
- Keep content concise

```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data 1   | Data 2   | Data 3   |
| Data 4   | Data 5   | Data 6   |
```

## Links

### Internal Links
```markdown
See [Configuration](./docs/configuration.md)
See [API Design](#api-design)
```

### External Links
```markdown
[Official Documentation](https://example.com/docs)
```

## Images

### Guidelines
- Use descriptive alt text
- Keep images in `docs/images/`
- Use relative paths

```markdown
![Architecture Diagram](./docs/images/architecture.png)
```

## File Organization

```
docs/
├── README.md           # Overview
├── getting-started.md  # Quick start guide
├── configuration.md    # Configuration reference
├── api/               # API documentation
│   ├── overview.md
│   └── endpoints.md
├── architecture/      # Architecture docs
│   ├── overview.md
│   └── adr/          # Decision records
└── images/           # Diagrams and images
```
