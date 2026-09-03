---
inclusion: manual
name: troubleshooting
description: >
  Systematic troubleshooting methodology for AWS, EKS, Terraform, Kro, and platform issues.
  Covers investigation-first approach, Kro RGD debugging, and ACK resource chains.
---

# Troubleshooting Methodology

## General Approach

1. VERIFY problem actually exists before starting
2. Search documentation with 3-4 query variations (EKS troubleshooting guide, AWS docs)
3. If inconclusive → refine queries based on findings
4. Investigate before fixing — understand root cause first

## YAML Validation

- After modifying YAML: `yq eval '.' <file> > /dev/null`
- For K8s manifests: `kubectl apply --dry-run=client -f <file>`

## Infrastructure Priority

- Use `terraform state list` → `terraform state show <resource>` before AWS CLI
- For networking (LB, Ingress): examine terraform config files first
- Missing/misconfigured resources → update Terraform, use deployment scripts (not manual creation)

## EKS-Specific

- Check AutoMode status with `describe-cluster` before assuming missing controllers
- After subnet tag changes → recreate LoadBalancer services
- Wait 150s after LB shows "active" before testing connectivity (DNS propagation)

## Kro ResourceGraphDefinition Debugging

### Systematic Steps

1. Check instance status: `kubectl get <kind> <name> -n <ns> -o jsonpath='{.status.conditions[?(@.type=="Ready")].message}'`
2. Get topological order: `kubectl get rgd <name> -o jsonpath='{.status.topologicalOrder}'`
3. Check each ACK resource in topological order
4. Look for: AccessDenied (trust policy), EntityAlreadyExists (previous deployment), Terminal conditions

### ACK Common Issues

- `sts:TagSession` AccessDenied → trust policy missing EKS Capability role
- `EntityAlreadyExists` → delete AWS resource first, then K8s resource
- `Resource not managed by ACK` → delete or adopt

### Force Reconciliation

```bash
kubectl annotate <kind> <name> -n <ns> kro.run/reconcile="$(date +%s)" --overwrite
```

## MCP Fallbacks

- EKS MCP fails → use kubectl/AWS CLI equivalents
- Terraform MCP fails → use state commands for inspection only
- ALWAYS explain why fallback is necessary
