---
name: gov-operational-excellence
description: >
  Operational Excellence governance. Monitoring, alerting, incident response,
  backup/DR, and runbook standards.
---

# Operational Excellence Governance

## When to Use
- Validating production readiness
- Reviewing monitoring/alerting setup
- Creating incident reports
- Defining backup/DR requirements

## Production Readiness Checklist

### Monitoring
- [ ] CloudWatch dashboards for key metrics
- [ ] Custom metrics for business KPIs
- [ ] Container Insights for EKS workloads
- [ ] APM/tracing (X-Ray or equivalent)
- [ ] Log aggregation with retention policies

### Alerting
- [ ] CPU/Memory > 80% sustained → warning
- [ ] CPU/Memory > 90% sustained → critical
- [ ] Error rate > threshold → alert
- [ ] Latency p99 > SLA → alert
- [ ] Health check failures → immediate
- [ ] Alert routing: PagerDuty/SNS → team channel

### Backup & DR
- [ ] RDS: automated backups, retention ≥ 7 days (prod: 30)
- [ ] S3: versioning enabled on critical buckets
- [ ] EBS: snapshot schedule for stateful workloads
- [ ] DynamoDB: PITR enabled
- [ ] Cross-region backup for critical data
- [ ] DR runbook documented and tested

### Incident Response
- [ ] Escalation path defined
- [ ] Runbooks for common failures
- [ ] Post-mortem template standardized
- [ ] Communication plan (stakeholders, status page)
- [ ] Rollback procedure documented

## Incident Report Template

```markdown
# Incident: {title}

**Severity**: P1/P2/P3/P4
**Duration**: {start} → {end}
**Impact**: {description}

## Timeline
| Time (UTC) | Event |
|------------|-------|

## Root Cause
## Resolution
## Action Items
| # | Action | Owner | Due |
```

## Log Retention Standards

| Log Type | Retention | Tier |
|----------|-----------|------|
| Application (prod) | 90 days | CloudWatch |
| Application (non-prod) | 30 days | CloudWatch |
| Access logs (ALB/S3) | 1 year | S3 IA |
| CloudTrail | 1 year | S3 IA |
| VPC Flow Logs | 90 days | CloudWatch |
| Audit logs | 7 years | S3 Glacier |

## Output Format

```
## Operational Readiness: {service}

### 🔴 Not Production Ready
### 🟡 Gaps (acceptable with risk acceptance)
### ✅ Ready
### 📋 Runbook Status
```

## Customization Points
<!-- Teams: add SLA targets, specific alert thresholds, DR RTO/RPO requirements -->
