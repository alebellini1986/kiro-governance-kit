#!/usr/bin/env bash
# ============================================================================
# Kiro Governance Kit — Repository Validation Script (v3.0)
# ============================================================================
# Validates the governance repository structure, assignments, and naming.
# Fail-slow: collects all errors and reports together at end.
#
# Usage:
#   ./scripts/validate.sh [--fix] [--verbose]
#
# Options:
#   --fix       Attempt to auto-fix issues where possible
#   --verbose   Show detailed output for each check
# ============================================================================

set -uo pipefail

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

# ─── State ───────────────────────────────────────────────────────────────────
FIX=false
VERBOSE=false
ERRORS=()
WARNINGS=()
CHECKS_PASSED=0
CHECKS_FAILED=0

# ─── Constants ───────────────────────────────────────────────────────────────
DIR_NAME_PATTERN='^[a-z0-9][a-z0-9-]{0,62}[a-z0-9]$|^[a-z0-9]$'
REQUIRED_TEAM_SUBDIRS=("steering" "skills" "hooks" "mcp-config")
EXPECTED_TEAMS=("team-a" "team-b" "team-c" "team-d" "team-e")

# Domain-specific keywords that should NOT appear in global/
# Replace these generic examples with the product/technology terms
# specific to each of your teams' domains.
DOMAIN_KEYWORDS=(
  "domain-1-keyword"
  "domain-2-keyword"
  "domain-3-keyword"
)

# ─── Utility ─────────────────────────────────────────────────────────────────
print_success() { echo -e "${GREEN}  ✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}  ⚠${NC} $1"; }
print_error()   { echo -e "${RED}  ✗${NC} $1"; }
print_info()    { echo -e "${DIM}  ℹ${NC} $1"; }
print_verbose() { [[ "$VERBOSE" == true ]] && echo -e "${DIM}    $1${NC}"; }

add_error() {
  ERRORS+=("$1")
  CHECKS_FAILED=$((CHECKS_FAILED + 1))
  print_error "$1"
}

add_warning() {
  WARNINGS+=("$1")
  print_warning "$1"
}

pass_check() {
  CHECKS_PASSED=$((CHECKS_PASSED + 1))
  print_success "$1"
}

# ─── Argument Parsing ────────────────────────────────────────────────────────
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --fix)
        FIX=true
        shift
        ;;
      --verbose)
        VERBOSE=true
        shift
        ;;
      -h|--help)
        show_usage
        exit 0
        ;;
      *)
        echo -e "${RED}Unknown argument:${NC} $1" >&2
        exit 1
        ;;
    esac
  done
}

show_usage() {
  cat <<EOF
Usage: $(basename "$0") [--fix] [--verbose]

Validates the governance repository structure and configuration assignments.

Options:
  --fix       Attempt to auto-fix issues where possible
  --verbose   Show detailed output for each check
  -h, --help  Show this help message

Checks performed:
  1. File assignment in TEAM-CAPABILITIES.md
  2. No multiply-assigned files (unless in _shared/)
  3. Directory naming conventions
  4. Team required subdirectories + README.md
  5. Project manifest.json with valid team reference
  6. No domain-specific files in global/
  7. teams/README.md roster matches actual directories
  8. No files in root steering/, skills/, hooks/ (post-cleanup)

Exit codes:
  0  All checks passed
  1  One or more checks failed

EOF
}

# ─── Check 1: File Assignment in TEAM-CAPABILITIES.md ────────────────────────
check_capability_assignment() {
  echo -e "\n${CYAN}━━━ Check 1: Capability Assignment ━━━${NC}\n"

  local capabilities_file="$REPO_ROOT/TEAM-CAPABILITIES.md"

  if [[ ! -f "$capabilities_file" ]]; then
    add_warning "TEAM-CAPABILITIES.md not found — skipping assignment check"
    return
  fi

  local capabilities_content
  capabilities_content=$(cat "$capabilities_file")

  # Collect all config files in global/, teams/*/, projects/*/
  local all_files=()

  # Global files
  for subdir in steering skills hooks mcp-config; do
    if [[ -d "$REPO_ROOT/global/$subdir" ]]; then
      for f in "$REPO_ROOT/global/$subdir"/*; do
        [[ -f "$f" ]] && all_files+=("global/$subdir/$(basename "$f")")
      done
    fi
  done

  # Team files (excluding _shared)
  for team_dir in "$REPO_ROOT/teams"/*/; do
    [[ -d "$team_dir" ]] || continue
    local team_name
    team_name=$(basename "$team_dir")
    [[ "$team_name" == "_shared" ]] && continue

    for subdir in steering skills hooks mcp-config; do
      if [[ -d "$team_dir/$subdir" ]]; then
        for f in "$team_dir/$subdir"/*; do
          [[ -f "$f" ]] && all_files+=("teams/$team_name/$subdir/$(basename "$f")")
        done
      fi
    done
  done

  # Shared files
  for subdir in steering skills hooks; do
    if [[ -d "$REPO_ROOT/teams/_shared/$subdir" ]]; then
      for f in "$REPO_ROOT/teams/_shared/$subdir"/*; do
        [[ -f "$f" ]] && all_files+=("teams/_shared/$subdir/$(basename "$f")")
      done
    fi
  done

  # Project files
  if [[ -d "$REPO_ROOT/projects" ]]; then
    for proj_dir in "$REPO_ROOT/projects"/*/; do
      [[ -d "$proj_dir" ]] || continue
      local proj_name
      proj_name=$(basename "$proj_dir")
      [[ "$proj_name" == "_template" ]] && continue

      for subdir in steering skills hooks mcp-config; do
        if [[ -d "$proj_dir/$subdir" ]]; then
          for f in "$proj_dir/$subdir"/*; do
            [[ -f "$f" ]] && all_files+=("projects/$proj_name/$subdir/$(basename "$f")")
          done
        fi
      done
    done
  fi

  # Check each file is mentioned in TEAM-CAPABILITIES.md
  local unassigned=0
  for filepath in "${all_files[@]:-}"; do
    local filename
    filename=$(basename "$filepath")
    if ! echo "$capabilities_content" | grep -qF "$filename"; then
      add_error "Unassigned file: $filepath — not found in TEAM-CAPABILITIES.md"
      unassigned=$((unassigned + 1))
    fi
  done

  if [[ $unassigned -eq 0 ]]; then
    pass_check "All ${#all_files[@]} config files assigned in TEAM-CAPABILITIES.md"
  fi
}

# ─── Check 2: No Multiply-Assigned Files ─────────────────────────────────────
check_no_duplicate_assignment() {
  echo -e "\n${CYAN}━━━ Check 2: No Multiply-Assigned Files ━━━${NC}\n"

  local capabilities_file="$REPO_ROOT/TEAM-CAPABILITIES.md"

  if [[ ! -f "$capabilities_file" ]]; then
    add_warning "TEAM-CAPABILITIES.md not found — skipping duplicate check"
    return
  fi

  # Collect filenames and detect duplicates across teams
  # Uses a temp file approach for bash 3.x compatibility (no associative arrays)
  local duplicates_found=false
  local tmpfile
  tmpfile=$(mktemp)

  # Build list of "category/filename team_name" entries
  for team_dir in "$REPO_ROOT/teams"/*/; do
    [[ -d "$team_dir" ]] || continue
    local team_name
    team_name=$(basename "$team_dir")
    [[ "$team_name" == "_shared" ]] && continue

    for subdir in steering skills hooks; do
      if [[ -d "$team_dir/$subdir" ]]; then
        for f in "$team_dir/$subdir"/*; do
          [[ -f "$f" ]] || continue
          local fname
          fname=$(basename "$f")
          echo "${subdir}/${fname} ${team_name}" >> "$tmpfile"
        done
      fi
    done
  done

  # Find duplicates: files appearing in more than one team
  local dup_keys
  dup_keys=$(awk '{print $1}' "$tmpfile" | sort | uniq -d)

  if [[ -n "$dup_keys" ]]; then
    while IFS= read -r key; do
      local teams
      teams=$(grep "^${key} " "$tmpfile" | awk '{print $2}' | tr '\n' ', ' | sed 's/,$//')
      # Check if it's in _shared (allowed)
      local subdir="${key%%/*}"
      local fname="${key#*/}"
      if [[ -f "$REPO_ROOT/teams/_shared/$subdir/$fname" ]]; then
        print_verbose "Shared file OK: $key (in _shared/ and teams: $teams)"
      else
        add_error "Multiply-assigned: $key — found in teams: $teams (not in _shared/)"
        duplicates_found=true
      fi
    done <<< "$dup_keys"
  fi

  if [[ "$duplicates_found" != true ]]; then
    pass_check "No multiply-assigned files detected"
  fi

  rm -f "$tmpfile"
}

# ─── Check 3: Directory Naming ───────────────────────────────────────────────
check_directory_naming() {
  echo -e "\n${CYAN}━━━ Check 3: Directory Naming Conventions ━━━${NC}\n"

  local invalid=0

  # Check team directory names
  for team_dir in "$REPO_ROOT/teams"/*/; do
    [[ -d "$team_dir" ]] || continue
    local name
    name=$(basename "$team_dir")
    [[ "$name" == "_shared" ]] && continue  # _shared is special

    if [[ "$name" =~ ^[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?$ ]]; then
      print_verbose "Valid team name: $name"
    else
      add_error "Invalid team directory name: '$name' — must match $DIR_NAME_PATTERN"
      invalid=$((invalid + 1))
    fi
  done

  # Check project directory names
  if [[ -d "$REPO_ROOT/projects" ]]; then
    for proj_dir in "$REPO_ROOT/projects"/*/; do
      [[ -d "$proj_dir" ]] || continue
      local name
      name=$(basename "$proj_dir")
      [[ "$name" == "_template" ]] && continue  # _template is special

      if [[ "$name" =~ ^[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?$ ]]; then
        print_verbose "Valid project name: $name"
      else
        add_error "Invalid project directory name: '$name' — must match $DIR_NAME_PATTERN"
        invalid=$((invalid + 1))
      fi
    done
  fi

  if [[ $invalid -eq 0 ]]; then
    pass_check "All directory names follow naming convention"
  fi
}

# ─── Check 4: Team Required Subdirectories + README.md ────────────────────────
check_team_structure() {
  echo -e "\n${CYAN}━━━ Check 4: Team Structure ━━━${NC}\n"

  local issues=0

  for team_dir in "$REPO_ROOT/teams"/*/; do
    [[ -d "$team_dir" ]] || continue
    local team_name
    team_name=$(basename "$team_dir")
    [[ "$team_name" == "_shared" ]] && continue

    # Check README.md
    if [[ ! -f "$team_dir/README.md" ]]; then
      add_error "Team '$team_name' missing README.md"
      issues=$((issues + 1))

      if [[ "$FIX" == true ]]; then
        cat > "$team_dir/README.md" <<EOF
# Team: $team_name

**Owner:** TBD
**Domain:** TBD
**Members:** TBD

## Configurations

### Steering
| File | Inclusion | Description |
|------|-----------|-------------|

### Skills
| Skill | Invocation | Description |
|-------|------------|-------------|

### Hooks
| Hook | Trigger | Description |
|------|---------|-------------|
EOF
        print_info "[FIX] Created README.md for team '$team_name'"
      fi
    else
      print_verbose "Team '$team_name' has README.md"
    fi

    # Check required subdirectories
    for subdir in "${REQUIRED_TEAM_SUBDIRS[@]}"; do
      if [[ ! -d "$team_dir/$subdir" ]]; then
        add_error "Team '$team_name' missing required subdirectory: $subdir/"
        issues=$((issues + 1))

        if [[ "$FIX" == true ]]; then
          mkdir -p "$team_dir/$subdir"
          print_info "[FIX] Created $subdir/ for team '$team_name'"
        fi
      else
        print_verbose "Team '$team_name' has $subdir/"
      fi
    done
  done

  if [[ $issues -eq 0 ]]; then
    pass_check "All teams have required structure (README.md + subdirectories)"
  fi
}

# ─── Check 5: Project manifest.json Validation ───────────────────────────────
check_project_manifests() {
  echo -e "\n${CYAN}━━━ Check 5: Project Manifests ━━━${NC}\n"

  if [[ ! -d "$REPO_ROOT/projects" ]]; then
    print_info "No projects/ directory — skipping"
    return
  fi

  local issues=0
  local project_count=0

  for proj_dir in "$REPO_ROOT/projects"/*/; do
    [[ -d "$proj_dir" ]] || continue
    local proj_name
    proj_name=$(basename "$proj_dir")
    [[ "$proj_name" == "_template" ]] && continue
    project_count=$((project_count + 1))

    local manifest="$proj_dir/manifest.json"
    if [[ ! -f "$manifest" ]]; then
      add_error "Project '$proj_name' missing manifest.json"
      issues=$((issues + 1))
      continue
    fi

    # Validate JSON
    if ! python3 -c "import json; json.load(open('$manifest'))" 2>/dev/null; then
      add_error "Project '$proj_name' has invalid JSON in manifest.json"
      issues=$((issues + 1))
      continue
    fi

    # Check team reference
    local team_ref
    team_ref=$(python3 -c "import json; print(json.load(open('$manifest')).get('team', ''))" 2>/dev/null || echo "")

    if [[ -z "$team_ref" ]]; then
      add_error "Project '$proj_name' manifest.json missing 'team' field"
      issues=$((issues + 1))
    elif [[ ! -d "$REPO_ROOT/teams/$team_ref" ]]; then
      add_error "Project '$proj_name' references non-existent team: '$team_ref'"
      issues=$((issues + 1))
    else
      print_verbose "Project '$proj_name' → team '$team_ref' (valid)"
    fi
  done

  if [[ $project_count -eq 0 ]]; then
    print_info "No projects found (only _template)"
  elif [[ $issues -eq 0 ]]; then
    pass_check "All $project_count project manifest(s) valid"
  fi
}

# ─── Check 6: No Domain-Specific Files in global/ ────────────────────────────
check_global_no_domain_specific() {
  echo -e "\n${CYAN}━━━ Check 6: No Domain-Specific Content in global/ ━━━${NC}\n"

  local issues=0

  for subdir in steering skills hooks; do
    local dir="$REPO_ROOT/global/$subdir"
    [[ -d "$dir" ]] || continue

    for f in "$dir"/*; do
      [[ -f "$f" ]] || continue
      local filename
      filename=$(basename "$f")
      local filename_lower
      filename_lower=$(echo "$filename" | tr '[:upper:]' '[:lower:]')

      # Only check FILENAME for domain keywords (not content).
      # Governance/audit skills legitimately reference domain terms in their body
      # (e.g., gov-security-compliance.md mentions "eks" as something to audit).
      # A file is domain-specific only if its NAME indicates a single-domain purpose.
      for keyword in "${DOMAIN_KEYWORDS[@]}"; do
        if echo "$filename_lower" | grep -qw "$keyword"; then
          add_error "Domain-specific file in global/$subdir/: '$filename' (keyword: $keyword)"
          issues=$((issues + 1))
          break
        fi
      done
    done
  done

  if [[ $issues -eq 0 ]]; then
    pass_check "No domain-specific content in global/"
  fi
}

# ─── Check 7: teams/README.md Roster Matches Directories ─────────────────────
check_team_roster() {
  echo -e "\n${CYAN}━━━ Check 7: Team Roster Consistency ━━━${NC}\n"

  local readme="$REPO_ROOT/teams/README.md"

  if [[ ! -f "$readme" ]]; then
    add_warning "teams/README.md not found — skipping roster check"
    return
  fi

  local readme_content
  readme_content=$(cat "$readme")
  local issues=0

  # Check each expected team is mentioned in README
  for team in "${EXPECTED_TEAMS[@]}"; do
    if [[ -d "$REPO_ROOT/teams/$team" ]]; then
      if ! echo "$readme_content" | grep -qi "$team"; then
        add_error "Team '$team' exists as directory but not documented in teams/README.md"
        issues=$((issues + 1))
      else
        print_verbose "Team '$team' documented in roster"
      fi
    else
      add_error "Expected team '$team' directory missing under teams/"
      issues=$((issues + 1))
    fi
  done

  # Check for directories not in expected list (excluding _shared)
  for team_dir in "$REPO_ROOT/teams"/*/; do
    [[ -d "$team_dir" ]] || continue
    local name
    name=$(basename "$team_dir")
    [[ "$name" == "_shared" ]] && continue

    local found=false
    for expected in "${EXPECTED_TEAMS[@]}"; do
      if [[ "$name" == "$expected" ]]; then
        found=true
        break
      fi
    done

    if [[ "$found" == false ]]; then
      add_warning "Unexpected team directory: '$name' (not in expected roster)"
    fi
  done

  if [[ $issues -eq 0 ]]; then
    pass_check "Team roster matches actual directories"
  fi
}

# ─── Check 8: No Files in Root steering/, skills/, hooks/ ────────────────────
check_root_cleanup() {
  echo -e "\n${CYAN}━━━ Check 8: Root-Level Cleanup ━━━${NC}\n"

  local issues=0

  for dir in steering skills hooks; do
    local root_dir="$REPO_ROOT/$dir"
    if [[ -d "$root_dir" ]]; then
      local file_count
      file_count=$(find "$root_dir" -type f | wc -l | tr -d ' ')
      if [[ $file_count -gt 0 ]]; then
        add_error "Root $dir/ still contains $file_count file(s) — should be relocated"
        issues=$((issues + 1))

        if [[ "$VERBOSE" == true ]]; then
          find "$root_dir" -type f | while read -r f; do
            print_verbose "  Remaining: $f"
          done
        fi
      else
        print_verbose "Root $dir/ is empty or doesn't exist"
      fi
    else
      print_verbose "Root $dir/ already removed"
    fi
  done

  if [[ $issues -eq 0 ]]; then
    pass_check "No configuration files in root-level directories"
  fi
}

# ─── Summary ─────────────────────────────────────────────────────────────────
show_summary() {
  echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${CYAN}━━━ Validation Summary ━━━${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

  echo -e "  Checks passed : ${GREEN}$CHECKS_PASSED${NC}"
  echo -e "  Checks failed : ${RED}$CHECKS_FAILED${NC}"
  echo -e "  Warnings      : ${YELLOW}${#WARNINGS[@]}${NC}"

  if [[ ${#ERRORS[@]} -gt 0 ]]; then
    echo -e "\n  ${RED}${BOLD}Errors:${NC}"
    for err in "${ERRORS[@]}"; do
      echo -e "    ${RED}•${NC} $err"
    done
  fi

  if [[ ${#WARNINGS[@]} -gt 0 ]]; then
    echo -e "\n  ${YELLOW}${BOLD}Warnings:${NC}"
    for warn in "${WARNINGS[@]}"; do
      echo -e "    ${YELLOW}•${NC} $warn"
    done
  fi

  echo ""

  if [[ ${#ERRORS[@]} -eq 0 ]]; then
    echo -e "  ${GREEN}${BOLD}✅ All validation checks passed!${NC}"
    return 0
  else
    echo -e "  ${RED}${BOLD}❌ Validation failed with ${#ERRORS[@]} error(s)${NC}"
    if [[ "$FIX" != true ]]; then
      echo -e "  ${DIM}Run with --fix to attempt auto-repair${NC}"
    fi
    return 1
  fi
}

# ─── Main ────────────────────────────────────────────────────────────────────
main() {
  echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║${NC}  ${BOLD}🔍 Kiro Governance Kit — Repository Validator v3.0${NC}       ${BLUE}║${NC}"
  echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"

  parse_args "$@"

  # Run all checks (fail-slow: collect all errors)
  check_capability_assignment
  check_no_duplicate_assignment
  check_directory_naming
  check_team_structure
  check_project_manifests
  check_global_no_domain_specific
  check_team_roster
  check_root_cleanup

  # Show summary and exit with appropriate code
  if show_summary; then
    exit 0
  else
    exit 1
  fi
}

main "$@"
