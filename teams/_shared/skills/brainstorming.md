---
inclusion: manual
---

# Brainstorming

Use BEFORE any creative work — features, components, behavioral changes. Explore intent, requirements, and design before implementation.

## Hard Gate

**DO NOT implement, write code, or scaffold ANYTHING until you have presented a design and the user has approved it.** Even for "simple" projects.

## Checklist

1. **Explore project context** — files, docs, recent commits
2. **Clarifying questions** — one at a time, understand purpose/constraints/success criteria
3. **Propose 2-3 approaches** — with trade-offs and recommendation
4. **Present design** — sections scaled to complexity, approval after each section
5. **Write design doc** — save and commit
6. **Self-review spec** — placeholders, contradictions, ambiguities, scope
7. **User review** — wait for approval before proceeding
8. **Transition to implementation** — invoke writing-plans or Kiro spec workflow

## Principles

- **One question at a time** — don't overload
- **Multiple choice preferred** — easier to answer
- **YAGNI** — remove unnecessary features
- **Explore alternatives** — always 2-3 approaches before deciding
- **Incremental validation** — present, get ok, then move forward
- **Design for isolation** — small units, clear interfaces, independently testable

## In existing codebases

- Explore current structure before proposing changes
- Follow existing patterns
- If existing code has issues that impact the work, include targeted improvements in the design
- Don't propose unrelated refactoring

Adapted from [obra/superpowers](https://github.com/obra/superpowers) — MIT License.
