# Teams Directory

Kiro configurations organized by team. Each folder is self-contained and independently managed.

## Structure

```
teams/
├── _shared/       Cross-team configs applied to all teams
├── team-a/        Example team folder (customize via bootstrap)
├── team-b/
├── team-c/
├── team-d/
└── team-e/
```

## _shared/

Contains steering rules, skills, and hooks inherited by every team.
Installed automatically by `scripts/install.sh` regardless of which team is selected.

## Team Folders (team-a through team-e)

Example/template folders. Duplicate and rename for your real team, or use the bootstrap script to generate one.

Each team folder contains:

- `steering/` — domain-specific behavioral rules
- `skills/` — reusable prompts and workflows
- `hooks/` — automation triggers (pre-commit, post-save, etc.)

## Usage

```bash
# Bootstrap a new team from template
./scripts/install.sh --team <your-team>
```

Teams extend the global layer (`global/`) with domain-specific configuration.
No conflicts allowed — overrides to global rules require team-wide agreement.
