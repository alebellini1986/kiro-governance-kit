---
name: gov-tagging-naming
description: >
  Tagging & Naming governance. Validates resource tags, naming conventions,
  and organizational taxonomy compliance.
---

# Tagging & Naming Governance

## When to Use
- Reviewing IaC before deployment
- Auditing existing resources for tag compliance
- Onboarding new accounts/projects
- Cost allocation validation

## Required Tags

| Tag | Values | Purpose |
|-----|--------|---------|
| tag1 | {x} or {y} | tag1 allocation |
| tag2 | {x} or {y} | tag2 allocation |
| tag3 | {x} or {y} | tag3 allocation |
| tag4 | {x} or {y} | tag4 allocation |
| tag5 | {x} or {y} | tag5 allocation |

## Naming Conventions

| Resource | Pattern |
|----------|---------|
| AWS Account | {x}-{y}-{z}
| S3 Bucket |  {x}-{y}-{z}
| Lambda |  {x}-{y}-{z}
| Glue Job |  {x}-{y}-{z}
| IAM Role |  {x}-{y}-{z}
| CloudFormation |  {x}-{y}-{z}
| EKS Cluster |  {x}-{y}-{z}
| Security Group |  {x}-{y}-{z}

## Validation Rules

- All values lowercase (except proper nouns in descriptions)
- No generic names: test1, temp, my-bucket, default
- No personal identifiers in resource names
- Region abbreviations: eu-west-1 → euw1, us-east-1 → use1
- Environment abbreviations in names only: dev/test/uat/prod

## Tag Propagation

- ASG → EC2 instances (propagate_at_launch)
- EKS → Node groups (tags block)
- CloudFormation → all resources (stack-level tags)
- Terraform → default_tags in provider

## Output Format

```
## Tag & Naming Review: {scope}

### ❌ Missing Required Tags
| Resource | Missing Tags |
|----------|-------------|

### ⚠️ Naming Violations
| Resource | Current | Expected |
|----------|---------|----------|

### ✅ Compliant Resources: {count}/{total}
```

## Customization Points
<!-- Teams: add specific patterns, additional optional tags, exceptions -->
