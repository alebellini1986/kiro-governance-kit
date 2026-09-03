#!/usr/bin/env bash
# ============================================================================
# Kiro Governance Kit — Three-Level Installer (v3.0)
# ============================================================================
# Three-phase install: Global → Shared → Team → Project to ~/.kiro/
# Usage:
#   ./scripts/install.sh --team <team-name> [--project <project-name>]
#   ./scripts/install.sh --project <project-name> --target <folder>
#
# Examples:
#   ./scripts/install.sh --team team-a
#   ./scripts/install.sh --team team-a --project my-api
#   ./scripts/install.sh --project example-project --target /path/to/workspace
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

# ─── Paths ───────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
KIRO_DIR="$HOME/.kiro"
KIRO_STEERING="$KIRO_DIR/steering"
KIRO_SKILLS="$KIRO_DIR/skills"
KIRO_HOOKS="$KIRO_DIR/hooks"
KIRO_AGENTS="$KIRO_DIR/agents"
KIRO_SETTINGS="$KIRO_DIR/settings"

# ─── State ───────────────────────────────────────────────────────────────────
TEAM=""
PROJECT=""
TARGET_DIR=""
INSTALLED_FILES=()  # Track installed filenames for conflict detection
INSTALL_COUNT=0
CONFLICT_FOUND=false

# ─── Utility ─────────────────────────────────────────────────────────────────
print_success() { echo -e "${GREEN}  ✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}  ⚠${NC} $1"; }
print_error()   { echo -e "${RED}  ✗${NC} $1"; }
print_info()    { echo -e "${DIM}  ℹ${NC} $1"; }

die() {
  echo -e "${RED}ERROR:${NC} $1" >&2
  exit "${2:-1}"
}

# ─── Argument Parsing ────────────────────────────────────────────────────────
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --team)
        [[ -z "${2:-}" ]] && die "--team requires a value"
        TEAM="$2"
        shift 2
        ;;
      --project)
        [[ -z "${2:-}" ]] && die "--project requires a value"
        PROJECT="$2"
        shift 2
        ;;
      --target)
        [[ -z "${2:-}" ]] && die "--target requires a value"
        TARGET_DIR="$2"
        shift 2
        ;;
      -h|--help)
        show_usage
        exit 0
        ;;
      *)
        die "Unknown argument: $1"
        ;;
    esac
  done

  # --project + --target mode: deploy to workspace
  if [[ -n "$PROJECT" && -n "$TARGET_DIR" ]]; then
    return 0
  fi

  # --team is required for normal install
  if [[ -z "$TEAM" ]]; then
    die "--team is required.\n\nUsage: $0 --team <team-name> [--project <project-name>]"
  fi
}

show_usage() {
  cat <<EOF
Usage: $(basename "$0") --team <team-name> [--project <project-name>]
       $(basename "$0") --project <project-name> --target <folder>

Three-level installer for Kiro Governance Kit.
Installs configurations to ~/.kiro/ following Global → Shared → Team → Project order.

Modes:
  Normal install    Merges Global/Shared/Team/Project into ~/.kiro/
  Deploy project    Copies a project's config into <folder>/.kiro/ (workspace-level)

Options:
  --team <name>       Team name (required for normal install)
  --project <name>    Project name (with --team: merges into ~/.kiro/; with --target: deploys to folder)
  --target <folder>   Destination folder for workspace-level deploy (used with --project)
  -h, --help          Show this help message

Available teams:
$(ls -1 "$REPO_ROOT/teams" 2>/dev/null | grep -v '^_' | grep -v 'README' | sed 's/^/  /')

Available projects:
$(ls -1 "$REPO_ROOT/projects" 2>/dev/null | grep -v '^_' | grep -v 'README' | sed 's/^/  /')

Examples:
  $(basename "$0") --team team-a
  $(basename "$0") --team team-a --project my-api
  $(basename "$0") --project example-project --target /path/to/workspace
EOF
}

# ─── Validation ──────────────────────────────────────────────────────────────
validate_params() {
  local team_dir="$REPO_ROOT/teams/$TEAM"

  # Validate team exists
  if [[ ! -d "$team_dir" ]]; then
    local valid_teams
    valid_teams=$(ls -1 "$REPO_ROOT/teams" 2>/dev/null | grep -v '^_' | grep -v 'README' | tr '\n' ', ' | sed 's/,$//')
    die "Team '$TEAM' not found.\nValid teams: $valid_teams"
  fi

  # Validate project if specified
  if [[ -n "$PROJECT" ]]; then
    local project_dir="$REPO_ROOT/projects/$PROJECT"

    if [[ ! -d "$project_dir" ]]; then
      local valid_projects
      valid_projects=$(ls -1 "$REPO_ROOT/projects" 2>/dev/null | grep -v '^_' | grep -v 'README' | tr '\n' ', ' | sed 's/,$//')
      die "Project '$PROJECT' not found.\nValid projects: ${valid_projects:-none}"
    fi

    # Verify project belongs to specified team
    local manifest="$project_dir/manifest.json"
    if [[ -f "$manifest" ]]; then
      local project_team
      project_team=$(grep -o '"team"[[:space:]]*:[[:space:]]*"[^"]*"' "$manifest" | grep -o '"[^"]*"$' | tr -d '"')
      if [[ "$project_team" != "$TEAM" ]]; then
        die "Project '$PROJECT' belongs to team '$project_team', not '$TEAM'."
      fi
    else
      die "Project '$PROJECT' is missing manifest.json."
    fi
  fi
}

# ─── Prerequisite Checks ────────────────────────────────────────────────────
check_prerequisites() {
  echo -e "\n${CYAN}━━━ Prerequisite Checks ━━━${NC}\n"

  local warnings=0

  # Node.js
  if command -v node &>/dev/null; then
    local node_ver
    node_ver=$(node --version | sed 's/v//' | cut -d. -f1)
    if [[ "$node_ver" -ge 18 ]]; then
      print_success "Node.js $(node --version)"
    else
      print_warning "Node.js $(node --version) — v18+ recommended"
      warnings=$((warnings + 1))
    fi
  else
    print_warning "Node.js not found — needed for MCP servers"
    warnings=$((warnings + 1))
  fi

  # Python
  if command -v python3 &>/dev/null; then
    print_success "Python $(python3 --version 2>&1 | cut -d' ' -f2)"
  elif command -v python &>/dev/null; then
    print_success "Python $(python --version 2>&1 | cut -d' ' -f2)"
  else
    print_warning "Python not found — needed for some MCP servers"
    warnings=$((warnings + 1))
  fi

  # AWS CLI
  if command -v aws &>/dev/null; then
    print_success "AWS CLI $(aws --version 2>&1 | cut -d' ' -f1 | cut -d'/' -f2)"
  else
    print_warning "AWS CLI not found — needed for aws-core MCP"
    warnings=$((warnings + 1))
  fi

  if [[ $warnings -gt 0 ]]; then
    echo ""
    print_warning "$warnings optional prerequisite(s) missing — continuing anyway"
  fi
}

# ─── Conflict Detection ─────────────────────────────────────────────────────
# Check if a filename already exists in the installed set for a given category
check_conflict() {
  local filename="$1"
  local category="$2"  # steering, skills, hooks
  local level="$3"     # global, shared, team, project

  local key="${category}/${filename}"

  for entry in "${INSTALLED_FILES[@]:-}"; do
    if [[ "$entry" == "$key:"* ]]; then
      local prev_level="${entry#*:}"
      echo -e "${RED}CONFLICT:${NC} '${filename}' in ${category}/ at ${level} level duplicates ${prev_level} level" >&2
      CONFLICT_FOUND=true
      return 1
    fi
  done

  INSTALLED_FILES+=("${key}:${level}")
  return 0
}

# ─── File Installation ───────────────────────────────────────────────────────
install_category() {
  local src_dir="$1"
  local dest_dir="$2"
  local category="$3"  # steering, skills, hooks
  local level="$4"     # global, shared, team, project
  local label="$5"

  if [[ ! -d "$src_dir" ]]; then
    print_info "$label: directory not found, skipping"
    return 0
  fi

  mkdir -p "$dest_dir"
  local count=0

  for file in "$src_dir"/*; do
    [[ -f "$file" ]] || continue
    local filename
    filename=$(basename "$file")

    # Skip README files
    [[ "$filename" == "README.md" ]] && continue

    # Conflict detection
    if ! check_conflict "$filename" "$category" "$level"; then
      return 1
    fi

    # Copy file (hooks: .json → .kiro.hook)
    if [[ "$category" == "hooks" && "$filename" == *.json ]]; then
      local hook_name="${filename%.json}"
      cp "$file" "$dest_dir/${hook_name}.kiro.hook"
    else
      cp "$file" "$dest_dir/$filename"
    fi
    count=$((count + 1))
  done

  if [[ $count -gt 0 ]]; then
    print_success "$label: $count file(s) installed"
    INSTALL_COUNT=$((INSTALL_COUNT + count))
  else
    print_info "$label: no files to install"
  fi
}

# ─── MCP Config Merge ────────────────────────────────────────────────────────
merge_mcp_configs() {
  echo -e "\n${CYAN}━━━ MCP Configuration Merge ━━━${NC}\n"

  mkdir -p "$KIRO_SETTINGS"
  local output_file="$KIRO_SETTINGS/mcp.json"
  local merged_servers=""
  local server_sources=""  # Track which level defined each server key

  # Collect MCP configs from all levels
  local configs=()
  local config_levels=()

  local global_mcp="$REPO_ROOT/global/mcp-config/mcp.json"
  if [[ -f "$global_mcp" ]]; then
    configs+=("$global_mcp")
    config_levels+=("global")
  fi

  local team_mcp="$REPO_ROOT/teams/$TEAM/mcp-config/mcp.json"
  if [[ -f "$team_mcp" ]]; then
    configs+=("$team_mcp")
    config_levels+=("team")
  fi

  if [[ -n "$PROJECT" ]]; then
    local project_mcp="$REPO_ROOT/projects/$PROJECT/mcp-config/mcp.json"
    if [[ -f "$project_mcp" ]]; then
      configs+=("$project_mcp")
      config_levels+=("project")
    fi
  fi

  if [[ ${#configs[@]} -eq 0 ]]; then
    print_info "No MCP configurations found at any level"
    return 0
  fi

  # If only one config, just copy it
  if [[ ${#configs[@]} -eq 1 ]]; then
    cp "${configs[0]}" "$output_file"
    print_success "MCP config installed from ${config_levels[0]} level"
    return 0
  fi

  # Deep merge with duplicate server key detection
  # Use Python for reliable JSON merging
  local merge_script
  merge_script=$(cat <<'PYTHON'
import json
import sys

configs = []
levels = []
for i in range(1, len(sys.argv), 2):
    with open(sys.argv[i]) as f:
        configs.append(json.load(f))
    levels.append(sys.argv[i+1])

merged = {}
server_owners = {}  # server_key -> level that defined it

for config, level in zip(configs, levels):
    servers = config.get("mcpServers", config.get("servers", {}))
    for key, value in servers.items():
        if key in server_owners:
            print(f"ERROR: Duplicate MCP server key '{key}' — defined at {server_owners[key]} and {level} levels", file=sys.stderr)
            sys.exit(2)
        server_owners[key] = level
        merged[key] = value

output = {"mcpServers": merged}
json.dump(output, sys.stdout, indent=2)
print()
PYTHON
  )

  local merge_args=()
  for i in "${!configs[@]}"; do
    merge_args+=("${configs[$i]}" "${config_levels[$i]}")
  done

  local merge_result
  if ! merge_result=$(python3 -c "$merge_script" "${merge_args[@]}" 2>&1); then
    if echo "$merge_result" | grep -q "^ERROR:"; then
      die "$merge_result" 2
    else
      die "MCP config merge failed: $merge_result"
    fi
  fi

  echo "$merge_result" > "$output_file"
  print_success "MCP config merged from ${#configs[@]} levels → ~/.kiro/settings/mcp.json"
}

# ─── Phase Execution ─────────────────────────────────────────────────────────
install_global() {
  echo -e "\n${CYAN}━━━ Phase 1: Global Level ━━━${NC}\n"

  install_category "$REPO_ROOT/global/steering" "$KIRO_STEERING" "steering" "global" "Global steering" || return 1
  install_category "$REPO_ROOT/global/skills" "$KIRO_SKILLS" "skills" "global" "Global skills" || return 1
  install_category "$REPO_ROOT/global/hooks" "$KIRO_HOOKS" "hooks" "global" "Global hooks" || return 1
  install_category "$REPO_ROOT/global/agents" "$KIRO_AGENTS" "agents" "global" "Global agents" || return 1
}

install_shared() {
  echo -e "\n${CYAN}━━━ Phase 2: Shared Level ━━━${NC}\n"

  local shared_dir="$REPO_ROOT/teams/_shared"
  if [[ ! -d "$shared_dir" ]]; then
    print_info "No _shared/ directory found, skipping"
    return 0
  fi

  install_category "$shared_dir/steering" "$KIRO_STEERING" "steering" "shared" "Shared steering" || return 1
  install_category "$shared_dir/skills" "$KIRO_SKILLS" "skills" "shared" "Shared skills" || return 1
  install_category "$shared_dir/hooks" "$KIRO_HOOKS" "hooks" "shared" "Shared hooks" || return 1
  install_category "$shared_dir/agents" "$KIRO_AGENTS" "agents" "shared" "Shared agents" || return 1
}

install_team() {
  echo -e "\n${CYAN}━━━ Phase 3: Team Level ($TEAM) ━━━${NC}\n"

  local team_dir="$REPO_ROOT/teams/$TEAM"

  install_category "$team_dir/steering" "$KIRO_STEERING" "steering" "team" "Team steering" || return 1
  install_category "$team_dir/skills" "$KIRO_SKILLS" "skills" "team" "Team skills" || return 1
  install_category "$team_dir/hooks" "$KIRO_HOOKS" "hooks" "team" "Team hooks" || return 1
  install_category "$team_dir/agents" "$KIRO_AGENTS" "agents" "team" "Team agents" || return 1
}

install_project() {
  if [[ -z "$PROJECT" ]]; then
    return 0
  fi

  echo -e "\n${CYAN}━━━ Phase 4: Project Level ($PROJECT) ━━━${NC}\n"

  local project_dir="$REPO_ROOT/projects/$PROJECT"

  install_category "$project_dir/steering" "$KIRO_STEERING" "steering" "project" "Project steering" || return 1
  install_category "$project_dir/skills" "$KIRO_SKILLS" "skills" "project" "Project skills" || return 1
  install_category "$project_dir/hooks" "$KIRO_HOOKS" "hooks" "project" "Project hooks" || return 1
  install_category "$project_dir/agents" "$KIRO_AGENTS" "agents" "project" "Project agents" || return 1
}

# ─── Verification Summary ────────────────────────────────────────────────────
show_verification() {
  echo -e "\n${CYAN}━━━ Verification Summary ━━━${NC}\n"

  local steering_count=0
  local skills_count=0
  local hooks_count=0
  local agents_count=0

  if [[ -d "$KIRO_STEERING" ]]; then
    steering_count=$(find "$KIRO_STEERING" -maxdepth 1 -type f | wc -l | tr -d ' ')
  fi
  if [[ -d "$KIRO_SKILLS" ]]; then
    skills_count=$(find "$KIRO_SKILLS" -maxdepth 1 -type f | wc -l | tr -d ' ')
  fi
  if [[ -d "$KIRO_HOOKS" ]]; then
    hooks_count=$(find "$KIRO_HOOKS" -maxdepth 1 -type f | wc -l | tr -d ' ')
  fi
  if [[ -d "$KIRO_AGENTS" ]]; then
    agents_count=$(find "$KIRO_AGENTS" -maxdepth 1 -type f | wc -l | tr -d ' ')
  fi

  echo -e "  ${BOLD}Installation complete:${NC}"
  echo -e "    Steering files : $steering_count → ~/.kiro/steering/"
  echo -e "    Skills files   : $skills_count → ~/.kiro/skills/"
  echo -e "    Hooks files    : $hooks_count → ~/.kiro/hooks/"
  echo -e "    Agents files   : $agents_count → ~/.kiro/agents/"
  echo -e "    MCP config     : ~/.kiro/settings/mcp.json"
  echo ""
  echo -e "  ${BOLD}Levels applied:${NC}"
  echo -e "    ${GREEN}✓${NC} Global"
  echo -e "    ${GREEN}✓${NC} Shared (_shared/)"
  echo -e "    ${GREEN}✓${NC} Team: $TEAM"
  if [[ -n "$PROJECT" ]]; then
    echo -e "    ${GREEN}✓${NC} Project: $PROJECT"
  fi
  echo ""
  echo -e "  ${BOLD}Total files installed: $INSTALL_COUNT${NC}"
  echo ""
  echo -e "  ${DIM}Restart Kiro or run Command Palette → MCP: Reconnect${NC}"
}

# ─── Deploy Project to Target Folder ─────────────────────────────────────────
deploy_project_to_target() {
  local project_dir="$REPO_ROOT/projects/$PROJECT"

  # Validate project exists
  if [[ ! -d "$project_dir" ]]; then
    local valid
    valid=$(ls -1 "$REPO_ROOT/projects" 2>/dev/null | grep -v '^_' | grep -v 'README' | tr '\n' ', ' | sed 's/,$//')
    die "Project '$PROJECT' not found.\nValid projects: ${valid:-none}"
  fi

  # Validate target exists
  if [[ ! -d "$TARGET_DIR" ]]; then
    die "Target folder '$TARGET_DIR' does not exist."
  fi

  local dest="$TARGET_DIR/.kiro"

  echo -e "\n${CYAN}━━━ Deploy project '$PROJECT' → $dest ━━━${NC}\n"

  mkdir -p "$dest"

  local count=0

  # Copy each category
  for category in steering skills hooks agents mcp-config; do
    local src="$project_dir/$category"
    [[ -d "$src" ]] || continue

    local dest_cat="$dest/$category"
    # mcp-config → settings/mcp.json (Kiro convention)
    if [[ "$category" == "mcp-config" ]]; then
      dest_cat="$dest/settings"
      mkdir -p "$dest_cat"
      for f in "$src"/*; do
        [[ -f "$f" ]] || continue
        cp "$f" "$dest_cat/$(basename "$f")"
        count=$((count + 1))
      done
    else
      mkdir -p "$dest_cat"
      cp -a "$src"/. "$dest_cat"/
      # Remove unwanted files from dest
      find "$dest_cat" -name '.gitkeep' -delete 2>/dev/null || true
      find "$dest_cat" -name 'README.md' -delete 2>/dev/null || true
      count=$((count + $(find "$dest_cat" -type f | wc -l | tr -d ' ')))
    fi
  done

  # Copy manifest if present
  if [[ -f "$project_dir/manifest.json" ]]; then
    cp "$project_dir/manifest.json" "$dest/manifest.json"
    count=$((count + 1))
  fi

  echo -e "${GREEN}  ✓${NC} $count file(s) deployed to $dest"
  echo ""
  echo -e "  ${DIM}Restart Kiro or open the workspace to activate.${NC}"
}

# ─── Main ────────────────────────────────────────────────────────────────────
main() {
  echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║${NC}  ${BOLD}🚀 Kiro Governance Kit — Three-Level Installer v3.0${NC}       ${BLUE}║${NC}"
  echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"

  parse_args "$@"

  # Deploy-project mode: copy project to target/.kiro and exit
  if [[ -n "$PROJECT" && -n "$TARGET_DIR" ]]; then
    deploy_project_to_target
    return 0
  fi

  validate_params
  check_prerequisites

  # Create base directories (exit 3 on permission error)
  if ! mkdir -p "$KIRO_STEERING" "$KIRO_SKILLS" "$KIRO_HOOKS" "$KIRO_AGENTS" "$KIRO_SETTINGS" 2>/dev/null; then
    die "Permission error: cannot create directories under ~/.kiro/\n  Try: chmod -R u+w ~/.kiro/" 3
  fi

  # Execute phases in order
  install_global || die "Installation aborted due to conflict" 2
  install_shared || die "Installation aborted due to conflict" 2
  install_team || die "Installation aborted due to conflict" 2
  install_project || die "Installation aborted due to conflict" 2

  # MCP config merge
  merge_mcp_configs

  # Final verification
  show_verification
}

main "$@"
