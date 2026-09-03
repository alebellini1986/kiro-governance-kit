---
name: gov-iam-access
description: >
  IAM & Access governance review. Audits IAM policies, roles, SCPs, trust relationships,
  and permission boundaries for compliance with organizational standards.
---

# IAM & Access Governance

## When to Use
- Reviewing IAM policies/roles before deployment
- Auditing cross-account access
- Validating SCP enforcement
- Checking permission boundaries

## Review Checklist

### IAM Policies
- [ ] No wildcard actions (`Action: "*"`) without justification
- [ ] No wildcard resources (`Resource: "*"`) without condition constraints
- [ ] Prefer managed policies over inline
- [ ] Policy size within limits (6144 chars managed, 2048 inline)
- [ ] Deny statements for sensitive actions (iam:*, organizations:*)

### IAM Roles
- [ ] Trust policy: only expected principals
- [ ] No cross-account trust without documentation
- [ ] Session duration appropriate (1h default, max 12h justified)
- [ ] Naming follows: {service}-{purpose}-role
- [ ] Tags: Environment, Project, Owner, CostCenter

### SCPs (Service Control Policies)
- [ ] Deny regions outside us-east-1 (unless justified)
- [ ] Deny disabling CloudTrail/GuardDuty/Config
- [ ] Deny leaving organization
- [ ] Deny root account usage
- [ ] Allow list for approved services only

### Cross-Account Access
- [ ] Documented in architecture diagram
- [ ] Minimal permissions (not AdministratorAccess)
- [ ] External ID for third-party access
- [ ] Condition keys (aws:PrincipalOrgID) where possible

## Output Format

```
## IAM Governance: {resource}

### ✅ Compliant
### ⚠️ Warnings (fix within sprint)
### ❌ Non-Compliant (block deployment)
### 📋 Recommendations
```

## Customization Points
<!-- Teams: add org-specific rules below -->
<!-- Example: specific SCP exceptions, approved cross-account patterns -->
