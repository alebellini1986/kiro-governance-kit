# Integration Patterns — Kiro in the Workflow

How Kiro fits into the team's existing processes.

## Pattern 1: Jira → Kiro → Implementation

```
PM creates ticket → Dev analyzes with Kiro (MCP Atlassian) → Spec workflow → Implementation
```

**Typical prompt**: "Analyze ticket PROJ-123 and propose an implementation plan"

## Pattern 2: Development → PR → Review

```
Dev develops (steering active) → Hook generates PR description → PR → Review
```

**Hook**: `pr-description.json`, `quality-check.json`

## Pattern 3: Production Troubleshooting

```
Alert → #troubleshooting → Log analysis (MCP AWS/kubectl) → Root cause → Fix
```

**Typical prompt**: "Pod X is in CrashLoopBackOff. Analyze the logs."

## Pattern 4: Continuous Documentation

```
Code change → Hook suggests docs → Kiro generates/updates → Verify
```

**Hook**: `document-new-file.json`

## Pattern 5: New Member Onboarding

```
ONBOARDING.md → Copy workspace template → Configure MCP → Cheat sheet → First task
```

**Time**: 30-60 minutes

## Pattern 6: Spec-Driven Development

```
Describe feature → Requirements → Design → Tasks → Implementation → Test (hook)
```

**When**: Medium-large new features, refactoring, structured POCs

## Pattern 7: GitOps / ArgoCD

```
Modify manifests → Hook helm-lint → Steering gitops.md → PR → ArgoCD sync
```

**Steering**: `gitops.md`, `eks.md`, `safety.md`

## Pattern 8: UX Research → Design → Code

```
Clarity/Contentsquare (behavioral data) → Typeform (survey) → #ux-research-analysis
→ Miro (workshop/synthesis) → Figma (design) → #design-handoff → Implementation → #ux-review
```

**MCP**: `figma`, `miro`, `clarity`, `typeform`
**Skills**: `#ux-research-analysis`, `#design-handoff`, `#ux-review`, `#survey-design`
**Hook**: `a11y-check.json` (auto on UI files)

## Situation → Pattern Matrix

| Situation | Pattern |
|-----------|--------|
| New ticket | 1 + 2 |
| Production bug | 3 |
| Complex feature | 6 + 2 |
| Infrastructure update | 7 |
| Docs to update | 4 |
| New member | 5 |
| UX research + design | 8 |
| Design-to-code handoff | 8 + 2 |
