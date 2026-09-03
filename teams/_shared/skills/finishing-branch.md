---
inclusion: manual
---

# Finishing Branch

Use when implementation is complete and all tests pass. Guides work completion with structured options.

## Process

### Step 1: Verify Tests

```bash
# Run the project's test suite
npm test / pytest / go test ./...
```

If tests fail → STOP. Fix before proceeding.

### Step 2: Present Options

```
Implementation complete. What do you want to do?

1. Merge back to main locally
2. Push and create Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work
```

### Step 3: Execute Choice

**Merge locally:**
- Checkout base branch, pull, merge feature
- Verify tests on merged result
- Cleanup branch

**Create PR:**
- Push branch with -u
- Create PR with summary + test plan
- Do NOT cleanup (needed for iterating on feedback)

**Keep as-is:**
- Report state and path
- No cleanup

**Discard:**
- Explicit confirmation required ("type 'discard'")
- Only after confirmation: delete branch and worktree

## Red Flags

- Never proceed with failing tests
- Never merge without verifying tests on the result
- Never delete work without confirmation
- Never force-push without explicit request

Adapted from [obra/superpowers](https://github.com/obra/superpowers) — MIT License.
