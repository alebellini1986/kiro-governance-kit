# Kiro Governance Kit

A framework for standardizing [Kiro IDE](https://kiro.dev) behavior across teams in an enterprise. Centrally manage steering rules, skills, hooks, and MCP configurations using a three-level hierarchy that scales from a single team to an entire organization.

## The Problem

When multiple teams adopt AI-assisted coding, each developer gets a different experience. One team enforces tagging conventions, another ignores them. Security rules exist in one workspace but not the next. Onboarding a new member means manually copying files and hoping nothing was missed.

Without governance:
- **Inconsistent AI behavior** — the same prompt produces different results across teams
- **Security gaps** — destructive commands run unchecked in some workspaces
- **Knowledge silos** — best practices stay locked in individual configurations
- **Onboarding friction** — new members spend hours configuring their IDE

## What This Kit Does

The Kiro Governance Kit provides a Git-managed repository of configurations that shape how the Kiro AI agent behaves. A single `install.sh` command deploys the right configuration to any team member.

It manages three types of Kiro configuration:

| Type | Format | Purpose |
|------|--------|---------|
| **Steering** | `.md` with front-matter | Behavioral rules that shape the AI agent (coding standards, security policies, naming conventions) |
| **Skills** | `.md` with front-matter | Reusable prompt templates invocable with `#` in Kiro chat (code review, compliance checks, debugging) |
| **Hooks** | `.json` (v1 format) | Automations triggered by IDE events (lint on save, PR description on stop, safety checks) |

## Three-Level Architecture

Configuration is organized in a hierarchy. Each level extends the one above it, and the installer merges them together.

```
┌──────────────────────────────────────────────────────────┐
│                  GLOBAL (everyone)                        │
│                                                          │
│  global/steering/   — universal rules (safety, coding    │
│                       standards, AWS conventions)         │
│  global/skills/     — shared skills (compliance checks,  │
│                       tagging, IAM review)                │
│  global/hooks/      — base automations (shell safety,    │
│                       write-op review, doc generation)    │
└──────────────────────┬───────────────────────────────────┘
                       │ extends
┌──────────────────────┴───────────────────────────────────┐
│                  TEAM (per domain)                        │
│                                                          │
│  teams/<name>/steering/   — domain rules (per-team        │
│                             coding and design standards)  │
│  teams/<name>/skills/     — team-only skills             │
│  teams/<name>/hooks/      — team-specific hooks          │
│  teams/_shared/           — cross-team utilities         │
│                             (debugging, PR description,   │
│                              brainstorming skills)        │
└──────────────────────┬───────────────────────────────────┘
                       │ extends (optional)
┌──────────────────────┴───────────────────────────────────┐
│                  PROJECT (per repository)                 │
│                                                          │
│  projects/<name>/   — project-level overrides and        │
│                       repo-specific configuration         │
└──────────────────────────────────────────────────────────┘
```

The installer merges all applicable levels into `~/.kiro/`, with lower levels taking priority. No conflicts are allowed — duplicate filenames across levels cause the install to abort.

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/your-org/kiro-governance-kit.git
cd kiro-governance-kit
```

### 2. Bootstrap your organization (first-time setup)

Run the interactive wizard to define your teams:

```bash
./scripts/bootstrap-kit.sh
```

The wizard prompts for:
- Organization name and GitHub org
- Team names, domains, and owners (add as many as you need)
- Optional orchestrator integration (AWS-based distribution)

It generates:
- **`kit.json`** — the team manifest and source of truth
- **`teams/<name>/`** — a folder per team with steering, skills, hooks, and mcp-config subdirectories
- **`scripts/install.sh`** — a customized installer driven by kit.json

### 3. Install for a team member

```bash
# See available teams
./scripts/install.sh --list

# Install your team's configuration
./scripts/install.sh --team team-a

# Install with a project overlay (optional)
./scripts/install.sh --team team-a --project my-api
```

The installer copies files from three layers into `~/.kiro/`:

1. **Global** — `global/{steering,skills,hooks}` → `~/.kiro/`
2. **Shared** — `teams/_shared/{steering,skills,hooks}` → `~/.kiro/`
3. **Team** — `teams/<name>/{steering,skills,hooks}` → `~/.kiro/`
4. **Project** (if specified) — `projects/<name>/` → `~/.kiro/`

MCP configurations are merged from all levels into `~/.kiro/settings/mcp.json`.

### 4. Verify in Kiro IDE

Open Kiro and type `#` in chat. You should see your governance skills listed. The steering rules activate automatically based on their inclusion mode.

## What Gets Installed

After running the installer, `~/.kiro/` contains:

```
~/.kiro/
├── steering/           ← Behavioral rules (auto-loaded by Kiro)
│   ├── safety.md           (global — blocks destructive operations)
│   ├── aws-conventions.md  (global — naming, tagging, account structure)
│   ├── code-standards.md   (global — coding conventions)
│   ├── cross-team.md       (shared — cross-team knowledge base)
│   └── ...                 (team-specific rules)
│
├── skills/             ← Prompt templates (invoked with # in chat)
│   ├── gov-iam-access.md
│   ├── gov-security-compliance.md
│   ├── gov-tagging-naming.md
│   ├── systematic-debugging.md
│   ├── pr-description.md
│   └── ...
│
├── hooks/              ← Event-driven automations
│   ├── shell-safety.kiro.hook
│   ├── review-write-ops.kiro.hook
│   └── ...
│
└── settings/
    └── mcp.json        ← MCP server configuration (merged)
```

## Repository Structure

```
kiro-governance-kit/
│
├── kit.json                         ← Team manifest (generated by bootstrap)
│
├── global/                          ← Level 1: applied to everyone
│   ├── steering/                    Safety, AWS conventions, code standards
│   ├── skills/                      Governance skills (IAM, security, tagging, etc.)
│   ├── hooks/                       Shell safety, write-op review, doc generation, skill suggester
│   └── agents/                      Global agent definitions
│
├── teams/                           ← Level 2: per-team configuration
│   ├── _shared/                     Cross-team utilities (brainstorming, PR desc, debugging)
│   ├── team-a/                      Example: Application Development
│   ├── team-b/                      Example: Infrastructure
│   ├── team-c/                      Example: Cost & FinOps
│   ├── team-d/                      Example: Integration
│   └── team-e/                      Example: Support & Operations
│
├── projects/                        ← Level 3: per-repository overrides (optional)
│   └── _template/                   Template for new projects
│
├── scripts/
│   ├── bootstrap-kit.sh             First-time org setup wizard
│   ├── install.sh                   Team installer (auto-generated or manual)
│   ├── validate.sh                  Repository structure validation
│   ├── migrate.sh                   Migration from old two-level structure
│   └── governance_validator.py      Python validation module
│
├── ai-usage-collect/                ← Optional: AI usage telemetry
│   ├── client/                      Client-side hooks and scripts
│   ├── terraform/                   Infrastructure for telemetry backend
│   ├── docs/                        Telemetry documentation
│   └── tests/                       Test suite
│
├── templates/                       ← Templates for new teams/projects
├── CHEATSHEET.md                    Quick reference for daily use
├── CONTRIBUTING.md                  How to add content
├── CUSTOMIZATION.md                 How to customize per team
├── INSTALL.md                       Detailed installation guide
├── INTEGRATION-PATTERNS.md          How Kiro fits into workflows
├── METRICS.md                       Adoption tracking
├── MIGRATION.md                     Two-level → three-level migration guide
├── ONBOARDING.md                    New member onboarding
├── POWERS.md                        Kiro Powers integration guide
├── TEAM-CAPABILITIES.md             Complete map of all configurations per team
└── buildspec.yml                    CI/CD pipeline definition
```

## Bootstrap Wizard

The `scripts/bootstrap-kit.sh` wizard is the recommended way to set up the kit for your organization. It runs once and produces everything needed.

### What it asks

| Section | Prompts | Purpose |
|---------|---------|---------|
| Organization | Name, GitHub org, AWS region, cost center, admin email | Identifies your org in kit.json |
| Teams | Name, domain, owner (repeat for each team) | Creates team folders and manifest entries |
| Orchestrator | Enable/disable, API endpoint, S3 bucket | Optional AWS-based distribution |

### What it generates

**`kit.json`** — the source of truth for team configuration:

```json
{
  "version": "1.0.0",
  "organization": "Acme Corp",
  "github_org": "acme-corp",
  "aws_region": "us-east-1",
  "teams": [
    { "name": "platform", "domain": "K8s, CI/CD, Observability", "owner": "jane@acme.com" },
    { "name": "backend", "domain": "Python, Go, APIs", "owner": "john@acme.com" }
  ],
  "orchestrator": { "enabled": false }
}
```

**Team folders** — each with `steering/`, `skills/`, `hooks/`, `mcp-config/`, and a `README.md`.

**`scripts/install.sh`** — a customized installer that reads kit.json and knows about your teams.

### Re-running bootstrap

Running `bootstrap-kit.sh` again is safe. It preserves existing team content and only creates folders for new teams.

## Contributing

### Add content to your team

```bash
# 1. Branch
git checkout -b feat/team-a-new-skill

# 2. Add file
cat > teams/team-a/skills/my-skill.md << 'EOF'
---
name: My Skill
description: One-line description of what it does
---
# My Skill

[Instructions for the Kiro agent]
EOF

# 3. Commit and PR
git add teams/team-a/skills/my-skill.md
git commit -m "feat(team-a): add my-skill"
git push -u origin feat/team-a-new-skill
```

### Rules

1. Changes to `global/` require governance admin review
2. Changes to `teams/<your-team>/` require your team owner's approval
3. Team rules must not contradict global rules
4. Every file should have a clear purpose

### Validation

Run the validator before submitting a PR:

```bash
./scripts/validate.sh          # Check structure and assignments
./scripts/validate.sh --fix    # Auto-fix where possible
./scripts/validate.sh --verbose # Detailed output
```

The validator checks:
- All config files are listed in TEAM-CAPABILITIES.md
- No duplicate filenames across teams (unless in `_shared/`)
- Directory naming conventions
- Team folder structure (required subdirectories + README)
- Project manifests reference valid teams
- No domain-specific files in `global/`
- Team roster consistency

## File Formats

### Steering (`.md` with YAML front-matter)

```markdown
---
inclusion: auto
---

# Safety Rules

- Never run destructive commands without confirmation
- Always verify the target before delete operations
```

Inclusion modes:
- **`auto`** — active in every Kiro session
- **`fileMatch`** — active only when a matching file is open (requires `fileMatchPattern`)
- **`manual`** — activated on demand via `#` in chat

### Skills (`.md` with YAML front-matter)

```markdown
---
name: Gov IAM Access
description: Review IAM policies, roles, and SCPs for compliance
---

# IAM Access Review

Analyze the following IAM configuration and check for:
1. Least-privilege violations
2. Overly permissive policies
...
```

Skills are invoked in Kiro chat by typing `#` followed by the skill name.

### Hooks (`.json`, Kiro v1 format)

```json
{
  "name": "Shell Safety",
  "version": "1.0.0",
  "description": "Reviews shell commands before execution",
  "when": {
    "type": "preToolUse",
    "patterns": ["execute_bash", "control_bash_process"]
  },
  "then": {
    "type": "askAgent",
    "prompt": "Review this shell command for safety..."
  }
}
```

Hooks live as `.json` in the repository and are installed as `.kiro.hook` files in `~/.kiro/hooks/`.

## Inclusion Modes

Steering files support three activation strategies:

| Mode | Front-matter | Behavior | Example use |
|------|-------------|----------|-------------|
| `auto` | `inclusion: auto` | Always active in every session | Safety rules, coding standards |
| `fileMatch` | `inclusion: fileMatch` + `fileMatchPattern: "*.tf"` | Active only when a matching file is open | Terraform conventions, Helm rules |
| `manual` | `inclusion: manual` | Only when invoked with `#` in chat | Troubleshooting guide, Jira workflow |

## Governance Orchestrator (Optional)

For organizations where not all members have Git access, the **[Kiro Governance Orchestrator](https://github.com/your-org/kiro-governance-orchestrator)** adds AWS-based distribution:

- **S3 artifacts** — no Git needed for consumers
- **Telemetry** — tracks who has which configurations installed
- **Auto-update** — SessionStart hook checks for new versions
- **Adoption dashboard** — CloudWatch metrics on team rollout
- **Non-destructive sync** — manifest-based, never overwrites user customizations

Architecture: CodePipeline → S3 → API Gateway → Lambda → DynamoDB

Enable by running `bootstrap-kit.sh` and answering "yes" to orchestrator integration, or deploy the orchestrator repository separately.

## AI Usage Telemetry (Optional)

The `ai-usage-collect/` module provides optional usage tracking for AI interactions. It includes:

- **Client hooks** — capture usage events (prompt classifications, session snapshots)
- **Terraform infrastructure** — deploy a telemetry backend (S3 + Lambda + DynamoDB)
- **Tag-based classification** — categorize AI usage by domain, task type, and team

This module is completely optional and requires explicit opt-in. See `ai-usage-collect/README.md` for setup instructions.

## Migration from Two-Level Structure

If you have an existing installation from the old flat structure:

```bash
# Create a backup first
./scripts/migrate.sh --dry-run   # Preview changes
./scripts/migrate.sh             # Execute migration

# Then reinstall with team
./scripts/install.sh --team <your-team>
```

See [MIGRATION.md](./MIGRATION.md) for the complete migration guide.

## Related Documentation

| Document | Purpose |
|----------|---------|
| [ONBOARDING.md](./ONBOARDING.md) | New member setup guide |
| [CHEATSHEET.md](./CHEATSHEET.md) | Daily quick reference |
| [TEAM-CAPABILITIES.md](./TEAM-CAPABILITIES.md) | Complete config map per team |
| [CONTRIBUTING.md](./CONTRIBUTING.md) | How to add content |
| [CUSTOMIZATION.md](./CUSTOMIZATION.md) | Per-team customization guide |
| [INTEGRATION-PATTERNS.md](./INTEGRATION-PATTERNS.md) | Workflow patterns |
| [POWERS.md](./POWERS.md) | Kiro Powers integration |
| [METRICS.md](./METRICS.md) | Adoption tracking |
| [MIGRATION.md](./MIGRATION.md) | Two-level → three-level migration |
| [INSTALL.md](./INSTALL.md) | Detailed installation reference |

## License

MIT
