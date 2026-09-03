---
inclusion: auto
---

# AWS Conventions (Workspace)

## Account Structure

- Multi-account via AWS Organizations
- Pattern: {x}-{y}-{z}
- Environments: test → uat → prod

## Naming Conventions

- S3 buckets: {account-alias}-{purpose}-{env}-{region}
- Lambda: {tag1}-{function-name}-{env}
- Glue jobs: {tag1}_{job_name}_{env}
- IAM roles: {tag2}-{purpose}-role
- CloudFormation stacks: {tag1}-{resource}-{env}

## Tagging Policy

- Required: tag1, tag2, tag3, tag4, tag5, tag6
- Lowercase tag values
- Enforce via SCP and AWS Config rules

## Infrastructure as Code

- ADF bootstrap for account provisioning
- CloudFormation preferred for infra in this workspace
- Parameters for env-specific values
- Termination protection on prod stacks

## Security

- No hardcoded credentials
- IAM roles over access keys
- SSO via AWS Identity Center
- Least privilege principle
