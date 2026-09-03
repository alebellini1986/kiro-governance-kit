---
inclusion: manual
name: jira
description: >
  Jira workflow conventions. Issue management, sprint practices, and integration
  with development workflow.
---

# Jira Workflow

## Issue Types

- Epic: large feature spanning multiple sprints
- Story: user-facing functionality
- Task: technical work not directly user-facing
- Bug: defect in existing functionality
- Sub-task: breakdown of story/task

## Issue Lifecycle

- To Do → In Progress → In Review → Done
- Move to In Progress when starting work
- Move to In Review when PR created
- Move to Done when PR merged + deployed

## Conventions

- Summary: clear, actionable, under 80 chars
- Description: context, acceptance criteria, technical notes
- Labels: use for cross-cutting concerns (security, performance, tech-debt)
- Components: use for system areas (frontend, backend, infra, platform)
- Story points: relative effort estimation

## Sprint Practices

- Sprint duration: 2 weeks
- Refinement before sprint planning
- Daily standup: blockers first
- Sprint review: demo working software
- Retro: actionable improvements

## Integration with Git

- Branch name includes ticket ID: `feature/PROJ-123-description`
- Commit messages reference ticket: `feat(auth): PROJ-123 add SSO login`
- PR title includes ticket: `[PROJ-123] Add SSO login flow`
- Auto-transition on PR merge (if configured)

## Atlassian Instance

- URL: https://YOUR_ATLASSIAN_SITE
- Use MCP atlassian tools for queries and updates
