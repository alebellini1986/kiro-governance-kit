---
inclusion: manual
---

# Governance Compliance Scorecard

Skill to run a quick compliance audit on an AWS account or repository.

## When to Use

Invoke `#gov-compliance-scorecard` when you want to:
- Verify compliance of an AWS account against corporate policies
- Pre-deploy audit on an infrastructure repository
- Periodic governance report for management
- Onboarding check on a new account

## Expected Input

Provide one or more of:
- AWS Account ID or alias
- Repository path or URL
- Specific scope (tags, security, naming, cost)

## Audit Checklist

### 1. Tagging Compliance
- [ ] Required tags present: `tag1`, `tag2`, `tag3`, `tag4`, `tag5`, `tag6`
- [ ] Tag values in lowercase
- [ ] No resources missing required tags
- [ ] `Owner` tag corresponds to a real team/person

### 2. Naming Convention
- [ ] S3 buckets: `{account-alias}-{purpose}-{env}-{region}`
- [ ] Lambda: `{project}-{function-name}-{env}`
- [ ] IAM roles: `{service}-{purpose}-role`
- [ ] CloudFormation stacks: `{project}-{resource}-{env}`
- [ ] No generic names (test1, temp, my-bucket)

### 3. Security
- [ ] No Security Group with 0.0.0.0/0 on non-standard ports
- [ ] No unintentionally public S3 bucket
- [ ] IAM policies follow least privilege
- [ ] No active access keys on root account
- [ ] MFA active on root account
- [ ] Encryption at rest enabled on RDS/EBS/S3

### 4. Cost Governance
- [ ] No idle resources (EC2 stopped > 7 days, unattached EBS)
- [ ] Reserved Instances / Savings Plans in use where appropriate
- [ ] Budget alerts configured
- [ ] No unused NAT Gateway

### 5. Operational Excellence
- [ ] CloudTrail active
- [ ] AWS Config rules active
- [ ] Backup plan configured for critical resources
- [ ] Monitoring/alerting on prod resources

## Output Format

Generate a structured report:

```
## Compliance Scorecard — {target}

| Area | Score | Findings |
|------|-------|----------|
| Tagging | ✅ 95% | 2 resources missing tag2 |
| Naming | ✅ 100% | Compliant |
| Security | ⚠️ 80% | 1 open SG, root MFA missing |
| Cost | ❌ 60% | 3 unattached EBS, no budget alerts |
| Operations | ✅ 90% | Backup plan incomplete |

**Overall Score: 85/100**

### Remediation Priority
1. 🔴 [HIGH] Enable root MFA
2. 🟡 [MED] Remove unattached EBS
3. 🟡 [MED] Configure budget alerts
4. 🟢 [LOW] Add missing tag2 tags
```

## Tools Used

- `aws configservice get-compliance-details-by-config-rule`
- `aws resourcegroupstaggingapi get-resources`
- `aws ec2 describe-security-groups`
- `aws s3api get-bucket-policy-status`
- `aws iam get-credential-report`
- `aws ce get-cost-and-usage` (for idle resources)

## Notes

- Run with an AWS profile that has read-only access to the target account
- Results are indicative — manual validation required for critical security findings
