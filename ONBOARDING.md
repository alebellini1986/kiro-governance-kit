# Onboarding Guide — Kiro Governance Kit

Guide for new users who want to configure Kiro with the team's governance kit.

---

## Prerequisites

### Required software

Before starting, make sure you have installed:

| Tool | Min. version | Purpose | Installation |
| --- | --- | --- | --- |
| **Homebrew** | any | macOS package manager | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` |
| **Node.js** | ≥ 18 | MCP servers (GitHub, Atlassian, Puppeteer) | `brew install node@22` |
| **uv** (includes uvx) | ≥ 0.4 | Python MCP servers (AWS docs, filesystem) | `brew install uv` |
| **AWS CLI** | ≥ 2 | MCP server aws-core | `brew install awscli` |
| **Git** | any | Clone repo, push | `brew install git` |
| **Kiro IDE** | latest | The IDE itself | [kiro.dev](https://kiro.dev) |

### Quick verification

Run this block — if everything is OK you won't see errors:

```bash
brew --version && node --version && uv --version && aws --version && git --version && echo "✅ All OK"
```

### Account configurations

- **GitHub**: SSH key configured (`ssh -T git@github.com` must work)
- **AWS SSO**: profile configured (`aws configure sso`, then `aws sso login`)
- **Atlassian API token**: generated from https://id.atlassian.com/manage-profile/security/api-tokens

---

## Step 1: Clone the kit

```bash
git clone git@github.com:your-org/kiro-governance-kit.git
cd kiro-governance-kit
```

---

## Step 2: Install with the script (recommended)

The kit uses a three-level architecture: **Global → Team → Project**.

### Base installation (Global + Team)

```bash
chmod +x scripts/install.sh

# Choose your team:
./scripts/install.sh --team team-a                    # Application Development
./scripts/install.sh --team team-b                    # Infrastructure
./scripts/install.sh --team team-c                    # Cost & FinOps
./scripts/install.sh --team team-d                    # Integration
./scripts/install.sh --team team-e                    # Support & Operations
```

### Installation with project (Global + Team + Project)

```bash
./scripts/install.sh --team team-a --project my-api
```

### What the script does

1. **Global install** — copies `global/{steering,skills,hooks}` → `~/.kiro/`
2. **Shared install** — copies `teams/_shared/` files → `~/.kiro/`
3. **Team install** — copies `teams/<team>/{steering,skills,hooks}` → `~/.kiro/`
4. **Project install** (if `--project`) — copies `projects/<project>/` → `~/.kiro/`
5. **MCP config** — merges MCP configs from all levels → `~/.kiro/settings/mcp.json`
6. **Conflict check** — verifies there are no duplicate files between levels

---

## Step 3: Configure MCP servers

After installation, configure credentials in `~/.kiro/settings/mcp.json`:

| Placeholder | Where to find it |
|-------------|------------------|
| `<YOUR_USERNAME>` | Your macOS username (e.g. `jsmith`) |
| `<YOUR_GITHUB_PAT>` | GitHub → Settings → Developer settings → Personal access tokens |
| `<YOUR_AWS_PROFILE>` | SSO profile name (e.g. `your-org-account`) |
| `<YOUR_DOMAIN>` | `your-org` |
| `<YOUR_EMAIL>` | Your company email |
| `<YOUR_ATLASSIAN_API_TOKEN>` | https://id.atlassian.com/manage-profile/security/api-tokens |

Restart Kiro or use Command Palette → "MCP: Reconnect Servers"

---

## Step 4: Verify functionality

### Test steering
Open a `.tf` file — you should see in the context that `terraform.md` and `aws.md` are active (fileMatch).

### Test skills
In chat type:
```
#gov-tagging-naming
```
You should see the skill loaded in context.

### Test MCP
In chat ask:
```
List S3 buckets in my account
```
If `aws-core` is configured correctly, Kiro will execute the AWS command.

---

## Manual Installation (alternative)

If you prefer not to use the script:

### 1. Global (required for everyone)

```bash
mkdir -p ~/.kiro/steering ~/.kiro/skills

# Global steering
cp global/steering/* ~/.kiro/steering/

# Global skills
cp global/skills/* ~/.kiro/skills/
```

### 2. Shared (cross-team)

```bash
cp teams/_shared/steering/* ~/.kiro/steering/
cp teams/_shared/skills/* ~/.kiro/skills/
```

### 3. Team (choose yours)

```bash
# Example: team-a
cp teams/team-a/steering/* ~/.kiro/steering/
cp teams/team-a/skills/* ~/.kiro/skills/
```

### 4. Hooks (workspace-level)

```bash
mkdir -p <your-project>/.kiro/hooks/

# Global hooks
cp global/hooks/* <your-project>/.kiro/hooks/

# Shared hooks
cp teams/_shared/hooks/* <your-project>/.kiro/hooks/

# Team hooks
cp teams/<your-team>/hooks/* <your-project>/.kiro/hooks/
```

### 5. MCP Config

```bash
mkdir -p ~/.kiro/settings/
cp global/mcp-config/mcp.json ~/.kiro/settings/mcp.json
# Configure credentials in the file
```

---

## Migration from Old Structure

If you already have the kit installed with the old structure (two-level):

```bash
chmod +x scripts/migrate.sh
./scripts/migrate.sh
```

See [MIGRATION.md](./MIGRATION.md) for full details.

---

## Daily Usage

### Scenario: Infrastructure review before merge

1. Open PR with Terraform changes
2. In chat: `#gov-tagging-naming` → verify tags
3. In chat: `#gov-security-compliance` → security audit
4. In chat: `#gov-cost-finops` → estimate cost impact
5. In chat: `#pr-description` → generate PR description

### Scenario: New AWS account

1. In chat: `#adf-account-generator`
2. Provide: brand, service, environment, email
3. Kiro generates YAML compliant with conventions
4. Commit to bootstrap repo

### Scenario: Troubleshooting

1. In chat: `#systematic-debugging`
2. Describe the problem
3. Kiro follows systematic methodology (verify → search docs → investigate → fix)

### Scenario: Incident

1. Investigate and resolve the problem
2. In chat: `#gov-operational-excellence`
3. Ask to generate incident report
4. Kiro produces structured report with timeline, root cause, action items

### Scenario: Complex feature

1. In chat: `#writing-plans` → write implementation plan
2. In chat: `#executing-plans` → execute step by step
3. In chat: `#verification-before-completion` → final verification
4. In chat: `#finishing-branch` → complete branch and PR

---

## Customization

Every file has a `## Customization Points` section at the bottom. Add your team-specific rules there without modifying the main body.

To create new skills or steering, see [CUSTOMIZATION.md](./CUSTOMIZATION.md).

---

## Setup Troubleshooting

| Problem | Solution |
|---------|----------|
| MCP server doesn't connect | `aws sso login --profile <profile>` |
| Skills not visible in `#` | Verify path: `~/.kiro/skills/*.md` |
| Steering doesn't activate | Check front-matter `inclusion` and `fileMatchPattern` |
| Atlassian timeout | Verify API token is not expired |
| `Unexpected end of JSON` | `mcp.json` empty or malformed — re-copy from template |
| install.sh script fails | Verify valid team with `ls teams/` |

---

## Support

- Repo: https://github.com/your-org/kiro-governance-kit
- Issues: open an issue on the repo for bugs or requests
- Slack: channel `#cloud-governance` (if available)
