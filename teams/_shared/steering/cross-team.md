---
inclusion: manual
---

# Cross-Team Knowledge Sharing

Quick reference for inter-team collaboration. Invoke with `#cross-team`.

## Team Directory

| Team | Owner | Domain | Slack Channel |
|------|-------|--------|---------------|
| Team A | Team Lead A | Application Development | #team-a |
| Team B | Team Lead B | Infrastructure (IaC, provisioning, networking) | #team-b |
| Team C | Team Lead C | Cost & FinOps | #team-c |
| Team D | Team Lead D | Integration (API, data pipelines) | #team-d |
| Team E | Team Lead E | Support & Operations | #team-e |

## Who to Contact for What

| Need | Team | Contact |
|------|------|---------|
| New cloud account | Team B | Team Lead B |
| IAM / SSO permissions | Team B | Team Lead B |
| Networking / connectivity | Team B | Team Lead B |
| Application deployment | Team A | Team Lead A |
| Code review | Team A | Team Lead A |
| New API integration | Team D | Team Lead D |
| Data pipeline | Team D | Team Lead D |
| Systems integration | Team E | Team Lead E |
| Production incident | Team E (1st) → Team B/A (2nd) | On-call rotation |
| Frontend code review | Team A | Team Lead A |
| CI/CD pipeline | Team B + Team A | Collaborative |
| Cost optimization | Team C | TBD |

## Escalation Path

```
L1: Team owner of impacted service
 ↓ (15 min without resolution)
L2: Infra/platform team for cross-cutting issues
 ↓ (30 min without resolution)
L3: War room with all involved teams
 ↓ (critical business impact)
L4: Management escalation
```

## Shared Runbooks

| Runbook | Where | When |
|---------|-------|------|
| Compute scaling | Wiki/Infra/Runbooks | Nodes under pressure |
| Database failover | Wiki/Infra/Runbooks | DB unreachable |
| Deployment sync failure | Wiki/Infra/Runbooks | App out-of-sync |
| API integration down | Wiki/Support/Runbooks | API not responding |
| Cloud account lockout | Wiki/Infra/Runbooks | Access blocked |
| Incident response | Wiki/Support/Runbooks | Any P1/P2 |

## Decision Log (ADR)

Significant architectural decisions:

| # | Date | Decision | Context | Team |
|---|------|----------|---------|------|
| ADR-001 | 2024-03 | Managed containers for stateless workloads | Reduce ops overhead | Team A |
| ADR-002 | 2024-05 | Standardized account provisioning | Multi-account standardization | Team B |
| ADR-003 | 2024-07 | GitOps deployment pattern | Managing many microservices | Team A |
| ADR-004 | 2024-09 | Central API gateway for integration | Systems integration | Team D |
| ADR-005 | 2025-01 | Centralized Kiro governance kit | AI-assisted dev standardization | Team B |

For new ADRs: create a page in Confluence/Architecture/ADR with the standard template.

## Shared Resources

### Shared repositories
- `your-org/aws-deployment-framework-bootstrap` — Account provisioning
- `your-org/aws-deployment-framework-pipelines` — CI/CD pipelines
- `your-org/kiro-governance-kit` — This repo (Kiro governance)

### Shared tools
- **Monitoring dashboards**: cross-team monitoring
- **Deployment tooling**: GitOps deploy
- **Cloud org management**: account governance
- **Issue tracker**: shared project for cross-team requests

## How to Request Cross-Team Support

1. Create a Jira ticket in the target team's project
2. Tag the owner in the appropriate Slack channel
3. For urgencies: escalation path above
4. For architectural decisions: propose an ADR and discuss in the weekly

## Weekly Sync

- **When**: Wednesday 10:00
- **Who**: Owner of each team
- **Where**: Teams / Meeting Room 3
- **Agenda**: Cross-team blockers, pending ADRs, incident review
