---
inclusion: manual
name: github
description: >
  GitHub workflow conventions. PR standards, branch strategy, code review practices,
  and repository management patterns.
---

# GitHub Workflow

## Branch Strategy

- Main/master: protected, no direct push
- Feature branches: `feature/{ticket-id}-{short-description}`
- Bugfix branches: `fix/{ticket-id}-{short-description}`
- Hotfix branches: `hotfix/{ticket-id}-{short-description}`
- Always branch from latest main

## Pull Request Standards

- Title: concise, under 70 chars, reference ticket ID
- Description structure:
  - Summary of changes
  - What was tested
  - Breaking changes (if any)
  - Related tickets/PRs
- Keep PRs focused — one logical change per PR
- Draft PRs for work-in-progress

## Code Review Practices

- Review within 24h
- Focus on: logic correctness, security, performance, maintainability
- Approve with comments for minor suggestions
- Request changes for blocking issues
- Use suggestions for small fixes

## Repository Hygiene

- Delete branches after merge
- Keep CI green on main
- Tag releases with semver
- Protect main branch: require reviews + passing CI

## Commit Messages

- Format: `type(scope): description`
- Types: feat, fix, docs, style, refactor, test, chore
- Keep first line under 72 chars
- Reference ticket in body if applicable
