# Migration Guide: Two-Level → Three-Level Architecture

This guide documents the migration from the old two-level architecture (Core + Teams) to the new three-level architecture (Global → Team → Project).

---

## What Changes

### Old structure (two-level)

```
kiro-governance-kit/
├── steering/          ← Core (for everyone)
├── skills/            ← Core (for everyone)
├── hooks/             ← Core (for everyone)
├── mcp-config/        ← MCP config
└── teams/             ← Team-specific
    ├── team-a/
    ├── team-b/
    ├── team-c/
    ├── team-d/
    └── team-e/
```

### New structure (three-level)

```
kiro-governance-kit/
├── global/            ← Level 1: universal (for everyone)
│   ├── steering/
│   ├── skills/
│   ├── hooks/
│   └── mcp-config/
├── teams/             ← Level 2: team-specific
│   ├── _shared/       ← Cross-team (shared between teams)
│   ├── team-a/
│   ├── team-b/
│   ├── team-c/
│   ├── team-d/
│   └── team-e/
├── projects/          ← Level 3: project-specific
│   └── _template/
└── scripts/           ← Install, migrate, validate
```

### Team changes

| Old | New | Notes |
|-----|-----|-------|
| `teams/1/` | Merged → `teams/team-a/` | files merged into team-a |
| `teams/2/` | Split → `teams/team-b/` + `teams/team-c/` | split by domain |

---

## Path Mapping Table

### Root `steering/` → Destinations

| Source (old) | Destination (new) | Action |
|--------------|-------------------|--------|
| `steering/safety.md` | `global/steering/safety.md` | Moved to global |
| `steering/aws-conventions.md` | `global/steering/aws-conventions.md` | Moved to global |
| `steering/code-standards.md` | `global/steering/code-standards.md` | Moved to global |
| `steering/github.md` | `teams/_shared/steering/github.md` | Moved to shared |
| `steering/jira.md` | `teams/_shared/steering/jira.md` | Moved to shared |
| `steering/troubleshooting.md` | `teams/_shared/steering/troubleshooting.md` | Moved to shared |
| `steering/cross-team.md` | `teams/_shared/steering/cross-team.md` | Moved to shared |
| `steering/terraform.md` | `teams/team-b/steering/terraform.md` | Moved to team |
| `steering/eks.md` | `teams/team-a/steering/eks.md` | Moved to team |
| `steering/gitops.md` | `teams/team-a/steering/gitops.md` | Moved to team |
| `steering/finops.md` | `teams/team-c/steering/finops.md` | Moved to team |
| `steering/aws.md` | `teams/team-b/steering/aws.md` | Moved to team |
| `steering/incident-postmortem.md` | `teams/team-e/steering/incident-postmortem.md` | Moved to team |

### Root `skills/` → Destinations

| Source (old) | Destination (new) | Action |
|--------------|-------------------|--------|
| `skills/gov-iam-access.md` | `global/skills/gov-iam-access.md` | Moved to global |
| `skills/gov-security-compliance.md` | `global/skills/gov-security-compliance.md` | Moved to global |
| `skills/gov-tagging-naming.md` | `global/skills/gov-tagging-naming.md` | Moved to global |
| `skills/gov-compliance-scorecard.md` | `global/skills/gov-compliance-scorecard.md` | Moved to global |
| `skills/gov-operational-excellence.md` | `global/skills/gov-operational-excellence.md` | Moved to global |
| `skills/gov-change-management.md` | `global/skills/gov-change-management.md` | Moved to global |
| `skills/team-onboarding-check.md` | `global/skills/team-onboarding-check.md` | Moved to global |
| `skills/gov-cost-finops.md` | `teams/team-c/skills/gov-cost-finops.md` | Moved to team |
| `skills/gov-network.md` | `teams/team-b/skills/gov-network.md` | Moved to team |
| `skills/pr-description.md` | `teams/_shared/skills/pr-description.md` | Moved to shared |
| `skills/systematic-debugging.md` | `teams/_shared/skills/systematic-debugging.md` | Moved to shared |
| `skills/brainstorming.md` | `teams/_shared/skills/brainstorming.md` | Moved to shared |
| `skills/executing-plans.md` | `teams/_shared/skills/executing-plans.md` | Moved to shared |
| `skills/finishing-branch.md` | `teams/_shared/skills/finishing-branch.md` | Moved to shared |
| `skills/writing-plans.md` | `teams/_shared/skills/writing-plans.md` | Moved to shared |
| `skills/subagent-development.md` | `teams/team-a/skills/subagent-development.md` | Moved to team |
| `skills/verification-before-completion.md` | `teams/_shared/skills/verification-before-completion.md` | Moved to shared |

### Root `hooks/` → Destinations

| Source (old) | Destination (new) | Action |
|--------------|-------------------|--------|
| `hooks/shell-safety.json` | `global/hooks/shell-safety.json` | Moved to global |
| `hooks/review-write-ops.json` | `global/hooks/review-write-ops.json` | Moved to global |
| `hooks/document-new-file.json` | `global/hooks/document-new-file.json` | Moved to global |
| `hooks/skill-suggester.json` | `global/hooks/skill-suggester.json` | Moved to global |
| `hooks/helm-lint.json` | `teams/team-a/hooks/helm-lint.json` | Moved to team |
| `hooks/k8s-validate.json` | `teams/team-a/hooks/k8s-validate.json` | Moved to team |
| `hooks/tf-fmt.json` | `teams/team-b/hooks/tf-fmt.json` | Moved to team |
| `hooks/tf-validate.json` | `teams/team-b/hooks/tf-validate.json` | Moved to team |
| `hooks/lint-on-save-ts.json` | `teams/team-a/hooks/lint-on-save-ts.json` | Moved to team |
| `hooks/lint-on-save-py.json` | `teams/team-a/hooks/lint-on-save-py.json` | Moved to team |
| `hooks/quality-check.json` | `teams/_shared/hooks/quality-check.json` | Moved to shared |
| `hooks/test-after-task.json` | `teams/team-a/hooks/test-after-task.json` | Moved to team |
| `hooks/pr-description.json` | `teams/_shared/hooks/pr-description.json` | Moved to shared |
| `hooks/drift-detection.json` | `teams/team-b/hooks/drift-detection.json` | Moved to team |
| `hooks/policy-validation.json` | `teams/team-b/hooks/policy-validation.json` | Moved to team |

### Root `mcp-config/` → Destination

| Source (old) | Destination (new) | Action |
|--------------|-------------------|--------|
| `mcp-config/mcp.json` | `global/mcp-config/mcp.json` | Moved to global |

---

## Step-by-Step Migration

### Prerequisites

- macOS or Linux with bash/zsh
- Git
- Access to the repo `your-org/kiro-governance-kit`

### Backup

```bash
# Create backup of current configuration
BACKUP_DIR="$HOME/.kiro-backup-$(date +%Y%m%d-%H%M%S)"
cp -r ~/.kiro/ "$BACKUP_DIR"
echo "Backup created at: $BACKUP_DIR"
```

### Automated Migration (recommended)

```bash
cd kiro-governance-kit
git pull origin main

# Run the migration script
chmod +x scripts/migrate.sh
./scripts/migrate.sh

# Or dry-run to see what would change
./scripts/migrate.sh --dry-run
```

### Manual Migration

#### Step 1: Update the repository

```bash
cd kiro-governance-kit
git pull origin main
```

#### Step 2: Clean old installation

```bash
# Remove old files (after backup!)
rm -rf ~/.kiro/steering/
rm -rf ~/.kiro/skills/
rm -rf ~/.kiro/hooks/
```

#### Step 3: Reinstall with the new script

```bash
chmod +x scripts/install.sh

# Install for your team (example: team-a)
./scripts/install.sh --team team-a

# Or with specific project
./scripts/install.sh --team team-a --project my-api
```

#### Step 4: Verify

```bash
# Check that files are installed
ls ~/.kiro/steering/
ls ~/.kiro/skills/

# In Kiro: type # to verify available skills
```

---

## Preserving Customizations

### Strategy

1. **Automatic backup** — `migrate.sh` creates a timestamped backup before any changes
2. **Customization detection** — files not present in the kit are preserved
3. **Manual merge** — if you modified kit files, the backup allows you to re-apply changes

### Custom files

If you added custom files in `~/.kiro/steering/` or `~/.kiro/skills/`:
- The migration script preserves them (does not delete them)
- After migration, verify there are no name conflicts with new files

### MCP Config

The `~/.kiro/settings/mcp.json` file with your credentials **is not touched** by the migration. The script only merges new server entries without overwriting existing ones.

---

## Rollback

If something goes wrong:

```bash
# Restore from backup
rm -rf ~/.kiro/
cp -r "$BACKUP_DIR" ~/.kiro/
echo "Rollback completed"
```

---

## Idempotency

The `migrate.sh` script is idempotent:
- Creates a marker file `.migration-marker` in `~/.kiro/` after the first migration
- If the marker exists with the current version, the script exits without changes
- To force a re-migration: `rm ~/.kiro/.migration-marker`

---

## Old Team → New Team Mapping

If you were on the `eks` team:
```bash
./scripts/install.sh --team team-a
# EKS files are now part of team-a
```

If you were on the `infrastructure` team:
```bash
# Choose based on your focus:
./scripts/install.sh --team team-b  # IaC, Terraform, networking
./scripts/install.sh --team team-c  # Cost optimization, budgets
```

---

## FAQ

**Q: Do I need to reinstall everything?**
A: Yes, but the `install.sh` script handles everything automatically. Just specify `--team`.

**Q: Will my MCP files be overwritten?**
A: No. The script merges new servers without touching existing credentials.

**Q: Can I use both team and project?**
A: Yes. `--project` is optional and adds a third level of configuration.

**Q: What happens to the eks/ and terraform/ templates?**
A: Removed. Use `./scripts/install.sh --team team-a` (for eks) or `--team team-b` (for terraform).
