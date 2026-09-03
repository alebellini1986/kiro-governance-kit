# Installation

## Prerequisites

- macOS or Linux (bash/zsh)
- Git
- [Kiro](https://kiro.dev) installed
- Access to the repo (org `your-org`)

### System Dependencies

The installation script and MCP servers require some dependencies. Follow these steps in the indicated order.

#### 1. Homebrew (macOS)

If you don't have Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Verify: `brew --version`

#### 2. Node.js (≥ 18)

Required for MCP servers (GitHub, Atlassian, Puppeteer, etc.).

```bash
brew install node@22
```

Verify: `node --version` (must be ≥ 18)

#### 3. Python + uv/uvx

Required for Python MCP servers (AWS docs, filesystem, etc.). `uvx` downloads and runs MCP servers without manual installation.

```bash
brew install uv
```

Verify: `uv --version` and `uvx --version`

> **Note:** `uvx` is included with `uv`. No separate `pip install` is needed.

#### 4. AWS CLI + SSO

Required for the `aws-core` MCP server.

```bash
brew install awscli
aws configure sso
```

Follow the SSO wizard with your company profile. Verify: `aws sts get-caller-identity`

#### 5. Git + SSH key

```bash
# If you don't have an SSH key configured for GitHub:
ssh-keygen -t ed25519 -C "your.email@your-org.com"
# Add the public key on GitHub → Settings → SSH keys
```

Verify: `ssh -T git@github.com`

#### Quick Verification Summary

```bash
brew --version        # Homebrew
node --version        # Node.js ≥ 18
uv --version          # uv (includes uvx)
aws --version         # AWS CLI
git --version         # Git
ssh -T git@github.com # SSH access to GitHub
```

If any of these fail, install the missing dependency before proceeding.

## Quick Install (automated script)

```bash
git clone https://github.com/your-org/kiro-governance-kit.git
cd kiro-governance-kit
chmod +x scripts/install.sh

# Install Global + Team
./scripts/install.sh --team <your-team>

# Or Global + Team + Project
./scripts/install.sh --team <your-team> --project <your-project>
```

### Available Teams

| Team | Domain |
|------|--------|
| `team-a` | Application Development — general software development, testing, code review |
| `team-b` | Infrastructure — IaC, cloud provisioning, networking |
| `team-c` | Cost & FinOps — cost optimization, budgets |
| `team-d` | Integration — API integration, data pipelines |
| `team-e` | Support & Operations — incident response, ticketing, monitoring |

### What the Script Does

The script installs in three phases:

1. **Global** — `global/{steering,skills,hooks}` → `~/.kiro/`
2. **Shared** — `teams/_shared/{steering,skills,hooks}` → `~/.kiro/`
3. **Team** — `teams/<team>/{steering,skills,hooks}` → `~/.kiro/`
4. **Project** (optional) — `projects/<project>/{steering,skills,hooks}` → `~/.kiro/`
5. **MCP Config** — merge from all levels → `~/.kiro/settings/mcp.json`

Includes:
- Conflict detection (duplicate files between levels → abort)
- Prerequisite checks (Node, Python, AWS CLI)
- Verification summary

---

## Manual Installation

### 1. Global (required for everyone)

```bash
mkdir -p ~/.kiro/steering ~/.kiro/skills

# Global steering
cp global/steering/* ~/.kiro/steering/

# Global skills
cp global/skills/* ~/.kiro/skills/
```

### 2. Shared (cross-team, recommended)

```bash
# Shared steering
cp teams/_shared/steering/* ~/.kiro/steering/

# Shared skills
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
```

⚠️ **Configure credentials** in the `mcp.json` file — placeholders must be replaced with your personal tokens.

---

## Verification

1. Restart Kiro
2. Open chat, type `#` → you should see the skills (e.g. `#gov-iam-access`)
3. Open a `.tf` file → the `terraform.md` steering activates automatically

---

## Updating

```bash
cd kiro-governance-kit
git pull
./scripts/install.sh --team <your-team>
```

The script only overwrites modified files, it does not touch `mcp.json` if already present with credentials.

---

## Migration from Old Structure

If you have the old installation (two-level with root steering/skills/hooks):

```bash
chmod +x scripts/migrate.sh
./scripts/migrate.sh
```

See [MIGRATION.md](./MIGRATION.md) for details.

---

## Uninstallation

```bash
# Remove steering and skills
rm -rf ~/.kiro/steering/
rm -rf ~/.kiro/skills/

# Remove hooks from workspace
rm -rf <your-project>/.kiro/hooks/
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Skills don't appear with `#` | Verify they are in `~/.kiro/skills/` (not workspace) |
| Steering doesn't activate | Verify path `~/.kiro/steering/` and file front-matter |
| Permission denied on install.sh | `chmod +x scripts/install.sh` |
| MCP doesn't connect | Configure credentials in `~/.kiro/settings/mcp.json` |
| Team not found | Verify name with `ls teams/` |
| File conflict between levels | Rename the file in the lower level |
