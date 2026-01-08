# Claude Code Development Environment Template

A universal, production-ready Claude Code configuration template for backend and frontend development projects.

## Overview

This template provides a standardized Claude Code development environment with:

- **Agents**: Specialized subagents for different development phases
- **Commands**: Custom slash commands for common workflows
- **Hooks**: Pre/post execution scripts for quality enforcement
- **Rules**: Project-wide coding standards and guidelines
- **Skills**: Domain-specific knowledge and best practices

## Supported Technologies

### Languages
- Go (1.21+)
- TypeScript / JavaScript
- Python (3.11+)
- Rust
- SQL (PostgreSQL, MySQL)
- MongoDB Query Language
- Terraform (HCL)

### Architectures & Patterns
- Clean Architecture / Onion Architecture
- Domain-Driven Design (DDD)
- Serverless Architecture
- Microservices Architecture
- Feature-Sliced Design (Frontend)
- REST API Design

### Build Tools & Package Managers
- pnpm, Vite (TypeScript/JS)
- go mod (Go)
- uv (Python)
- cargo (Rust)

### Databases
- PostgreSQL
- MySQL
- MongoDB

### Deployment
- Firebase
- Cloud Build (GCP)
- Docker

## Directory Structure

```
.claude/
├── README.md
├── settings.json
├── settings.local.json
├── agents/
├── commands/
├── hooks/
├── rules/
└── skills/
```

## Quick Start

1. Copy this `.claude` directory to your project root
2. Customize `settings.json` for your project
3. Create `settings.local.json` for personal preferences
4. Modify rules and skills based on project requirements

## Install

```bash
curl -fsSL https://github.com/sdn0303/claude-code-template/archive/main.tar.gz \
  | tar -xz --strip-components=1 claude-code-template-main/.claude
```

### Makefile (option)

```makefile
CLAUDE_TEMPLATE_REPO := sdn0303/claude-code-template

.PHONY: claude-init claude-update

claude-init:
	@if [ -d .claude ]; then \
		echo "Error: .claude already exists"; exit 1; \
	fi
	curl -fsSL https://github.com/$(CLAUDE_TEMPLATE_REPO)/archive/main.tar.gz \
		| tar -xz --strip-components=1 claude-code-template-main/.claude
	chmod +x .claude/hooks/*.sh
	@echo "Claude Code template installed. Edit .claude/settings.json"

claude-update:
	@echo "Backing up settings..."
	cp .claude/settings.json .claude/settings.json.bak 2>/dev/null || true
	cp .claude/settings.local.json .claude/settings.local.json.bak 2>/dev/null || true
	rm -rf .claude
	$(MAKE) claude-init
	mv .claude/settings.json.bak .claude/settings.json 2>/dev/null || true
	mv .claude/settings.local.json.bak .claude/settings.local.json 2>/dev/null || true
	@echo "Updated. Review changes in settings if needed."
```

## Agent Workflow

```text
@plan → @edit → @test → @review → @commit
```

## License

MIT License
