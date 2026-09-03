---
inclusion: manual
---

# Team Onboarding Check

Skill to verify that a team member has correctly completed the Kiro Governance Kit setup.

## When to Use

Invoke `#team-onboarding-check` when:
- A new member has just run the installer
- You want to verify your setup is complete
- Troubleshooting: something isn't working as expected

## Automated Checklist

### 1. Steering Files
Verify presence in `~/.kiro/steering/`:

| File | Type | Required |
|------|------|:---:|
| safety.md | auto | ✅ |
| aws-conventions.md | auto | ✅ |
| code-standards.md | auto | ✅ |
| aws.md | fileMatch | ✅ |
| terraform.md | fileMatch | ✅ |
| eks.md | fileMatch | ✅ |
| gitops.md | fileMatch | ✅ |
| troubleshooting.md | manual | ✅ |
| github.md | manual | ✅ |
| jira.md | manual | ✅ |
| finops.md | manual | ✅ |

### 2. Skills
Verify presence in `~/.kiro/skills/`:

- gov-iam-access.md
- gov-security-compliance.md
- gov-network.md
- gov-tagging-naming.md
- gov-cost-finops.md
- gov-operational-excellence.md
- gov-change-management.md
- gov-compliance-scorecard.md
- pr-description.md
- team-onboarding-check.md

### 3. MCP Configuration
Verify `~/.kiro/settings/mcp.json`:

- [ ] File exists
- [ ] any mcp configuration in place

### 4. Hooks (workspace-level)
Verify `.kiro/hooks/` in the current workspace:

- [ ] Directory exists
- [ ] At least shell-safety.json present
- [ ] review-write-ops.json present
- [ ] Team-specific hooks present

### 5. Connectivity
Quick tests:

- [ ] `aws sts get-caller-identity` → responds (SSO active)
- [ ] MCP servers reachable (no timeout in Kiro)
- [ ] Skills visible when typing `#` in chat

## Output Format

```
## Onboarding Check — {username}

| Area | Status | Details |
|------|--------|---------|
| Steering | ✅ 11/11 | All core files present |
| Skills | ⚠️ 8/10 | Missing: gov-compliance-scorecard, team-onboarding-check |
| MCP Config | ✅ OK | No placeholders, all servers configured |
| Hooks | ⚠️ Partial | shell-safety OK, team hooks missing |
| Connectivity | ✅ OK | AWS SSO active, MCP reachable |

**Status: ⚠️ Almost complete — 2 actions required**

### Required Actions
1. Update skills: `cp skills/gov-compliance-scorecard.md ~/.kiro/skills/`
2. Install team hooks: `cp teams/<your-team>/hooks/* .kiro/hooks/`
```

## Instructions

1. Read files in `~/.kiro/steering/`, `~/.kiro/skills/`, `~/.kiro/settings/`
2. Compare against the checklist above
3. If in the current workspace, also verify `.kiro/hooks/`
4. Test AWS connectivity if possible
5. Generate report with corrective actions
