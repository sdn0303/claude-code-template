# Prompt Engineering Techniques

Advanced patterns for effective AI-assisted development.

## 1. Context Engineering

### Context Quality Principles

1. **Relevance**: Include only necessary information
2. **Specificity**: Be precise and unambiguous
3. **Structure**: Organize logically
4. **Completeness**: Provide sufficient detail

### Context Template

```xml
<context>
<project>
Name: [project-name]
Stack: [languages, frameworks]
Architecture: [pattern]
</project>

<current_task>
Target: [file or component]
Goal: [objective]
Constraints: [limitations]
</current_task>

<relevant_code>
[Include only directly relevant code]
</relevant_code>
</context>
```

## 2. Instruction Design

### SMART Instructions

- **S**pecific: Clear and unambiguous
- **M**easurable: Verifiable outcomes
- **A**chievable: Within capabilities
- **R**elevant: Directly applicable
- **T**ime-bound: Clear scope

### Instruction Patterns

**Sequential Steps:**

```xml
<instructions>
Execute in order:

1. [Step 1] - [expected outcome]
2. [Step 2] - [expected outcome]
3. [Step 3] - [expected outcome]

Verify each step before proceeding.
</instructions>
```

**Conditional Logic:**

```xml
<instructions>
Analyze input and apply:

- If [condition A]: [action A]
- If [condition B]: [action B]
- Otherwise: [default action]
</instructions>
```

## 3. Few-Shot Examples

### Example Selection

1. **Diversity**: Cover different scenarios
2. **Progression**: Simple → Complex
3. **Edge Cases**: Include boundaries
4. **Realism**: Match actual use cases

### Example Format

```xml
<examples>
<example id="1">
<description>Basic case</description>
<input>[input data]</input>
<output>[expected output]</output>
</example>

<example id="2">
<description>Complex case</description>
<input>[complex input]</input>
<thinking>
1. Analyze [aspect]
2. Consider [factor]
3. Apply [rule]
</thinking>
<output>[expected output]</output>
</example>

<example id="3">
<description>Edge case</description>
<input>[edge input]</input>
<output>[edge output]</output>
<note>Special handling for [reason]</note>
</example>
</examples>
```

## 4. Chain of Thought

### Basic CoT

```
Problem: [statement]

Think through this step by step.
```

### Structured CoT

```xml
<problem>[problem statement]</problem>

<thinking_process>
## 1. Problem Decomposition
- Sub-problem 1: ...
- Sub-problem 2: ...

## 2. Analysis
[Analysis of each sub-problem]

## 3. Synthesis
[Combine solutions]

## 4. Verification
[Validate solution]
</thinking_process>

<solution>
[Final answer]
</solution>
```

## 5. Output Control

### Format Specification

```xml
<output_format>
## Required Sections
1. Summary (2-3 sentences)
2. Details (bullet points)
3. Recommendations (numbered list)

## Formatting Rules
- Markdown headings
- Code in fenced blocks
- Key points in **bold**
</output_format>
```

### JSON Schema

```xml
<output_format>
Respond with JSON matching this schema:

{
  "analysis": {
    "summary": "string (<100 chars)",
    "findings": ["string"],
    "severity": "high|medium|low"
  },
  "recommendations": [
    {
      "title": "string",
      "description": "string",
      "priority": 1-5
    }
  ]
}
</output_format>
```

## 6. Role Design

### Expert Role

```markdown
Act as a [domain] expert with:

## Background
- [Years] experience
- [Qualifications]
- [Specialization]

## Communication Style
- Use technical terms with explanations
- Lead with conclusions
- Acknowledge uncertainty

## Priorities
1. Accuracy
2. Practicality
3. Clarity
```

## 7. Error Recovery

### Validation Pattern

```xml
<validation>
Before processing, verify:

1. Required fields present
2. Data format valid
3. Values within range

If issues found:
- Stop processing
- Report specific errors
- Suggest corrections
</validation>
```

### Fallback Behavior

```xml
<fallback>
When uncertain:

- Missing info: Ask for clarification
- Low confidence: Present alternatives
- Cannot process: Explain limitation
</fallback>
```

## 8. Iterative Refinement

### Self-Critique Pattern

```xml
<process>
1. Generate initial response
2. Self-evaluate:
   - Accuracy: Is information correct?
   - Completeness: All aspects covered?
   - Clarity: Easy to understand?
3. Revise if needed
4. Output final response
</process>
```

## 9. Domain Patterns

### Code Review

```xml
<review_context>
Target: [file/component]
Language: [language]
Purpose: [code purpose]
</review_context>

<review_criteria>
1. Correctness: Logic validity
2. Readability: Code clarity
3. Maintainability: Change ease
4. Performance: Efficiency
5. Security: Vulnerabilities
</review_criteria>

<output_format>
## Positive Observations
- ...

## Issues
1. [SEVERITY] Title
   - Problem: ...
   - Recommendation: ...
   - Location: ...
</output_format>
```

### Documentation

```xml
<doc_context>
Target: [component/API]
Audience: [reader type]
Purpose: [use case]
</doc_context>

<structure>
1. Overview
2. Prerequisites
3. Basic Usage
4. API Reference
5. Examples
6. Troubleshooting
</structure>
```

## 10. Performance Tips

### Token Efficiency

- Remove redundant explanations
- Include only relevant context
- Use concise examples
- Avoid repetition

### Response Optimization

```xml
<early_exit>
If conditions met:
- [Condition] → [Short response]

Otherwise: Full processing
</early_exit>
```
