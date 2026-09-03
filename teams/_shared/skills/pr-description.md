---
name: pr-description
description: >
  Generate pull request description from git diff or file changes.
  Follows team conventions for PR structure.
---

# PR Description Generator

When invoked, generate PR description from current changes (git diff or specified files).

## Process

1. Read git diff or changed files
2. Categorize changes (feature/fix/refactor/docs/infra)
3. Generate structured description

## Output Format

```markdown
## Summary

{1-2 sentence description of what this PR does}

## Changes

- {bullet list of logical changes, grouped by area}

## Type

- [ ] Feature
- [ ] Bug fix
- [ ] Refactor
- [ ] Documentation
- [ ] Infrastructure
- [ ] Configuration

## Testing

- {what was tested}
- {how to verify}

## Related

- Jira: {ticket-id if detectable}
- Depends on: {other PRs if any}

## Checklist

- [ ] Code follows project conventions
- [ ] Tests added/updated
- [ ] Documentation updated (if needed)
- [ ] No secrets committed
- [ ] Tags/naming follow governance standards
```

## Rules

- Keep summary under 2 sentences
- Group changes logically, not file-by-file
- Detect ticket IDs from branch name or commit messages
- Flag any governance concerns (missing tags, hardcoded values, security)
