#!/usr/bin/env bash
# Governance Heartbeat — chiamato dall'hook SessionStart
# Raccoglie inventory locale e invia al gateway
set +e

ENV_FILE="$HOME/.kiro/governance-env.sh"
[ ! -f "$ENV_FILE" ] && exit 0
source "$ENV_FILE"
[ -z "$KIRO_GOV_ENDPOINT" ] && exit 0

# Version
VER=$(python3 -c "import json; print(json.load(open('$HOME/.kiro/governance-version.json')).get('version','unknown'))" 2>/dev/null || echo "unknown")

# ai-usage-collect check
AIU="false"
[ -x "$HOME/.local/bin/ai-usage-collect" ] && AIU="true"

# Skills (basename without .md)
SKILLS=""
if ls "$HOME/.kiro/skills/"*.md >/dev/null 2>&1; then
  SKILLS=$(cd "$HOME/.kiro/skills" && ls *.md 2>/dev/null | sed 's/\.md$//' | tr '\n' ',' | sed 's/,$//')
fi

# Hooks (basename)
HOOKS=""
for ext in json kiro.hook; do
  if ls "$HOME/.kiro/hooks/"*.$ext >/dev/null 2>&1; then
    HOOKS="${HOOKS}$(cd "$HOME/.kiro/hooks" && ls *.$ext 2>/dev/null | tr '\n' ',' | sed 's/,$//'),"
  fi
done
HOOKS=$(echo "$HOOKS" | sed 's/,$//')

# Steering (basename without .md)
STEERING=""
if ls "$HOME/.kiro/steering/"*.md >/dev/null 2>&1; then
  STEERING=$(cd "$HOME/.kiro/steering" && ls *.md 2>/dev/null | sed 's/\.md$//' | tr '\n' ',' | sed 's/,$//')
fi

# MCP servers
MCP=""
if [ -f "$HOME/.kiro/settings/mcp.json" ]; then
  MCP=$(python3 -c "import json; print(','.join(json.load(open('$HOME/.kiro/settings/mcp.json')).get('mcpServers',{}).keys()))" 2>/dev/null || echo "")
fi

# Send heartbeat
curl -sf -m 5 -X POST "${KIRO_GOV_ENDPOINT}/v1/heartbeat" \
  -H "Content-Type: application/json" \
  -d "{\"machine_id\":\"${KIRO_GOV_MACHINE_ID}\",\"team\":\"${KIRO_GOV_TEAM}\",\"version\":\"${VER}\",\"ai_usage_collect\":${AIU},\"active_skills\":\"${SKILLS}\",\"active_hooks\":\"${HOOKS}\",\"active_steering\":\"${STEERING}\",\"mcp_servers\":\"${MCP}\"}" 2>/dev/null || echo "{\"status\":\"offline\"}"

exit 0
