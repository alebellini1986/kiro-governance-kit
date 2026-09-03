---
inclusion: manual
---

# Executing Plans

Use when you have a written implementation plan to execute step-by-step with review checkpoints.

## Process

### Step 1: Load and Review

1. Read the plan
2. Critical review — identify questions or concerns
3. If concerns: raise before starting
4. If ok: proceed

### Step 2: Execute Tasks

For each task:
1. Follow every step exactly (the plan has bite-sized steps)
2. Run verifications as specified
3. Mark as completed

### Step 3: Complete

After all tasks completed and verified:
- Verify full test suite
- Present options: merge, PR, keep branch
- Execute choice

## When to Stop

**STOP immediately when:**
- Blocker (missing dependency, test fail, unclear instruction)
- Plan has critical gaps
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## Rules

- Review plan critically first
- Follow steps exactly
- Don't skip verifications
- Stop when blocked, don't guess
- Never start implementation on main without explicit consent

Adapted from [obra/superpowers](https://github.com/obra/superpowers) — MIT License.
