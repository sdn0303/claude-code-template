---
name: prompt-engineering
description: Agent handoff protocols and structured output formats. Use when transitioning between agents or producing structured output for consumption by other agents.
---

# Prompt Engineering Skill

Standardized protocols for agent communication and structured output generation.

## Agent Handoff Protocol

When transitioning work between agents, use the following XML structure:

```xml
<handoff>
<from>[source-agent]</from>
<to>[target-agent]</to>
<status>success | needs_revision | blocked</status>
<summary>
[1-2 sentence summary of completed work]
</summary>
<artifacts>
- [Created/modified file 1]
- [Created/modified file 2]
</artifacts>
<context_for_next>
[Detailed information the next agent needs]
</context_for_next>
<action_required>
[Specific actions the next agent should take]
</action_required>
</handoff>
```

## Status Definitions

- **success**: Work completed, ready for next phase
- **needs_revision**: Issues found, returning for fixes
- **blocked**: Cannot proceed, requires external input

## Agent-Specific Templates

See [HANDOFF.md](HANDOFF.md) for detailed templates.

## Prompt Techniques

See [TECHNIQUES.md](TECHNIQUES.md) for advanced patterns.

## Examples

See [EXAMPLES.md](EXAMPLES.md) for concrete use cases.
