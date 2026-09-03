# Adoption Metrics — Kiro Governance Kit

Tracking governance kit adoption across teams.

---

## Adoption Dashboard

### Status per Team

| Team | Owner | Core installed | Team config | MCP active | Last updated |
|------|-------|:---:|:---:|:---:|------|
| team-a | Team Lead A | ⬜ | ⬜ | ⬜ | — |
| team-b | Team Lead B | ✅ | ✅ | ✅ | — |
| team-c | Team Lead C | ⬜ | ⬜ | ⬜ | — |
| team-d | Team Lead D | ⬜ | ⬜ | ⬜ | — |
| team-e | Team Lead E | ⬜ | ⬜ | ⬜ | — |

**Legend:** ✅ Completed | ⚠️ Partial | ⬜ Not started

### Aggregate Metrics

| Metric | Value | Target |
|--------|-------|--------|
| Teams onboarded | 2/5 | 5/5 by Q4 2026 |
| Members with complete setup | — | 100% active teams |
| Most used skills | — | Tracking via feedback |
| Active hooks (average per workspace) | — | ≥ 5 |
| Incidents with generated post-mortem | — | 100% P1/P2 |
| Average compliance score | — | ≥ 85/100 |

---

## Skills Usage Tracking

Track which skills are used most to understand where to invest.

### Governance Skills

| Skill | Estimated uses/month | Feedback |
|-------|:---:|----------|
| #gov-tagging-naming | — | — |
| #gov-security-compliance | — | — |
| #gov-compliance-scorecard | — | — |
| #gov-cost-finops | — | — |
| #gov-iam-access | — | — |
| #gov-operational-excellence | — | — |
| #gov-change-management | — | — |
| #gov-network | — | — |

### Workflow & Methodology Skills

| Skill | Estimated uses/month | Feedback |
|-------|:---:|----------|
| #brainstorming | — | — |
| #writing-plans | — | — |
| #executing-plans | — | — |
| #systematic-debugging | — | — |
| #verification-before-completion | — | — |
| #finishing-branch | — | — |
| #subagent-development | — | — |

### Operations Skills

| Skill | Estimated uses/month | Feedback |
|-------|:---:|----------|
| #pr-description | — | — |
| #team-onboarding-check | — | — |

> **How to track:** Each member can update this file with a +1 when they use a skill. Alternatively, collect feedback in the weekly sync.

---

## Hooks Effectiveness

| Hook | Trigger | Activations/week | False positives | Notes |
|------|---------|:---:|:---:|------|
| shell-safety | preToolUse (shell) | — | — | — |
| review-write-ops | preToolUse (write) | — | — | — |
| policy-validation | preToolUse (write) | — | — | — |
| drift-detection | postToolUse (shell) | — | — | — |
| skill-suggester | promptSubmit | — | — | — |
| quality-check | promptSubmit | — | — | — |
| lint-on-save-ts | fileEdited (*.ts, *.tsx) | — | — | — |
| lint-on-save-py | fileEdited (*.py) | — | — | — |
| test-after-task | postTaskExecution | — | — | — |
| pr-description | agentStop | — | — | — |
| document-new-file | fileCreated | — | — | — |
| helm-lint | fileEdited (*.yaml) | — | — | — |
| k8s-validate | fileEdited (*.yaml) | — | — | — |
| tf-fmt | fileEdited (*.tf) | — | — | — |
| tf-validate | fileEdited (*.tf) | — | — | — |

---

## Feedback Loop

### How to contribute feedback

1. **GitHub Issue**: open an issue with label `feedback` for suggestions
2. **Weekly sync**: bring feedback to the weekly meeting
3. **Direct PR**: improve steering/skills/hooks and open a PR

### Feedback received

| Date | From | Type | Description | Status |
|------|------|------|-------------|--------|
| — | — | — | — | — |

---

## Adoption Roadmap

### Q 2026 (current)
- [ ] Kit v1 published
- [ ] Infra + EKS team onboarded (→ team-b + team-a)
- [ ] Three-level restructuring completed
- [ ] Team-a onboarding
- [ ] Team-e onboarding
- [ ] Team-d onboarding
- [ ] First compliance scorecard run

### Q 2026
- [ ] 100% teams onboarded
- [ ] Automated metrics (if possible via hook/log)
- [ ] First quarterly governance review
- [ ] Confluence dashboard integration

### Q 2026
- [ ] Kit v2 based on feedback
- [ ] Custom skills for emerging teams
- [ ] Governance score as team KPI

---

## How to Update This File

1. After each onboarding, update the "Status per Team" table
2. Monthly, collect feedback and update "Skills Usage"
3. Quarterly, full review with all owners

**Owner of this file:** Your Name
