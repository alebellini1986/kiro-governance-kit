# Kiro Cheat Sheet — Quick Reference

## Chat — Basic Commands

| Action | How to |
|--------|--------|
| Invoke a skill | `#` in chat → select from list |
| Reference a file | `#File` → select |
| Reference a folder | `#Folder` → select |
| Active file problems | `#Problems` |
| Terminal output | `#Terminal` |
| Current Git diff | `#Git Diff` |
| Attach image/doc | Drag into chat or 📎 |

## Governance Skills

| Skill | What it does |
|-------|--------------|
| `#gov-iam-access` | Review IAM policy, roles, SCPs |
| `#gov-security-compliance` | Security audit, encryption, GDPR |
| `#gov-compliance-scorecard` | Compliance scorecard for AWS account |
| `#gov-network` | Review VPC, Security Groups |
| `#gov-tagging-naming` | Check tags and naming conventions |
| `#gov-cost-finops` | Cost estimation and optimization |
| `#gov-operational-excellence` | Production readiness check |
| `#gov-change-management` | PR and deployment review |

## Workflow & Methodology Skills

| Skill | What it does |
|-------|--------------|
| `#brainstorming` | Structured brainstorming for ideas and design |
| `#writing-plans` | Writing multi-step implementation plans |
| `#executing-plans` | Guided execution of existing plans |
| `#systematic-debugging` | Methodical debugging with structured approach |
| `#verification-before-completion` | Pre-completion verification and testing |
| `#finishing-branch` | Branch completion, merge, and PR |
| `#subagent-development` | Development with sub-agent orchestration |

## Operations Skills

| Skill | What it does |
|-------|--------------|
| `#pr-description` | Generate PR description |
| `#team-onboarding-check` | Verify new member onboarding setup |

## Steering — Types

| Type | When it activates |
|------|-------------------|
| `auto` | Every interaction |
| `fileMatch` | When you open matching files |
| `manual` | Only with `#name` |

## Daily Patterns

```
# PR description
#pr-description
Generate the PR description for the current diff

# Ticket analysis
Analyze ticket PROJ-123 and suggest an approach

# Error debugging
#Terminal
#systematic-debugging
Analyze the error and suggest a fix

# Security review
#gov-security-compliance
#File <file>
Do a security audit

# Brainstorming
#brainstorming
How can I implement X? Explore options.

# Implementation plan
#writing-plans
Write a plan to implement feature Y
```

## MCP — What to Ask

| Server | Example |
|--------|---------|
| Atlassian | "Show tickets in sprint", "Create Confluence page" |
| GitHub | "Create PR", "List commits" |
| AWS Docs | "How do I configure ALB with WAF?" |
| AWS Core | "List EC2 in eu-west-1" |
| Figma | "Extract components from frame X", "Generate code from design" |
| Miro | "Read stickies from board", "Create diagram from code" |
| Clarity | "Scroll depth last 2 days by device" |
| Typeform | "List responses to form X", "Create new survey" |

## Hooks

Management: Command Palette → "Open Kiro Hook UI"

| Event | Use |
|-------|-----|
| `fileEdited` | Lint on save |
| `postTaskExecution` | Test after task |
| `agentStop` | PR description |
| `preToolUse` | Safety check, policy validation |
| `postToolUse` | Drift detection |
| `promptSubmit` | Quality check, skill suggester |

## Ponytail — Lazy Senior Dev 🐴

Active for everyone via `_shared/steering/ponytail.md`. Decision ladder:
1. Is it really needed? → YAGNI
2. Already in the codebase? → Reuse
3. Stdlib does it? → Use stdlib
4. Platform native? → Use native
5. Installed dependency? → Use that
6. One line? → One line
7. Only then: write the minimum that works

> Never lazy about: input validation, error handling, security, accessibility.

## Quick Troubleshooting

| Problem | Fix |
|---------|-----|
| MCP doesn't connect | Command Palette → "Reconnect MCP Servers" |
| Steering not active | Verify path `.kiro/steering/` |
| Skill doesn't appear | Skills only in `~/.kiro/skills/` |
| Generic response | Add context with `#File` |
| Tokens exhausted | Activate caveman mode |
