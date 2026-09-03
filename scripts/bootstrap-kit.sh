#!/usr/bin/env bash
# ============================================================================
# Kiro Governance Kit — Bootstrap Wizard
# ============================================================================
# Run this ONCE when setting up the kit for your organization.
# Creates teams/ structure, populates kit.json manifest, and generates
# a customized install.sh tailored to your team roster.
#
# Usage:
#   ./scripts/bootstrap-kit.sh
#
# Output:
#   kit.json              — team manifest (source of truth)
#   teams/<name>/         — folder structure per team
#   scripts/install.sh    — updated with your teams
# ============================================================================

set -euo pipefail

# ─── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
KIT_JSON="$REPO_ROOT/kit.json"

# ─── Header ─────────────────────────────────────────────────────────────────
clear 2>/dev/null || true
echo ""
echo -e "${BOLD}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║       Kiro Governance Kit — Bootstrap Wizard              ║${NC}"
echo -e "${BOLD}║   Configure teams, domains, and install preferences       ║${NC}"
echo -e "${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# ─── Organization Info ───────────────────────────────────────────────────────
echo -e "${BLUE}[1/4]${NC} ${BOLD}Organization Info${NC}"
echo ""

echo -n "  Organization name: "
read ORG_NAME
ORG_NAME="${ORG_NAME:-My Organization}"

echo -n "  GitHub org/user (for repo references): "
read GITHUB_ORG
GITHUB_ORG="${GITHUB_ORG:-my-org}"

echo -n "  Primary AWS region [us-east-1]: "
read AWS_REGION
AWS_REGION="${AWS_REGION:-us-east-1}"

echo -n "  Cost center tag [none]: "
read COST_CENTER
COST_CENTER="${COST_CENTER:-none}"

echo -n "  Governance admin email: "
read ADMIN_EMAIL
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@example.com}"

echo ""
echo -e "${GREEN}  ✓${NC} Organization: ${BOLD}$ORG_NAME${NC}"
echo ""

# ─── Team Definition ─────────────────────────────────────────────────────────
echo -e "${BLUE}[2/4]${NC} ${BOLD}Define Teams${NC}"
echo ""
echo -e "  Add teams one by one. Each team gets its own folder with steering,"
echo -e "  skills, and hooks. Type ${BOLD}done${NC} when finished."
echo ""

TEAMS=()
TEAM_DOMAINS=()
TEAM_OWNERS=()

COUNTER=1
while true; do
  echo -e "  ${CYAN}Team #${COUNTER}${NC}"
  echo -n "    Name (lowercase, dashes ok) [done to finish]: "
  read TEAM_NAME

  if [[ "$TEAM_NAME" == "done" || -z "$TEAM_NAME" ]]; then
    if [[ ${#TEAMS[@]} -eq 0 ]]; then
      echo -e "  ${RED}At least one team is required.${NC}"
      continue
    fi
    break
  fi

  # Sanitize
  TEAM_NAME=$(echo "$TEAM_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')

  echo -n "    Domain/description (e.g. 'TypeScript, Python, K8s'): "
  read TEAM_DOMAIN
  TEAM_DOMAIN="${TEAM_DOMAIN:-General development}"

  echo -n "    Owner name/email: "
  read TEAM_OWNER
  TEAM_OWNER="${TEAM_OWNER:-TBD}"

  TEAMS+=("$TEAM_NAME")
  TEAM_DOMAINS+=("$TEAM_DOMAIN")
  TEAM_OWNERS+=("$TEAM_OWNER")

  echo -e "  ${GREEN}  ✓${NC} Added: ${BOLD}$TEAM_NAME${NC} — $TEAM_DOMAIN (owner: $TEAM_OWNER)"
  echo ""
  ((COUNTER++))
done

echo ""
echo -e "${GREEN}  ✓${NC} ${#TEAMS[@]} teams defined"
echo ""

# ─── Orchestrator (optional) ─────────────────────────────────────────────────
echo -e "${BLUE}[3/4]${NC} ${BOLD}Governance Orchestrator (optional)${NC}"
echo ""
echo -e "  The Kiro Governance Orchestrator provides AWS-based distribution"
echo -e "  (S3 + API Gateway + Lambda) so team members don't need Git access."
echo -e "  It also adds telemetry, auto-update, and adoption dashboards."
echo ""
echo -n "  Enable orchestrator integration? [y/N]: "
read ENABLE_ORCH
ENABLE_ORCH="${ENABLE_ORCH:-n}"

ORCH_ENDPOINT=""
ORCH_BUCKET=""
if [[ "$ENABLE_ORCH" =~ ^[yY] ]]; then
  echo -n "    API Gateway endpoint [https://YOUR_API_GATEWAY_ENDPOINT]: "
  read ORCH_ENDPOINT
  ORCH_ENDPOINT="${ORCH_ENDPOINT:-https://YOUR_API_GATEWAY_ENDPOINT}"

  echo -n "    S3 artifact bucket [kiro-governance-artifacts]: "
  read ORCH_BUCKET
  ORCH_BUCKET="${ORCH_BUCKET:-kiro-governance-artifacts}"

  echo -e "  ${GREEN}  ✓${NC} Orchestrator enabled"
else
  echo -e "  ${DIM}  Skipped — you can enable later by re-running bootstrap${NC}"
fi
echo ""

# ─── Generate ────────────────────────────────────────────────────────────────
echo -e "${BLUE}[4/4]${NC} ${BOLD}Generating kit structure...${NC}"
echo ""

# ─── Write kit.json ──────────────────────────────────────────────────────────
python3 -c "
import json

teams = []
names = '''${TEAMS[*]}'''.split()
domains = '''$(IFS='|'; echo "${TEAM_DOMAINS[*]}")'''.split('|')
owners = '''$(IFS='|'; echo "${TEAM_OWNERS[*]}")'''.split('|')

for i, name in enumerate(names):
    teams.append({
        'name': name,
        'domain': domains[i].strip() if i < len(domains) else '',
        'owner': owners[i].strip() if i < len(owners) else 'TBD'
    })

kit = {
    'version': '1.0.0',
    'organization': '$ORG_NAME',
    'github_org': '$GITHUB_ORG',
    'aws_region': '$AWS_REGION',
    'cost_center': '$COST_CENTER',
    'admin_email': '$ADMIN_EMAIL',
    'teams': teams,
    'orchestrator': {
        'enabled': '${ENABLE_ORCH}'.lower().startswith('y'),
        'endpoint': '$ORCH_ENDPOINT',
        'bucket': '$ORCH_BUCKET'
    }
}

with open('$KIT_JSON', 'w') as f:
    json.dump(kit, f, indent=2)
print('  ✓ kit.json written')
"

# ─── Create team folders ─────────────────────────────────────────────────────
for team in "${TEAMS[@]}"; do
  TEAM_DIR="$REPO_ROOT/teams/$team"
  mkdir -p "$TEAM_DIR"/{steering,skills,hooks,mcp-config}

  # README per team
  if [[ ! -f "$TEAM_DIR/README.md" ]]; then
    IDX=-1
    for i in "${!TEAMS[@]}"; do
      if [[ "${TEAMS[$i]}" == "$team" ]]; then IDX=$i; break; fi
    done
    cat > "$TEAM_DIR/README.md" << EOF
# Team: $team

**Owner:** ${TEAM_OWNERS[$IDX]}
**Domain:** ${TEAM_DOMAINS[$IDX]}

## Steering
Add team-specific steering files here (\`.md\` with front-matter).

## Skills
Add team-specific skills here (\`.md\` with front-matter).

## Hooks
Add team-specific hooks here (\`.json\` in v1 format).
EOF
  fi

  echo -e "  ${GREEN}✓${NC} teams/$team/"
done

# ─── Create _shared if not exists ────────────────────────────────────────────
mkdir -p "$REPO_ROOT/teams/_shared"/{steering,skills,hooks}
echo -e "  ${GREEN}✓${NC} teams/_shared/"

# ─── Create global if not exists ─────────────────────────────────────────────
mkdir -p "$REPO_ROOT/global"/{steering,skills,hooks}
echo -e "  ${GREEN}✓${NC} global/"

# ─── Generate install.sh from kit.json ───────────────────────────────────────
# Only generate if no install.sh exists yet (preserve the full v3.0 installer)
if [[ -f "$REPO_ROOT/scripts/install.sh" ]]; then
  echo -e "  ${GREEN}✓${NC} scripts/install.sh already exists — preserved"
else
  cat > "$REPO_ROOT/scripts/install.sh" << 'INSTALLEOF'
#!/usr/bin/env bash
# ============================================================================
# Kiro Governance Kit — Installer (auto-generated from kit.json)
# ============================================================================
# Installs Global + Shared + Team configs to ~/.kiro/
# Hooks are installed as .kiro.hook files (Kiro's expected format).
# Usage:
#   ./scripts/install.sh --team <team-name>
#   ./scripts/install.sh --list
# ============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
KIT_JSON="$REPO_ROOT/kit.json"
KIRO_DIR="$HOME/.kiro"

TEAM=""
LIST_ONLY=false

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --team)  TEAM="$2"; shift 2 ;;
    --list)  LIST_ONLY=true; shift ;;
    -h|--help) echo "Usage: install.sh --team <name> | --list"; exit 0 ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

# Read kit.json
if [[ ! -f "$KIT_JSON" ]]; then
  echo -e "${RED}ERROR:${NC} kit.json not found. Run scripts/bootstrap-kit.sh first."
  exit 1
fi

# List teams
if [[ "$LIST_ONLY" == "true" ]]; then
  echo ""
  echo -e "${BOLD}Available teams:${NC}"
  python3 -c "
import json
kit = json.load(open('$KIT_JSON'))
for i, t in enumerate(kit['teams'], 1):
    print(f'  {i}) {t[\"name\"]:<25} — {t[\"domain\"]} (owner: {t[\"owner\"]})')
"
  echo ""
  exit 0
fi

# Validate team
if [[ -z "$TEAM" ]]; then
  echo -e "${RED}ERROR:${NC} --team required. Use --list to see available teams."
  exit 1
fi

TEAM_DIR="$REPO_ROOT/teams/$TEAM"
if [[ ! -d "$TEAM_DIR" ]]; then
  echo -e "${RED}ERROR:${NC} Team '$TEAM' not found in teams/. Use --list."
  exit 1
fi

# Copy hooks: .json files → .kiro.hook in destination
install_hooks() {
  local src="$1"
  local dest="$2"
  local label="$3"
  local count=0
  for f in "$src"/*.json; do
    [[ -f "$f" ]] || continue
    local name
    name=$(basename "${f%.json}")
    cp "$f" "$dest/${name}.kiro.hook"
    count=$((count + 1))
  done
  [[ $count -gt 0 ]] && echo -e "${GREEN}  ✓${NC} $label: $count hook(s)" || true
}

# Install
echo ""
echo -e "${BOLD}Kiro Governance Kit — Install${NC}"
echo -e "${DIM}Team: $TEAM${NC}"
echo ""

mkdir -p "$KIRO_DIR"/{steering,skills,hooks,settings}

# Global
echo -e "${BLUE}[1/3]${NC} Installing global..."
cp "$REPO_ROOT/global/steering/"*.md "$KIRO_DIR/steering/" 2>/dev/null && echo -e "${GREEN}  ✓${NC} steering" || true
cp "$REPO_ROOT/global/skills/"*.md "$KIRO_DIR/skills/" 2>/dev/null && echo -e "${GREEN}  ✓${NC} skills" || true
install_hooks "$REPO_ROOT/global/hooks" "$KIRO_DIR/hooks" "hooks"

# Shared
echo -e "${BLUE}[2/3]${NC} Installing shared..."
cp "$REPO_ROOT/teams/_shared/steering/"*.md "$KIRO_DIR/steering/" 2>/dev/null && echo -e "${GREEN}  ✓${NC} steering" || true
cp "$REPO_ROOT/teams/_shared/skills/"*.md "$KIRO_DIR/skills/" 2>/dev/null && echo -e "${GREEN}  ✓${NC} skills" || true
install_hooks "$REPO_ROOT/teams/_shared/hooks" "$KIRO_DIR/hooks" "hooks"

# Team
echo -e "${BLUE}[3/3]${NC} Installing team: $TEAM..."
cp "$TEAM_DIR/steering/"*.md "$KIRO_DIR/steering/" 2>/dev/null && echo -e "${GREEN}  ✓${NC} steering" || true
cp "$TEAM_DIR/skills/"*.md "$KIRO_DIR/skills/" 2>/dev/null && echo -e "${GREEN}  ✓${NC} skills" || true
install_hooks "$TEAM_DIR/hooks" "$KIRO_DIR/hooks" "hooks"

# Summary
S=$(ls "$KIRO_DIR/steering/"*.md 2>/dev/null | wc -l | tr -d ' ')
K=$(ls "$KIRO_DIR/skills/"*.md 2>/dev/null | wc -l | tr -d ' ')
H=$(ls "$KIRO_DIR/hooks/"*.kiro.hook 2>/dev/null | wc -l | tr -d ' ')

echo ""
echo -e "${GREEN}✓ Install complete${NC}"
echo -e "  Steering: $S | Skills: $K | Hooks: $H"
echo -e "  Open Kiro → type # → you should see your skills."
echo ""
INSTALLEOF

  chmod +x "$REPO_ROOT/scripts/install.sh"
  echo -e "  ${GREEN}✓${NC} scripts/install.sh generated"
fi

# ─── Done ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✓ Bootstrap complete!                                   ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Organization:  ${BOLD}$ORG_NAME${NC}"
echo -e "  Teams:         ${BOLD}${#TEAMS[@]}${NC}"
echo -e "  Orchestrator:  $(if [[ "$ENABLE_ORCH" =~ ^[yY] ]]; then echo "enabled"; else echo "disabled"; fi)"
echo -e "  Manifest:      ${BOLD}kit.json${NC}"
echo ""
echo -e "${DIM}Next steps:${NC}"
echo -e "  1. Add steering/skills/hooks to global/ and teams/<name>/"
echo -e "  2. Run: ${BOLD}./scripts/install.sh --team <name>${NC} to install locally"
echo -e "  3. Commit and push to share with your team"
if [[ "$ENABLE_ORCH" =~ ^[yY] ]]; then
  echo -e "  4. Deploy the orchestrator: see kiro-governance-orchestrator repo"
fi
echo ""
