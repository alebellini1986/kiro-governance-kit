# AI Usage Collect

Lightweight telemetry module for tracking Kiro IDE usage across teams. Captures session metadata (category, credits, tools, cost allocation tags) and sends it to a centralized API for analytics.

## How It Works

```
Kiro session ends
    │
    ▼
classify-hook.json (Stop trigger)
    → Agent analyzes session
    → Determines category, credits, tags
    │
    ▼
ai-usage-collect (CLI)
    → Validates tags against allowed_tags.json
    → Builds event JSON
    → POSTs to API endpoint (fire-and-forget)
    │
    ▼
API Gateway → Lambda → S3
    → Glue Crawler → Athena (analytics)
```

## Components

```
ai-usage-collect/
├── client/
│   ├── bin/
│   │   └── ai-usage-collect       ← CLI collector script (zsh)
│   ├── hooks/
│   │   ├── classify-hook.json     ← Kiro hook (Stop): classifies session
│   │   └── snapshot-hook.json     ← Kiro hook (UserPromptSubmit): token snapshot
│   ├── allowed_tags.json          ← Tag validation (customize per org)
│   ├── install.sh                 ← Interactive installer
│   └── tests/
│       └── test_collector.bats    ← Unit tests (bats)
│
├── terraform/
│   ├── main.tf                    ← API Gateway + Lambda + S3 + Glue + Athena
│   └── lambda/
│       └── handler.py             ← Ingestion Lambda
│
├── docs/
│   └── setup.md                   ← Detailed setup guide
│
└── README.md                      ← This file
```

## Quick Start

### 1. Deploy Infrastructure (admin, one-time)

```bash
cd terraform/
terraform init
terraform plan -var="account_id=YOUR_ACCOUNT" -var="api_key_value=YOUR_KEY"
terraform apply
```

Outputs: `api_endpoint` and `api_key_value`.

### 2. Install Client (each developer)

```bash
cd client/
./install.sh
```

The installer prompts for:
- Team name
- API endpoint (from terraform output)
- API key

Or, if using the [Governance Orchestrator](../README.md#governance-orchestrator-optional), the client is auto-installed via `governance-sync`.

### 3. Verify

```bash
which ai-usage-collect              # should return ~/.local/bin/ai-usage-collect
cat ~/.ai-usage/config.env          # team, endpoint, key
ls ~/.kiro/hooks/classify-hook.json # hook present
```

## Cost Allocation Tags

The collector supports up to 6 customizable cost allocation tags. These are generic labels you define per your organization's FinOps strategy.

### CLI Flags

| Flag | JSON Field | Purpose |
|------|-----------|---------|
| `--cost-tag-1` | `tag_cost_allocated_1` | First allocation dimension (e.g., project) |
| `--cost-tag-2` | `tag_cost_allocated_2` | Second dimension (e.g., application) |
| `--cost-tag-3` | `tag_cost_allocated_3` | Third dimension (e.g., business unit) |
| `--cost-tag-4` | `tag_cost_allocated_4` | Fourth dimension (e.g., cost center) |
| `--cost-tag-5` | `tag_cost_allocated_5` | Fifth dimension (e.g., environment) |
| `--cost-tag-6` | `tag_cost_allocated_6` | Sixth dimension (e.g., owner/team) |

### Validation

Tags are validated against `~/.ai-usage/allowed_tags.json`:

```json
{
  "CostAllocated1": ["ProjectA", "ProjectB", "Infrastructure"],
  "CostAllocated2": ["Kiro", "CursorAI", "Copilot"],
  "CostAllocated3": ["Engineering", "Design", "Operations"],
  "CostAllocated4": ["CC-001", "CC-002"],
  "CostAllocated5": ["Prod", "Dev", "Staging"],
  "CostAllocated6": ["TeamAlpha", "TeamBeta"]
}
```

If a tag value is not in the allowed list, the event is silently dropped (never blocks the user).

## Event Schema

Each event sent to the API:

```json
{
  "event_id": "uuid",
  "timestamp": "2026-08-25T10:00:00Z",
  "user": "username",
  "team": "dev",
  "category": "feature",
  "session_credits": 0.45,
  "auto_tags": "terraform,lambda,api-gateway",
  "skills_activated": "gov-security-compliance",
  "steering_loaded": "safety,terraform",
  "mcp_servers_used": "aws-core,github",
  "tool_calls": 42,
  "tag_cost_allocated_1": "AI",
  "tag_cost_allocated_2": "Kiro",
  "tag_cost_allocated_3": "Engineering",
  "tag_cost_allocated_4": "CC-001",
  "tag_cost_allocated_5": "Prod",
  "tag_cost_allocated_6": "Architecture"
}
```

## Hooks

### classify-hook.json (trigger: Stop)

Runs when a Kiro session ends. The agent analyzes the completed session and invokes `ai-usage-collect` with inferred metadata:
- Category (debug, feature, review, ops, learning, refactor, security, incident)
- Session credits
- Cost allocation tags (inferred from context, validated against allowed values)
- Auto-tags, skills used, steering loaded, MCP servers, tool call count

### snapshot-hook.json (trigger: UserPromptSubmit)

Captures token line count before each prompt for delta calculation. Stored locally in `~/.ai-usage/.snapshot`.

## Configuration

### ~/.ai-usage/config.env

```bash
TEAM="your-team"
API_ENDPOINT="https://YOUR_API_GATEWAY/prod/usage"
API_KEY="your-api-key"
```

### ~/.ai-usage/allowed_tags.json

Define allowed values for each cost allocation dimension. Events with invalid tag values are silently dropped.

## Analytics (Athena)

Pre-built queries available after Glue Crawler runs:

```sql
-- Usage by team
SELECT team, COUNT(*) as sessions, SUM(session_credits) as total_credits
FROM usage_events GROUP BY team ORDER BY total_credits DESC;

-- Usage by category
SELECT category, COUNT(*) as sessions
FROM usage_events GROUP BY category ORDER BY sessions DESC;

-- Daily trends
SELECT DATE(timestamp) as day, COUNT(*) as sessions, SUM(session_credits) as credits
FROM usage_events GROUP BY DATE(timestamp) ORDER BY day DESC LIMIT 30;

-- Cost allocation report
SELECT tag_cost_allocated_1, tag_cost_allocated_4, SUM(session_credits) as credits
FROM usage_events GROUP BY tag_cost_allocated_1, tag_cost_allocated_4;
```

## Privacy

- No code or chat content is collected — only session metadata
- User identified by OS username (configurable)
- Events are fire-and-forget — never block the user's workflow
- All errors exit silently (exit 0)
- Opt-out: remove `~/.ai-usage/config.env` or delete the classify hook

## Integration with Governance Orchestrator

When the [Kiro Governance Orchestrator](https://github.com/your-org/kiro-governance-orchestrator) is deployed, ai-usage-collect is automatically:
- Included in team bundles (via buildspec)
- Installed by `governance-sync`
- Config auto-generated on first sync
- Tracked via heartbeat (`ai_usage_active: true/false` in DynamoDB)
