# Contributing — Kiro Governance Kit

Guide for contributing to the Kiro governance repository.

## Principles

1. **Core is shared** — Changes to `steering/`, `skills/`, `hooks/` (root) impact EVERYONE. They require review.
2. **Teams are autonomous** — Each team manages their own folder in `teams/`. The owner approves PRs.
3. **Don't break others** — Team-specific rules must not contradict the core.
4. **Document** — Every file must have a clear purpose. If it's not obvious, add comments.

## Contribution Structure

### Contributing to Core (requires team review)

```bash
# Change to shared steering/skills/hooks
git checkout -b feat/core-new-steering
# ... make changes ...
git push -u origin feat/core-new-steering
# Create PR → request review from team lead
```

**When to contribute to core**:
- Security rule that applies to everyone
- Skill useful across teams
- Hook that every project should have
- Fix to existing rules

### Contributing to Your Own Team (owner approves)

```bash
# Change to your team's folder
git checkout -b feat/team-a-new-skill
# ... make changes in teams/team-a/ ...
git push -u origin feat/team-a-new-skill
# Create PR → team owner approves
```

**When to contribute to team**:
- Domain-specific steering
- Skill only your team uses
- Hook for context-specific tools
- Documentation of recurring patterns

## File Format

### Steering (.md)

```markdown
---
inclusion: auto|fileMatch|manual
fileMatchPattern: "pattern" # only for fileMatch
---

# Title

## Rules
- Rule 1
- Rule 2

## Customization Points
<!-- Section for team-specific extensions -->
```

### Skills (.md)

```markdown
---
name: Skill Name
description: What it does in one line
---

# Skill Name

[Instructions for Kiro on how to execute the skill]

## Output
[Expected output format]
```

### Hooks (.json)

```json
{
  "name": "Hook Name",
  "version": "1.0.0",
  "description": "What it does",
  "when": {
    "type": "event",
    "patterns": ["*.ext"]
  },
  "then": {
    "type": "askAgent|runCommand",
    "prompt": "..." 
  }
}
```

## PR Checklist

- [ ] File in the correct folder (core vs team)
- [ ] Front-matter present and correct (steering/skills)
- [ ] Valid JSON (hooks)
- [ ] Team README updated (if adding files)
- [ ] Tested locally (copied to .kiro/ and verified it works)
- [ ] No conflict with core rules
- [ ] No secret/credential in the file

## Owners

| Area | Owner | Approves PRs on |
|------|-------|-----------------|
| Global | Your Name | global/** |
| teams/team-a/ | Team Lead A | teams/team-a/** |
| teams/team-b/ | Your Name | teams/team-b/** |
| teams/team-c/ | TBD | teams/team-c/** |
| teams/team-d/ | Team Lead D | teams/team-d/** |
| teams/team-e/ | Team Lead E | teams/team-e/** |

## Process

1. **Fork/Branch** → create branch from main
2. **Modify** → add/modify files
3. **Local test** → copy to .kiro/ and verify
4. **PR** → create PR with clear description
5. **Review** → owner approves
6. **Merge** → squash merge to main

## Questions?

Open an issue or ask in the recurring meeting.
