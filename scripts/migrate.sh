#!/usr/bin/env bash
# ============================================================================
# Kiro Governance Kit — Migration Script (v3.0)
# ============================================================================
# Migrates existing ~/.kiro/ from old two-level structure to new three-level.
# Creates timestamped backup, maps old paths → new, writes migration marker.
#
# Usage:
#   ./scripts/migrate.sh [--dry-run] [--backup-dir <path>]
#
# Options:
#   --dry-run       Show what would be done without making changes
#   --backup-dir    Custom backup directory (default: ~/.kiro-backup-<timestamp>)
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
MIGRATION_MARKER="$KIRO_DIR/.migration-marker"
MIGRATION_VERSION="3.0"

# ─── State ───────────────────────────────────────────────────────────────────
DRY_RUN=false
BACKUP_DIR=""
FILES_MOVED=0
FILES_SKIPPED=0
FILES_ERRORS=0
ERROR_LOG=()

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
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --backup-dir)
        [[ -z "${2:-}" ]] && die "--backup-dir requires a path"
        BACKUP_DIR="$2"
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
}

show_usage() {
  cat <<EOF
Usage: $(basename "$0") [--dry-run] [--backup-dir <path>]

Migrates ~/.kiro/ from old two-level structure to new three-level structure.

Options:
  --dry-run         Show what would be done without making changes
  --backup-dir      Custom backup directory (default: ~/.kiro-backup-<timestamp>)
  -h, --help        Show this help message

The script:
  1. Checks if already migrated (via .migration-marker)
  2. Creates timestamped backup of ~/.kiro/
  3. Reorganizes files from old paths to new paths
  4. Writes .migration-marker on success
  5. Displays summary of changes

EOF
}

# ─── Path Mapping Table ──────────────────────────────────────────────────────
# Maps old filenames in ~/.kiro/ to their new locations based on the
# three-level restructure. Format: "old_relative_path|new_relative_path"
#
# Old structure: flat files in steering/, skills/, hooks/
# New structure: same dirs but files come from specific levels (global/team/shared)
# The migration renames files that were split or reorganized.

declare -a PATH_MAP=(
  # Steering: files that stay (from global)
  "steering/safety.md|steering/safety.md"
  "steering/aws-conventions.md|steering/aws-conventions.md"
  "steering/code-standards.md|steering/code-standards.md"

  # Steering: files that were shared (now come from _shared)
  "steering/github.md|steering/github.md"
  "steering/jira.md|steering/jira.md"
  "steering/troubleshooting.md|steering/troubleshooting.md"
  "steering/cross-team.md|steering/cross-team.md"

  # Steering: team-specific files (now only installed if matching team selected)
  # These get removed during migration — user must re-run install.sh with --team
  "steering/terraform.md|REMOVE"
  "steering/eks.md|REMOVE"
  "steering/gitops.md|REMOVE"
  "steering/finops.md|REMOVE"
  "steering/aws.md|REMOVE"
  "steering/incident-postmortem.md|REMOVE"

  # Skills: files that stay (from global)
  "skills/gov-iam-access.md|skills/gov-iam-access.md"
  "skills/gov-security-compliance.md|skills/gov-security-compliance.md"
  "skills/gov-tagging-naming.md|skills/gov-tagging-naming.md"
  "skills/gov-compliance-scorecard.md|skills/gov-compliance-scorecard.md"
  "skills/gov-operational-excellence.md|skills/gov-operational-excellence.md"
  "skills/gov-change-management.md|skills/gov-change-management.md"
  "skills/team-onboarding-check.md|skills/team-onboarding-check.md"

  # Skills: shared skills (stay in place, now from _shared)
  "skills/pr-description.md|skills/pr-description.md"
  "skills/systematic-debugging.md|skills/systematic-debugging.md"
  "skills/brainstorming.md|skills/brainstorming.md"
  "skills/executing-plans.md|skills/executing-plans.md"
  "skills/finishing-branch.md|skills/finishing-branch.md"
  "skills/writing-plans.md|skills/writing-plans.md"
  "skills/verification-before-completion.md|skills/verification-before-completion.md"

  # Skills: team-specific (removed — re-install with --team)
  "skills/gov-cost-finops.md|REMOVE"
  "skills/gov-network.md|REMOVE"
  "skills/subagent-development.md|REMOVE"

  # Hooks: global hooks (stay, rename .kiro.hook if needed)
  "hooks/shell-safety.kiro.hook|hooks/shell-safety.kiro.hook"
  "hooks/review-write-ops.kiro.hook|hooks/review-write-ops.kiro.hook"
  "hooks/document-new-file.kiro.hook|hooks/document-new-file.kiro.hook"
  "hooks/skill-suggester.kiro.hook|hooks/skill-suggester.kiro.hook"

  # Hooks: shared hooks
  "hooks/quality-check.kiro.hook|hooks/quality-check.kiro.hook"
  "hooks/pr-description.kiro.hook|hooks/pr-description.kiro.hook"

  # Hooks: team-specific (removed — re-install with --team)
  "hooks/helm-lint.kiro.hook|REMOVE"
  "hooks/k8s-validate.kiro.hook|REMOVE"
  "hooks/tf-fmt.kiro.hook|REMOVE"
  "hooks/tf-validate.kiro.hook|REMOVE"
  "hooks/test-after-task.kiro.hook|REMOVE"
  "hooks/drift-detection.kiro.hook|REMOVE"
  "hooks/policy-validation.kiro.hook|REMOVE"

  # Hooks: lint-on-save split (old combined → removed, new split installed by team)
  "hooks/lint-on-save.kiro.hook|REMOVE"
)

# ─── Idempotency Check ──────────────────────────────────────────────────────
check_already_migrated() {
  if [[ -f "$MIGRATION_MARKER" ]]; then
    local marker_version
    marker_version=$(cat "$MIGRATION_MARKER" 2>/dev/null || echo "unknown")
    echo -e "\n${GREEN}Already migrated${NC} (version: $marker_version)"
    echo -e "  No migration needed. Run ${BOLD}install.sh --team <name>${NC} to update configs."
    exit 0
  fi
}

# ─── Backup ──────────────────────────────────────────────────────────────────
create_backup() {
  if [[ -z "$BACKUP_DIR" ]]; then
    BACKUP_DIR="$HOME/.kiro-backup-$(date +%Y%m%d-%H%M%S)"
  fi

  echo -e "\n${CYAN}━━━ Creating Backup ━━━${NC}\n"

  if [[ "$DRY_RUN" == true ]]; then
    print_info "[DRY RUN] Would backup ~/.kiro/ → $BACKUP_DIR"
    return 0
  fi

  if ! cp -a "$KIRO_DIR" "$BACKUP_DIR"; then
    die "Failed to create backup at $BACKUP_DIR. Aborting — no changes made." 1
  fi

  print_success "Backup created: $BACKUP_DIR"
}

# ─── Migration Logic ─────────────────────────────────────────────────────────
migrate_file() {
  local old_path="$1"
  local new_path="$2"
  local full_old="$KIRO_DIR/$old_path"

  # Source doesn't exist — skip silently
  if [[ ! -f "$full_old" ]]; then
    FILES_SKIPPED=$((FILES_SKIPPED + 1))
    return 0
  fi

  # REMOVE action: delete team-specific files that no longer belong at user level
  if [[ "$new_path" == "REMOVE" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      print_info "[DRY RUN] Would remove: $old_path (team-specific, re-install with --team)"
      FILES_MOVED=$((FILES_MOVED + 1))
      return 0
    fi

    if rm -f "$full_old" 2>/dev/null; then
      print_success "Removed: $old_path (team-specific → re-install with --team)"
      FILES_MOVED=$((FILES_MOVED + 1))
    else
      print_error "Failed to remove: $old_path"
      ERROR_LOG+=("REMOVE failed: $old_path")
      FILES_ERRORS=$((FILES_ERRORS + 1))
    fi
    return 0
  fi

  local full_new="$KIRO_DIR/$new_path"

  # Same path — no action needed
  if [[ "$old_path" == "$new_path" ]]; then
    FILES_SKIPPED=$((FILES_SKIPPED + 1))
    return 0
  fi

  # Move file
  if [[ "$DRY_RUN" == true ]]; then
    print_info "[DRY RUN] Would move: $old_path → $new_path"
    FILES_MOVED=$((FILES_MOVED + 1))
    return 0
  fi

  local new_dir
  new_dir=$(dirname "$full_new")
  mkdir -p "$new_dir"

  if mv "$full_old" "$full_new" 2>/dev/null; then
    print_success "Moved: $old_path → $new_path"
    FILES_MOVED=$((FILES_MOVED + 1))
  else
    print_error "Failed to move: $old_path → $new_path"
    ERROR_LOG+=("MOVE failed: $old_path → $new_path")
    FILES_ERRORS=$((FILES_ERRORS + 1))
  fi
}

run_migration() {
  echo -e "\n${CYAN}━━━ Migrating Files ━━━${NC}\n"

  for mapping in "${PATH_MAP[@]}"; do
    local old_path="${mapping%%|*}"
    local new_path="${mapping##*|}"
    migrate_file "$old_path" "$new_path"
  done
}

# ─── Write Migration Marker ─────────────────────────────────────────────────
write_marker() {
  if [[ "$DRY_RUN" == true ]]; then
    print_info "[DRY RUN] Would write migration marker (v$MIGRATION_VERSION)"
    return 0
  fi

  cat > "$MIGRATION_MARKER" <<EOF
$MIGRATION_VERSION
migrated_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
backup=$BACKUP_DIR
EOF

  print_success "Migration marker written (v$MIGRATION_VERSION)"
}

# ─── Summary ─────────────────────────────────────────────────────────────────
show_summary() {
  echo -e "\n${CYAN}━━━ Migration Summary ━━━${NC}\n"

  if [[ "$DRY_RUN" == true ]]; then
    echo -e "  ${BOLD}[DRY RUN] No changes were made${NC}"
    echo ""
  fi

  echo -e "  Files moved/removed : ${GREEN}$FILES_MOVED${NC}"
  echo -e "  Files skipped       : ${DIM}$FILES_SKIPPED${NC}"
  echo -e "  Errors              : ${RED}$FILES_ERRORS${NC}"

  if [[ ${#ERROR_LOG[@]} -gt 0 ]]; then
    echo ""
    echo -e "  ${RED}Errors:${NC}"
    for err in "${ERROR_LOG[@]}"; do
      echo -e "    ${RED}•${NC} $err"
    done
  fi

  echo ""
  if [[ "$DRY_RUN" != true ]]; then
    echo -e "  ${BOLD}Next steps:${NC}"
    echo -e "    1. Run: ${CYAN}./scripts/install.sh --team <your-team>${NC}"
    echo -e "    2. This will install the correct team-specific configs"
    echo -e "    3. Restart Kiro or reconnect MCP"
    echo ""
    echo -e "  ${DIM}Backup: $BACKUP_DIR${NC}"
  fi
}

# ─── Main ────────────────────────────────────────────────────────────────────
main() {
  echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║${NC}  ${BOLD}🔄 Kiro Governance Kit — Migration Script v3.0${NC}           ${BLUE}║${NC}"
  echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"

  parse_args "$@"

  # Check ~/.kiro/ exists
  if [[ ! -d "$KIRO_DIR" ]]; then
    die "~/.kiro/ directory not found. Nothing to migrate.\nRun install.sh instead." 1
  fi

  # Idempotency check
  check_already_migrated

  # Create backup (before any changes)
  create_backup

  # Run migration
  run_migration

  # Write marker on success (only if not dry-run and no fatal errors)
  if [[ "$DRY_RUN" != true ]]; then
    write_marker
  fi

  # Show summary
  show_summary
}

main "$@"
