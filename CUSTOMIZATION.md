# Customization Guide

## Philosophy

The kit provides a governance **foundation**. Each team customizes by adding vertical rules without modifying the base structure. This allows:
- Central updates without conflicts
- Isolated team-specific rules
- Fast onboarding of new members

---

## 1. Customizing Steering Files

### Adding rules to existing files

Every steering file has a standard structure. To add team-specific rules, append at the end of the file:

```markdown
## Team-Specific Rules

### {Team Name}
- Rule 1
- Rule 2
```

### Creating new steering files

For contexts specific to your team, create new files in `.kiro/steering/`:

```markdown
---
inclusion: fileMatch
fileMatchPattern: "**/*pattern*"
name: my-context
description: >
  Brief description of what this steering covers.
---

# Title

## Instructions
- Rule 1
- Rule 2
```

**Available inclusion types:**

| Front-matter | Effect |
|-------------|--------|
| `inclusion: auto` | Always active (no pattern needed) |
| `inclusion: fileMatch` + `fileMatchPattern: "..."` | Active when matching files are open |
| `inclusion: manual` | Only when invoked with `#name` in chat |

### Examples for different teams

**Data Engineering Team:**
```markdown
---
inclusion: fileMatch
fileMatchPattern: "**/*glue*,**/*spark*,**/*etl*,**/*.py"
name: data-engineering
---

# Data Engineering Standards

- Glue jobs: PySpark, output Parquet partitioned
- Naming: {project}_{job}_{env}
- Error handling: explicit try/except, log to CloudWatch
- Data quality: validate schema before write
- Partitioning: by date (year/month/day) for time-series
```

**Frontend Team:**
```markdown
---
inclusion: fileMatch
fileMatchPattern: "**/*.tsx,**/*.ts,**/next*,**/react*"
name: frontend
---

# Frontend Standards

- Framework: Next.js / React
- Styling: Tailwind CSS
- State: React Query for server state, Zustand for client
- Testing: Vitest + Testing Library
- Accessibility: WCAG 2.1 AA minimum
```

**Networking Team:**
```markdown
---
inclusion: manual
name: network-architecture
---

# Network Architecture Reference

- Transit Gateway: tgw-{region}-{purpose}
- CIDR allocation: 10.{account-octet}.0.0/16
- VPN: site-to-site to on-premise DC
- DNS: Route53 PHZ per account, shared resolver rules
```

---

## 2. Customizing Skills

### Skill structure

```markdown
---
name: skill-name
description: >
  Brief description. Appears in the menu when you type # in chat.
---

# Skill Title

## When to Use
- When to invoke this skill

## Process / Checklist
- Steps or checks to perform

## Output Format
- How to format the result

## Customization Points
<!-- Add your team-specific rules here -->
```

### Creating team-specific skills

**Example: Data Classification (Data/Compliance team)**
```markdown
---
name: data-classification
description: >
  Classify data by sensitivity level and determine required controls.
---

# Data Classification

## Levels

| Level | Description | Controls |
|-------|-------------|----------|
| Public | Public data | None specific |
| Internal | Internal use | Encryption at rest |
| Confidential | Sensitive data | Encryption + access logging + RBAC |
| Restricted | PII/financial | All above + audit trail + DLP |

## Checklist for new dataset
- [ ] Classification level assigned
- [ ] Data owner identified
- [ ] Retention policy defined
- [ ] Encryption configured per level
- [ ] Access control implemented
```

**Example: Capacity Planning (Platform team)**
```markdown
---
name: capacity-planning
description: >
  Capacity analysis for EKS clusters and AWS resources. Sizing and scaling recommendations.
---

# Capacity Planning

## Metrics to Collect
- CPU/Memory utilization (p50, p95, p99) over last 30 days
- Pod count trend
- Node count and bin-packing efficiency
- Storage growth rate

## Sizing Formula
- Target CPU: 60-70% average (headroom for spikes)
- Target Memory: 70-80% average
- Scale trigger: >80% sustained 5 min
- Buffer: +30% for peak season (Black Friday, sales)
```

---

## 3. Organization by Team

### Recommended structure

```
.kiro/
├── steering/
│   ├── [files from base kit]            ← Shared foundation
│   ├── context-{project}.md             ← Project-specific context
│   └── {team}-standards.md              ← Team-specific standards
│
└── skills/                               ← User-level only (~/.kiro/skills/)
    ├── [skills from base kit]            ← Governance foundation
    └── {team}-{skill}.md                ← Team vertical skills
```

### Team → recommended skills matrix

| Team | Base Skills | Suggested Additional Skills |
|------|-------------|----------------------------|
| Platform/SRE | All | capacity-planning, runbook-generator |
| Security | gov-iam, gov-security, gov-network | penetration-checklist, compliance-report |
| Data | gov-tagging, gov-cost | data-classification, pipeline-review |
| DevOps | gov-change, gov-ops | deployment-checklist, rollback-plan |
| Frontend | gov-change, pr-description | accessibility-review, performance-budget |
| Backend | gov-change, gov-security | api-review, database-migration |

---

## 4. Updates and Versioning

### Recommended strategy

1. **Base kit** in a dedicated Git repo (e.g. `kiro-governance-kit`)
2. **Versioning** with semver tags (v1.0.0, v1.1.0, ...)
3. **Changelog** for each release
4. **Pull request** for changes to the base kit
5. **Team extensions** in separate repos or branches

### Updating the kit

```bash
# Pull the latest kit version
cd kiro-governance-kit
git pull origin main

# Copy updates (preserves local customizations)
rsync -av --ignore-existing steering/ ~/.kiro/steering/
rsync -av --ignore-existing skills/ ~/.kiro/skills/
```

### Conflicts

If you modified a base file:
- Your changes in the `## Customization Points` section are safe
- Changes to the main body may conflict → manual merge

---

## 5. Best Practices

1. **Don't modify the body of base files** — only use `## Customization Points`
2. **One file per context** — don't mix different domains
3. **Specific fileMatch** — patterns that are too broad activate unnecessary steering (token waste)
4. **Manual for reference** — long documents are better as manual (they don't consume tokens unless invoked)
5. **Prefixed names** — `gov-*` for governance, `context-*` for context, `{team}-*` for team
6. **Clear descriptions** — they appear in the `#` menu, must be immediately understandable
7. **Iterate** — start minimal, add rules when you find real gaps (not speculative ones)
