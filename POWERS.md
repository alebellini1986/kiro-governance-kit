# Kiro Powers — Strategic Guide

How to leverage Kiro Powers to enhance the agent with specialized on-demand knowledge.

---

## What is a Power

A Power is a package that combines MCP servers, steering files, and hooks into a capability installable with one click. It activates automatically when the conversation context matches the Power's keywords.

---

## Recommended Powers for the Team

### Required (install immediately)

| Power | What it does | Installation |
|-------|--------------|--------------|
| **Local Long-Term Memory** | Persistent memory across sessions. Saves state, decisions, project context | IDE → Powers panel → search "ltm" |
| **Terraform** | Registry, modules, policy check, HCP workflow | IDE → Powers panel → search "terraform" |
| **IAM Policy Autopilot** | Generates IAM policies by analyzing code | Already installed (see mcp.json) |
| **AWS Infrastructure as Code** | CDK + CloudFormation best practices | IDE → Powers panel → search "infrastructure" |

### Recommended by role

| Power | For whom | What it does |
|-------|----------|--------------|
| **AWS DevOps Agent** | Infra, EKS | Incident investigation, cost optimization, architecture review |
| **AWS Observability** | Everyone | CloudWatch, CloudTrail, APM, gap analysis |
| **AWS Cost Optimization** | FinOps | Spending analysis, recommendations |
| **Context7** | Dev | Up-to-date docs for any library/framework |
| **Build a Power** | You (governance owner) | To create custom company powers |

---

## Local Long-Term Memory (LTM)

### What it is

Local per-project memory that persists across Kiro sessions. Captures state after significant work, enables cheap recall for "pick up where you left off" tasks.

### Setup

1. Install from the Powers panel in Kiro IDE
2. The Power creates an `ltm/` folder in the project
3. After each significant session, Kiro automatically saves context

### Usage

- **Recall**: Kiro automatically loads previous context when you reopen the project
- **Reset**: you can do selective or full memory reset
- **Validation**: the Power verifies memory integrity

### Best Practices

- Use LTM on projects with long, iterative sessions
- Don't use it for one-shot projects
- Periodically review what's stored (`ltm/` folder)

---

## Build a Power (Custom Powers)

### Why

Transform the governance kit into a one-click installable Power. Advantages:
- Instant onboarding (vs bash script)
- On-demand activation based on keywords
- Automatic versioning and updates
- Distribution via GitHub

### Custom Power Structure

```
b2c-governance-power/
├── POWER.md                    ← Documentation + metadata
├── .kiro/
│   ├── steering/               ← Power steering files
│   │   ├── safety.md
│   │   ├── aws-conventions.md
│   │   └── ...
│   ├── hooks/                  ← Power hooks
│   │   ├── policy-validation.json
│   │   ├── skill-suggester.json
│   │   └── ...
│   └── settings/
│       └── mcp.json            ← MCP servers config
└── README.md
```

### POWER.md Template

```markdown
---
name: b2c-governance
displayName: B2C Cloud Governance
description: Governance kit for B2C teams — steering, skills, hooks for AWS multi-account
keywords:
  - governance
  - aws
  - terraform
  - compliance
  - tagging
  - security
  - infrastructure
  - eks
  - iam
author: Your Name
version: 1.0.0
---

# B2C Cloud Governance Power

Complete kit for AWS cloud governance oriented to B2C teams.

## Capabilities

- Automatic policy validation on Terraform/Helm files
- Compliance scorecard for AWS accounts
- Naming and tagging enforcement
- Incident post-mortem generation
- Cross-team knowledge base
- Contextual skill suggestions

## Included MCP Servers

- aws-core (AWS API)
- aws-docs (documentation)
- atlassian (Jira/Confluence)
- github

## Activation

Activates automatically when you mention:
- Governance, compliance, audit
- AWS, Terraform, IAM, EKS
- Tagging, naming, security
- Incident, post-mortem
```

### How to Create the Power

1. Install the "Build a Power" Power from the panel
2. In chat: "I want to create a custom power from my governance kit"
3. The Power guides you through the structuring
4. Publish on GitHub as a public or private repo
5. Share the URL with the team for one-click installation

---

## Workflow: From Governance Kit to Custom Power

```
┌─────────────────────────────────────────────────────────┐
│  TODAY: Governance Kit (repo + install.sh)               │
│  - Manual installation via script                       │
│  - Manual updates (git pull + re-run)                   │
│  - Skills/steering separate from MCP config             │
└────────────────────────┬────────────────────────────────┘
                         │ evolves into
┌────────────────────────┴────────────────────────────────┐
│  TOMORROW: Custom Power (b2c-governance-power)          │
│  - One-click installation from Powers panel             │
│  - Automatic updates                                    │
│  - Everything packaged: steering + hooks + MCP          │
│  - On-demand activation based on keywords               │
└─────────────────────────────────────────────────────────┘
```

---

## Resources

- [Kiro Powers docs](https://kiro.dev/docs/powers/)
- [Powers marketplace](https://kiro.dev/powers/)
- [Create a Power guide](https://kiro.dev/docs/powers/create/)
- [LTM Power repo](https://github.com/DAE-UX/Long-term-memory-power/tree/main/ltm-power)
- [Power Builder repo](https://github.com/kirodotdev/powers/tree/main/power-builder)
