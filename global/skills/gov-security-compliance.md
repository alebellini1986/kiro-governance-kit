---
name: gov-security-compliance
description: >
  Security & Compliance governance. Encryption, network exposure, data protection,
  logging, and regulatory compliance checks.
---

# Security & Compliance Governance

## When to Use
- Pre-deployment security review
- Auditing existing resources
- Compliance validation (GDPR, internal policies)
- Incident investigation

## Review Checklist

### Encryption
- [ ] At rest: enabled on ALL storage (S3, EBS, RDS, DynamoDB, EFS)
- [ ] In transit: TLS 1.2+ enforced
- [ ] KMS keys: rotation enabled, proper key policies
- [ ] No unencrypted secrets in code/config/env vars
- [ ] Secrets Manager or Parameter Store for sensitive values

### Network Exposure
- [ ] No 0.0.0.0/0 ingress except 80/443 on public ALB
- [ ] Security groups: minimal ports, specific CIDR ranges
- [ ] No public RDS/ElastiCache/OpenSearch endpoints
- [ ] No public S3 buckets (unless CloudFront origin with OAC)
- [ ] VPC flow logs enabled
- [ ] Private subnets for all backend services

### Logging & Detection
- [ ] CloudTrail: enabled all regions, S3 + CloudWatch
- [ ] GuardDuty: active in all accounts
- [ ] AWS Config: rules for compliance drift
- [ ] CloudWatch alarms on security events
- [ ] S3 access logging on sensitive buckets
- [ ] VPC flow logs for network forensics

### Data Protection (GDPR)
- [ ] PII identified and classified
- [ ] Data retention policies defined and enforced
- [ ] Cross-border transfer documented (EU → non-EU)
- [ ] Right to deletion implementable
- [ ] Encryption for PII at rest and in transit

### Container Security (EKS)
- [ ] Pod security standards enforced
- [ ] No privileged containers in prod
- [ ] Image scanning (Trivy/ECR scanning)
- [ ] Network policies between namespaces
- [ ] IRSA/Pod Identity over node-level permissions

## Output Format

```
## Security Audit: {target}

### 🔴 Critical (block deployment)
### 🟡 High (fix within sprint)
### 🟢 Passed
### 🔒 Hardening Recommendations
```

## Customization Points
<!-- Teams: add specific compliance frameworks, approved cipher suites, WAF rules -->
