# AI Usage Collect - Setup Guide

## Prerequisites

- AWS CLI configured with access to the your-aws-profile account
- Terraform >= 1.5.0
- zsh (macOS default)
- python3, curl, uuidgen

## 1. Deploy Infrastructure

```bash
cd ai-usage-collect/terraform/
terraform init
terraform plan -var="account_id=ACCOUNT_ID" -var="api_key_value=YOUR_API_KEY"
terraform apply -var="account_id=ACCOUNT_ID" -var="api_key_value=YOUR_API_KEY"
```

Note the outputs:
- `api_endpoint` — the POST URL for usage events
- `api_key_value` — the API key (sensitive, use `terraform output -raw api_key_value`)

## 2. Install Client

```bash
cd ai-usage-collect/client/
./install.sh
```

The installer will prompt for:
- **Team name**: your team identifier (e.g. `team-a`)
- **API endpoint**: from terraform output
- **API key**: from terraform output

## 3. Verify Installation

```bash
which ai-usage-collect
cat ~/.ai-usage/config.env
cat ~/.ai-usage/allowed_tags.json
ls ~/.kiro/hooks/
```

## 4. Architecture

```
[Kiro IDE] → snapshot hook (promptSubmit) → saves line count
           → classify hook (agentStop) → classifies + calls collector
           → collector script → validates tags → POST /usage → API GW → Lambda → S3
           → Glue Crawler → Data Catalog → Athena queries
```

## 5. Tag Validation

The client validates governance tags against `~/.ai-usage/allowed_tags.json`.
If a tag value is not in the allowed list, the event is silently dropped.
Update `client/allowed_tags.json` and re-run install to update allowed values.
