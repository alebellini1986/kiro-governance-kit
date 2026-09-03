---
inclusion: manual
---

# Verification Before Completion

Use BEFORE claiming work is completed, fixed, or passing. Evidence before assertions.

## Principle

**NO CLAIM WITHOUT FRESH VERIFICATION.** If you haven't run the command in this message, you can't say it passes.

## Gate Function

```
BEFORE any success claim:
1. IDENTIFY: which command proves this claim?
2. EXECUTE: run the COMPLETE command (fresh)
3. READ: full output, exit code, count failures
4. VERIFY: does the output confirm the claim?
   - NO → declare actual state with evidence
   - YES → declare claim WITH evidence
5. ONLY THEN: make the claim
```

## What Requires What

| Claim | Requires | NOT sufficient |
|-------|----------|----------------|
| Tests pass | Test output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check |
| Build ok | Build command: exit 0 | Linter passing |
| Bug fixed | Original symptom test: passes | "Code changed, should be ok" |
| Requirements met | Line-by-line checklist | "Tests pass" |

## Red Flags — STOP

- Using "should", "probably", "seems"
- Expressing satisfaction before verification ("Done!", "Perfect!")
- Commit/push/PR without verification
- Trusting success reports without independent check
- "Just this once"

## Correct Patterns

```
✅ [Run test] [See: 34/34 pass] "All tests pass"
❌ "Should pass now"

✅ [Run build] [See: exit 0] "Build ok"
❌ "Linter passes" (linter ≠ compilation)

✅ Re-read plan → Checklist → Verify each point → Report
❌ "Tests pass, phase complete"
```

## Bottom Line

Run the command. Read the output. THEN declare the result. Non-negotiable.

Adapted from [obra/superpowers](https://github.com/obra/superpowers) — MIT License.
