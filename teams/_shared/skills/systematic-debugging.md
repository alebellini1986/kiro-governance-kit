---
inclusion: manual
---

# Systematic Debugging

Use when you encounter bugs, test failures, or unexpected behavior — BEFORE proposing a fix.

## Principle

**NO FIX WITHOUT ROOT CAUSE.** Fixing symptoms = failure.

## When to Use

- Test failure, bug, unexpected behavior
- Performance problems, build failures
- Especially when "it seems obvious" or you're under pressure

## The 4 Phases

### Phase 1: Root Cause Investigation

BEFORE any fix:

1. **Read error messages** — full stack trace, line numbers, error codes
2. **Reproduce** — exact steps, every time? If not reproducible → more data, don't guess
3. **Check recent changes** — git diff, new dependencies, config changes
4. **Gather evidence** — for multi-component systems, add diagnostic logging at every boundary
5. **Trace data flow** — where does the wrong value originate? Trace back to the source

### Phase 2: Pattern Analysis

1. Find similar working examples in the codebase
2. Compare with reference implementation (read ALL of it, don't skim)
3. Identify differences — even those "that can't matter"
4. Understand dependencies and assumptions

### Phase 3: Hypothesis & Testing

1. **Form single hypothesis** — "I think X is the cause because Y"
2. **Minimal test** — the SMALLEST possible change, one variable at a time
3. **Verify** — works? → Phase 4. Doesn't work? → NEW hypothesis (don't stack fixes on top)

### Phase 4: Implementation

1. **Create failing test case** — automated reproduction
2. **Implement single fix** — root cause, ONE change at a time
3. **Verify** — test passes? No other tests broken?
4. **If 3+ fixes failed** → STOP. Architectural problem. Discuss before continuing.

## Red Flags — STOP and return to Phase 1

- "Quick fix for now, I'll investigate later"
- "I'll try changing X and see"
- "I'll add more changes and run the tests"
- "It's probably X, I'll fix that"
- Proposing solutions before tracing the data flow
- Every fix reveals a new problem in a different place

## Impact

- Systematic approach: 15-30 min per fix
- Random fixes: 2-3 hours of thrashing
- First-time fix rate: 95% vs 40%

Adapted from [obra/superpowers](https://github.com/obra/superpowers) — MIT License.
