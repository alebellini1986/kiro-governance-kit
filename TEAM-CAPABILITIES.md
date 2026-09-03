# Team Capabilities Map

Complete map of all Kiro configurations (steering, skills, hooks, MCP config) assigned to each team or the global level.

---

## Global

Configurations applied to **all** teams. Installed in the first phase of the install script.

### Steering

| File | Inclusion | Description |
|------|-----------|-------------|
| `global/steering/safety.md` | auto | Deletion safety — blocks destructive operations |
| `global/steering/aws-conventions.md` | auto | Naming, tagging, account structure AWS |
| `global/steering/code-standards.md` | auto | Code conventions Python, commits |

### Skills

| File | Invocation | Description |
|------|------------|-------------|
| `global/skills/gov-iam-access.md` | `#gov-iam-access` | Review IAM policies/roles |
| `global/skills/gov-security-compliance.md` | `#gov-security-compliance` | Security audit |
| `global/skills/gov-compliance-scorecard.md` | `#gov-compliance-scorecard` | Compliance scorecard per account |
| `global/skills/gov-tagging-naming.md` | `#gov-tagging-naming` | Check tags and naming |
| `global/skills/gov-operational-excellence.md` | `#gov-operational-excellence` | Production readiness |
| `global/skills/gov-change-management.md` | `#gov-change-management` | PR gates, deploy review |
| `global/skills/team-onboarding-check.md` | `#team-onboarding-check` | Verify team onboarding |

### Hooks

| File | Trigger | Description |
|------|---------|-------------|
| `global/hooks/shell-safety.json` | preToolUse | Shell command safety check |
| `global/hooks/review-write-ops.json` | preToolUse | Review write operations |
| `global/hooks/document-new-file.json` | fileCreated | New file documentation |
| `global/hooks/skill-suggester.json` | promptSubmit | Contextual skill suggestion |

### MCP Config

| File | Description |
|------|-------------|
| `global/mcp-config/mcp.json` | Base MCP server template (AWS, GitHub, Atlassian) |

---

## Shared Capabilities (`teams/_shared/`)

Configurations shared between all teams. Referenced during team installation.

### Steering

| File | Inclusion | Description |
|------|-----------|-------------|
| `teams/_shared/steering/github.md` | manual | GitHub PR/branch conventions |
| `teams/_shared/steering/jira.md` | manual | Jira workflow |
| `teams/_shared/steering/troubleshooting.md` | manual | Debug methodology |
| `teams/_shared/steering/cross-team.md` | auto | Cross-team knowledge base |
| `teams/_shared/steering/ponytail.md` | always | Ponytail lazy senior dev mode — minimal code, maximum efficiency |

### Skills

| File | Invocation | Description |
|------|------------|-------------|
| `teams/_shared/skills/pr-description.md` | `#pr-description` | Generate PR description |
| `teams/_shared/skills/systematic-debugging.md` | `#systematic-debugging` | Methodical debugging |
| `teams/_shared/skills/brainstorming.md` | `#brainstorming` | Structured brainstorming |
| `teams/_shared/skills/executing-plans.md` | `#executing-plans` | Executing implementation plans |
| `teams/_shared/skills/finishing-branch.md` | `#finishing-branch` | Branch/PR completion |
| `teams/_shared/skills/writing-plans.md` | `#writing-plans` | Writing implementation plans |
| `teams/_shared/skills/verification-before-completion.md` | `#verification-before-completion` | Pre-completion verification |

### Hooks

| File | Trigger | Description |
|------|---------|-------------|
| `teams/_shared/hooks/quality-check.json` | promptSubmit | Quality check on prompt |
| `teams/_shared/hooks/pr-description.json` | agentStop | Automatic PR description |

---

## Team: team-a

**Owner:** Team Lead A
**Domain:** Application Development — general software development, testing, code review

### Steering

| File | Inclusion | Description |
|------|-----------|-------------|
| `teams/team-a/steering/coding-standards.md` | fileMatch | Language coding standards |
| `teams/team-a/steering/testing-strategy.md` | auto | Testing strategy |
| `teams/team-a/steering/api-design.md` | auto | API design patterns |

### Skills

| File | Invocation | Description |
|------|------------|-------------|
| `teams/team-a/skills/code-review.md` | `#code-review` | Structured code review |
| `teams/team-a/skills/test-generator.md` | `#test-generator` | Test generation |
| `teams/team-a/skills/subagent-development.md` | `#subagent-development` | Development with sub-agent |

### Hooks

| File | Trigger | Description |
|------|---------|-------------|
| `teams/team-a/hooks/lint-on-save.json` | fileEdited | Lint on save |
| `teams/team-a/hooks/test-after-task.json` | postTaskExecution | Test after task completion |
| `teams/team-a/hooks/pr-description.json` | agentStop | PR description |

### MCP Config

| File | Description |
|------|-------------|
| `teams/team-a/mcp-config/README.md` | Placeholder (team-specific MCP config) |

---

## Team: team-b

**Owner:** Team Lead B
**Domain:** Infrastructure — IaC, cloud provisioning, networking

### Steering

| File | Inclusion | Description |
|------|-----------|-------------|
| `teams/team-b/steering/iac-standards.md` | fileMatch | IaC standards |
| `teams/team-b/steering/provisioning.md` | auto | Cloud provisioning conventions |
| `teams/team-b/steering/networking.md` | auto | Networking design |

### Skills

| File | Invocation | Description |
|------|------------|-------------|
| `teams/team-b/skills/infra-review.md` | `#infra-review` | Infrastructure review |
| `teams/team-b/skills/gov-network.md` | `#gov-network` | Review network resources |

### Hooks

| File | Trigger | Description |
|------|---------|-------------|
| `teams/team-b/hooks/iac-fmt.json` | fileEdited | IaC format |
| `teams/team-b/hooks/iac-validate.json` | fileEdited | IaC validate |
| `teams/team-b/hooks/shell-safety.json` | preToolUse | Shell safety (default owner) |
| `teams/team-b/hooks/drift-detection.json` | userTriggered | Infrastructure drift detection |
| `teams/team-b/hooks/policy-validation.json` | fileEdited | Policy validation on IaC files |

### MCP Config

| File | Description |
|------|-------------|
| `teams/team-b/mcp-config/` | Empty (team-specific MCP config) |

---

## Team: team-c

**Owner:** Team Lead C
**Domain:** Cost & FinOps — cost optimization, budgets

### Steering

| File | Inclusion | Description |
|------|-----------|-------------|
| `teams/team-c/steering/cost-governance.md` | auto | Cost governance policies |
| `teams/team-c/steering/budgets.md` | manual | Budget practices |

### Skills

| File | Invocation | Description |
|------|------------|-------------|
| `teams/team-c/skills/cost-estimate.md` | `#cost-estimate` | Infrastructure cost estimation |
| `teams/team-c/skills/gov-cost-finops.md` | `#gov-cost-finops` | Cost/FinOps governance |

### Hooks

_No team-specific hooks._

### MCP Config

| File | Description |
|------|-------------|
| `teams/team-c/mcp-config/` | Empty (team-specific MCP config) |

---

## Team: team-d

**Owner:** Team Lead D
**Domain:** Integration — API integration, data pipelines

### Steering

| File | Inclusion | Description |
|------|-----------|-------------|
| `teams/team-d/steering/api-lifecycle.md` | auto | API lifecycle management |
| `teams/team-d/steering/data-pipeline-standards.md` | fileMatch | Data pipeline standards |
| `teams/team-d/steering/error-handling.md` | auto | Error handling patterns |

### Skills

| File | Invocation | Description |
|------|------------|-------------|
| `teams/team-d/skills/integration-review.md` | `#integration-review` | Integration flow review |

### Hooks

_No team-specific hooks._

### MCP Config

| File | Description |
|------|-------------|
| `teams/team-d/mcp-config/README.md` | Placeholder (team-specific MCP config) |

---

## Team: team-e

**Owner:** Team Lead E
**Domain:** Support & Operations — incident response, ticketing, monitoring

### Steering

| File | Inclusion | Description |
|------|-----------|-------------|
| `teams/team-e/steering/support-workflow.md` | auto | Support workflow |
| `teams/team-e/steering/monitoring.md` | auto | Monitoring conventions |
| `teams/team-e/steering/incident-response.md` | auto | Incident response procedures |
| `teams/team-e/steering/incident-postmortem.md` | auto | Incident post-mortem template |

### Skills

| File | Invocation | Description |
|------|------------|-------------|
| `teams/team-e/skills/incident-analysis.md` | `#incident-analysis` | Incident analysis |
| `teams/team-e/skills/api-doc-generator.md` | `#api-doc-generator` | API documentation generator |
| `teams/team-e/skills/ticket-summary.md` | `#ticket-summary` | Ticket summary |

### Hooks

| File | Trigger | Description |
|------|---------|-------------|
| `teams/team-e/hooks/quality-check.json` | promptSubmit | Quality check |

### MCP Config

| File | Description |
|------|-------------|
| `teams/team-e/mcp-config/README.md` | Placeholder (team-specific MCP config) |


