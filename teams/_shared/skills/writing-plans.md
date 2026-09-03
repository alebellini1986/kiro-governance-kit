---
inclusion: manual
---

# Writing Plans

Use when you have requirements for a multi-step task, BEFORE touching code. Generates a detailed implementation plan with bite-sized tasks.

## Principle

Write plans assuming the engineer has zero context. Document everything: files to touch, code, tests, how to verify. Small tasks. DRY. YAGNI. TDD. Frequent commits.

## When to Use

- Medium-large new feature
- Structural refactoring
- Migration or upgrade
- Any work touching 3+ files

## Process

1. **Scope check** — if it covers multiple independent subsystems, split into separate plans
2. **File structure** — map files created/modified with clear responsibilities
3. **Task decomposition** — each task produces self-contained and testable changes
4. **Bite-sized steps** — each step is one action (2-5 min): write test → run → implement → run → commit

## Task Format

```markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py`
- Test: `tests/exact/path/to/test.py`

- [ ] Step 1: Write failing test
- [ ] Step 2: Run test (verify FAIL)
- [ ] Step 3: Implement minimal code
- [ ] Step 4: Run test (verify PASS)
- [ ] Step 5: Commit
```

## Rules

- **Exact paths** always
- **Complete code** in every step — if a step changes code, show the code
- **Exact commands** with expected output
- **No placeholders** — never "TBD", "TODO", "implement later", "similar to Task N"
- **Self-review** after writing: spec coverage, placeholder scan, type consistency

## After the Plan

Offer execution choice:
1. **Kiro spec workflow** — use Kiro's spec system (requirements → design → tasks)
2. **Inline execution** — execute task by task in the current session

Adapted from [obra/superpowers](https://github.com/obra/superpowers) — MIT License.
