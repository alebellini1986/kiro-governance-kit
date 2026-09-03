---
name: gov-change-management
description: >
  Change Management governance. PR review standards, deployment gates,
  approval workflows, and release management practices.
---

# Change Management Governance

## When to Use
- Reviewing PRs for governance compliance
- Validating deployment pipelines
- Checking approval workflows
- Release planning

## PR Review Gates

### Mandatory Checks (block merge if failing)
- [ ] CI passes (lint, test, build)
- [ ] No secrets in diff (git-secrets/trufflehog)
- [ ] Required reviewers approved (min 1, prod: min 2)
- [ ] Branch up-to-date with main
- [ ] No force-push to protected branches
- [ ] Terraform plan attached for infra changes

### Governance Checks
- [ ] Tags present on new resources
- [ ] Naming conventions followed
- [ ] No hardcoded credentials/account IDs
- [ ] Security group changes justified in description
- [ ] IAM changes reviewed by security team
- [ ] Cost impact noted for significant resource additions

## Deployment Pipeline Standards

### Environment Promotion
```
dev → test → uat → prod
     (auto)  (auto) (manual approval)
```

### Prod Deployment Requirements
- [ ] Change ticket created
- [ ] Rollback plan documented
- [ ] Deployment window agreed (avoid Friday deploys)
- [ ] Monitoring dashboard open during deploy
- [ ] Smoke tests pass post-deploy
- [ ] Communication sent to stakeholders

### Rollback Criteria
- Error rate > 2x baseline within 15 min
- Latency p99 > 2x baseline within 15 min
- Health check failures > 0 within 5 min
- Customer-reported issues within 30 min

## Pipeline Governance

- Account changes: require management account approval
- Bootstrap changes: tested in sandbox first
- SCP changes: reviewed by security + platform team
- Global IAM changes: require 2 approvals

## PR Description Generator

When reviewing/generating PR descriptions:

```markdown
## Summary
{1-2 sentences}

## Changes
- {grouped by area}

## Governance
- Tags: ✅/❌
- Naming: ✅/❌
- Security: ✅/❌
- Cost impact: {estimate or "negligible"}

## Testing
- {what was tested}

## Rollback
- {how to revert if needed}
```

## Output Format

```
## Change Review: {PR/deployment}

### 🚫 Blockers (must fix before merge)
### ⚠️ Governance Gaps (fix or document exception)
### ✅ Approved Checks
### 📋 Deployment Checklist Status
```

## Customization Points
<!-- Teams: add specific approval matrices, deployment windows, environment-specific gates -->
