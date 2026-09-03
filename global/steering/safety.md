---
inclusion: always
name: safety
description: >
  Resource deletion safety guardrails. Prevents destructive operations without explicit user approval.
  Always active to protect production resources.
---

# Resource Deletion Safety

## Deletion Operations Requiring Approval

- NEVER execute kubectl delete without explicit user confirmation
- NEVER execute terraform destroy without explicit user confirmation
- NEVER delete ArgoCD Applications/AppProjects without confirmation
- NEVER delete Kubernetes namespaces, PVs, PVCs without confirmation
- NEVER delete AWS resources (S3, RDS, IAM, etc.) without confirmation
- NEVER delete KRO ResourceGraphDefinitions or infrastructure CRs without confirmation

## Required Approval Process

1. STOP and explain what will be deleted + impact
2. Ask: "Delete [resource]? This will [consequences]. Confirm: yes/no"
3. WAIT for explicit "yes"
4. Only proceed after confirmation

## Safe Operations (No Approval Needed)

- Read-only: kubectl get/describe, terraform show/state show
- Creating new resources
- Updating existing resources
- Viewing logs
- Listing resources

## Before Suggesting Deletion

- ALWAYS consider non-destructive alternatives first
- Suggest update over delete+recreate
- Explain why deletion might not be necessary
