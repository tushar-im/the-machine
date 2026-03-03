#!/bin/bash
set -euo pipefail

# -------------------------------------------------------
# 🔫 build-handler — Gate-Driven Build System
# Used by: Reese (Software Engineer)
# -------------------------------------------------------
#
# A gate-driven build workflow manager for project scaffolding,
# cloning, planning, and milestone-based development.
#
# Usage: build-handler <command> [args...]
#
# Commands:
#   scaffold <name>          Create new project with create-01x-project
#   clone <repo-url>         Clone repo for direct work
#   clone-01x <repo-url>     Clone + overlay 01x agent system
#   seed <project> <text>    Write product seed from text
#   seed-file <project> <f>  Write product seed from file
#   plan <project>           Run planning agents via Claude Code
#   branch <project> <name>  Create feature branch
#   build-milestone <proj>   Build current milestone via Claude Code
#   merge <project>          Merge current branch to main
#   test <project>           Run project tests
#   diff <project>           Show current diff
#   resume <project>         Resume interrupted build
#   list                     List all projects
#   status <project>         Show project status
# -------------------------------------------------------

PROJECTS_DIR="/workspace/projects"
SHARED_DIR="/workspace/shared"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Ensure projects directory exists
mkdir -p "$PROJECTS_DIR"

# -------------------------------------------------------
# Command: scaffold
# -------------------------------------------------------
cmd_scaffold() {
    local name="${1:?Usage: build-handler scaffold <project-name>}"
    local project_dir="$PROJECTS_DIR/$name"

    if [ -d "$project_dir" ]; then
        log_error "Project '$name' already exists at $project_dir"
        exit 1
    fi

    log_info "Scaffolding project '$name'..."
    mkdir -p "$project_dir"
    cd "$project_dir"

    npx -y create-01x-project@latest ./ --name "$name" --yes 2>&1 || {
        log_warn "create-01x-project failed, creating minimal structure..."
        mkdir -p src tests docs
        echo "# $name" > README.md
        git init
        git add -A
        git commit -m "initial scaffold: $name"
    }

    # Write status file
    echo "scaffolded" > "$project_dir/.build-status"
    log_success "Project '$name' scaffolded at $project_dir"
    echo ""
    echo "🚪 GATE 1: Review scaffold and approve to proceed to planning."
}

# -------------------------------------------------------
# Command: clone
# -------------------------------------------------------
cmd_clone() {
    local repo_url="${1:?Usage: build-handler clone <repo-url>}"
    local name
    name=$(basename "$repo_url" .git)
    local project_dir="$PROJECTS_DIR/$name"

    if [ -d "$project_dir" ]; then
        log_error "Project '$name' already exists at $project_dir"
        exit 1
    fi

    log_info "Cloning $repo_url..."
    git clone "$repo_url" "$project_dir"
    echo "cloned" > "$project_dir/.build-status"
    log_success "Cloned to $project_dir"
}

# -------------------------------------------------------
# Command: clone-01x
# -------------------------------------------------------
cmd_clone_01x() {
    local repo_url="${1:?Usage: build-handler clone-01x <repo-url>}"
    local name
    name=$(basename "$repo_url" .git)
    local project_dir="$PROJECTS_DIR/$name"

    # First clone
    cmd_clone "$repo_url"

    # Then overlay 01x agent system
    log_info "Overlaying 01x agent system..."
    cd "$project_dir"
    npx -y create-01x-project@latest ./ --overlay --yes 2>&1 || {
        log_warn "01x overlay failed — project cloned without agent system."
    }

    echo "cloned-01x" > "$project_dir/.build-status"
    log_success "Cloned + 01x overlay applied at $project_dir"
}

# -------------------------------------------------------
# Command: seed
# -------------------------------------------------------
cmd_seed() {
    local project="${1:?Usage: build-handler seed <project> <seed-text>}"
    shift
    local seed_text="$*"
    local project_dir="$PROJECTS_DIR/$project"

    if [ ! -d "$project_dir" ]; then
        log_error "Project '$project' not found."
        exit 1
    fi

    echo "$seed_text" > "$project_dir/PRODUCT_SEED.md"
    echo "seeded" > "$project_dir/.build-status"
    log_success "Product seed written to $project_dir/PRODUCT_SEED.md"
}

# -------------------------------------------------------
# Command: seed-file
# -------------------------------------------------------
cmd_seed_file() {
    local project="${1:?Usage: build-handler seed-file <project> <file>}"
    local file="${2:?Usage: build-handler seed-file <project> <file>}"
    local project_dir="$PROJECTS_DIR/$project"

    if [ ! -d "$project_dir" ]; then
        log_error "Project '$project' not found."
        exit 1
    fi

    if [ ! -f "$file" ]; then
        log_error "Seed file '$file' not found."
        exit 1
    fi

    cp "$file" "$project_dir/PRODUCT_SEED.md"
    echo "seeded" > "$project_dir/.build-status"
    log_success "Product seed copied from $file to $project_dir/PRODUCT_SEED.md"
}

# -------------------------------------------------------
# Command: plan
# -------------------------------------------------------
cmd_plan() {
    local project="${1:?Usage: build-handler plan <project>}"
    local project_dir="$PROJECTS_DIR/$project"

    if [ ! -d "$project_dir" ]; then
        log_error "Project '$project' not found."
        exit 1
    fi

    log_info "Running planning agents for '$project'..."
    cd "$project_dir"

    # Use Claude Code to generate implementation plan
    if command -v claude &>/dev/null; then
        claude --print "Read PRODUCT_SEED.md and create a detailed implementation plan. Break it into milestones (M1, M2, M3...). Each milestone should be independently testable. Write the plan to IMPLEMENTATION_PLAN.md" 2>&1
    else
        log_warn "Claude Code not available. Create IMPLEMENTATION_PLAN.md manually."
    fi

    echo "planned" > "$project_dir/.build-status"
    log_success "Planning complete for '$project'."
    echo ""
    echo "🚪 GATE 2: Review IMPLEMENTATION_PLAN.md and approve to proceed to milestone build."
}

# -------------------------------------------------------
# Command: branch
# -------------------------------------------------------
cmd_branch() {
    local project="${1:?Usage: build-handler branch <project> <branch-name>}"
    local branch_name="${2:?Usage: build-handler branch <project> <branch-name>}"
    local project_dir="$PROJECTS_DIR/$project"

    if [ ! -d "$project_dir" ]; then
        log_error "Project '$project' not found."
        exit 1
    fi

    cd "$project_dir"
    git checkout -b "$branch_name"
    echo "$branch_name" > "$project_dir/.current-branch"
    log_success "Created and switched to branch '$branch_name'"
}

# -------------------------------------------------------
# Command: build-milestone
# -------------------------------------------------------
cmd_build_milestone() {
    local project="${1:?Usage: build-handler build-milestone <project>}"
    local project_dir="$PROJECTS_DIR/$project"

    if [ ! -d "$project_dir" ]; then
        log_error "Project '$project' not found."
        exit 1
    fi

    local current_branch
    current_branch=$(cat "$project_dir/.current-branch" 2>/dev/null || git -C "$project_dir" branch --show-current)

    log_info "Building milestone on branch '$current_branch' for '$project'..."
    cd "$project_dir"

    echo "building" > "$project_dir/.build-status"

    if command -v claude &>/dev/null; then
        claude --print "Read IMPLEMENTATION_PLAN.md. Build the current milestone (${current_branch}). Follow the spec exactly. Run tests when done. Report results." 2>&1
    else
        log_warn "Claude Code not available. Build milestone manually."
    fi

    echo "built" > "$project_dir/.build-status"
    log_success "Milestone build complete for '$project'."
    echo ""
    echo "🚪 GATE: Review changes. 👍 to merge, 🔧 for fixes, 👀 for diff."
}

# -------------------------------------------------------
# Command: merge
# -------------------------------------------------------
cmd_merge() {
    local project="${1:?Usage: build-handler merge <project>}"
    local project_dir="$PROJECTS_DIR/$project"

    if [ ! -d "$project_dir" ]; then
        log_error "Project '$project' not found."
        exit 1
    fi

    cd "$project_dir"
    local current_branch
    current_branch=$(git branch --show-current)

    if [ "$current_branch" = "main" ]; then
        log_error "Already on main branch. Nothing to merge."
        exit 1
    fi

    # Stage and commit any uncommitted changes
    git add -A
    git diff --cached --quiet || git commit -m "finalize: $current_branch"

    # Merge to main
    git checkout main
    git merge "$current_branch" --no-ff -m "merge: $current_branch"

    echo "merged" > "$project_dir/.build-status"
    rm -f "$project_dir/.current-branch"
    log_success "Merged '$current_branch' into main."
}

# -------------------------------------------------------
# Command: test
# -------------------------------------------------------
cmd_test() {
    local project="${1:?Usage: build-handler test <project>}"
    local project_dir="$PROJECTS_DIR/$project"

    if [ ! -d "$project_dir" ]; then
        log_error "Project '$project' not found."
        exit 1
    fi

    cd "$project_dir"
    log_info "Running tests for '$project'..."

    if [ -f "package.json" ] && grep -q '"test"' package.json; then
        npm test 2>&1
    elif [ -f "Makefile" ] && grep -q '^test:' Makefile; then
        make test 2>&1
    elif [ -f "Cargo.toml" ]; then
        cargo test 2>&1
    elif [ -d "tests" ]; then
        python3 -m pytest tests/ 2>&1 || python3 -m unittest discover tests/ 2>&1
    else
        log_warn "No test framework detected. Run tests manually."
    fi
}

# -------------------------------------------------------
# Command: diff
# -------------------------------------------------------
cmd_diff() {
    local project="${1:?Usage: build-handler diff <project>}"
    local project_dir="$PROJECTS_DIR/$project"

    if [ ! -d "$project_dir" ]; then
        log_error "Project '$project' not found."
        exit 1
    fi

    cd "$project_dir"
    echo "--- Staged Changes ---"
    git diff --cached --stat
    echo ""
    echo "--- Unstaged Changes ---"
    git diff --stat
    echo ""
    echo "--- Full Diff ---"
    git diff
    git diff --cached
}

# -------------------------------------------------------
# Command: resume
# -------------------------------------------------------
cmd_resume() {
    local project="${1:?Usage: build-handler resume <project>}"
    local project_dir="$PROJECTS_DIR/$project"

    if [ ! -d "$project_dir" ]; then
        log_error "Project '$project' not found."
        exit 1
    fi

    local status
    status=$(cat "$project_dir/.build-status" 2>/dev/null || echo "unknown")
    local branch
    branch=$(cat "$project_dir/.current-branch" 2>/dev/null || echo "main")

    log_info "Resuming project '$project'"
    echo "  Status: $status"
    echo "  Branch: $branch"
    echo ""

    cd "$project_dir"
    git checkout "$branch" 2>/dev/null || true

    log_success "Ready to continue. Check IMPLEMENTATION_PLAN.md for next steps."
}

# -------------------------------------------------------
# Command: list
# -------------------------------------------------------
cmd_list() {
    log_info "Projects in $PROJECTS_DIR:"
    echo ""

    if [ ! -d "$PROJECTS_DIR" ] || [ -z "$(ls -A "$PROJECTS_DIR" 2>/dev/null)" ]; then
        echo "  (no projects)"
        return
    fi

    for dir in "$PROJECTS_DIR"/*/; do
        local name
        name=$(basename "$dir")
        local status
        status=$(cat "$dir/.build-status" 2>/dev/null || echo "unknown")
        local branch
        branch=$(cat "$dir/.current-branch" 2>/dev/null || git -C "$dir" branch --show-current 2>/dev/null || echo "?")
        printf "  %-30s status=%-12s branch=%s\n" "$name" "$status" "$branch"
    done
}

# -------------------------------------------------------
# Command: status
# -------------------------------------------------------
cmd_status() {
    local project="${1:?Usage: build-handler status <project>}"
    local project_dir="$PROJECTS_DIR/$project"

    if [ ! -d "$project_dir" ]; then
        log_error "Project '$project' not found."
        exit 1
    fi

    local status
    status=$(cat "$project_dir/.build-status" 2>/dev/null || echo "unknown")
    local branch
    branch=$(git -C "$project_dir" branch --show-current 2>/dev/null || echo "?")
    local last_commit
    last_commit=$(git -C "$project_dir" log -1 --oneline 2>/dev/null || echo "no commits")

    echo ""
    echo "📋 Project: $project"
    echo "   Status:  $status"
    echo "   Branch:  $branch"
    echo "   Last:    $last_commit"
    echo "   Path:    $project_dir"
    echo ""

    # Show git status summary
    cd "$project_dir"
    echo "   Git Status:"
    git status --short | head -20 | sed 's/^/   /'
}

# -------------------------------------------------------
# Main dispatcher
# -------------------------------------------------------
COMMAND="${1:-help}"
shift || true

case "$COMMAND" in
    scaffold)        cmd_scaffold "$@" ;;
    clone)           cmd_clone "$@" ;;
    clone-01x)       cmd_clone_01x "$@" ;;
    seed)            cmd_seed "$@" ;;
    seed-file)       cmd_seed_file "$@" ;;
    plan)            cmd_plan "$@" ;;
    branch)          cmd_branch "$@" ;;
    build-milestone) cmd_build_milestone "$@" ;;
    merge)           cmd_merge "$@" ;;
    test)            cmd_test "$@" ;;
    diff)            cmd_diff "$@" ;;
    resume)          cmd_resume "$@" ;;
    list)            cmd_list ;;
    status)          cmd_status "$@" ;;
    help|--help|-h)
        echo "Usage: build-handler <command> [args...]"
        echo ""
        echo "Commands:"
        echo "  scaffold <name>          Create new project with create-01x-project"
        echo "  clone <repo-url>         Clone repo for direct work"
        echo "  clone-01x <repo-url>     Clone + overlay 01x agent system"
        echo "  seed <project> <text>    Write product seed from text"
        echo "  seed-file <project> <f>  Write product seed from file"
        echo "  plan <project>           Run planning agents via Claude Code"
        echo "  branch <project> <name>  Create feature branch"
        echo "  build-milestone <proj>   Build current milestone via Claude Code"
        echo "  merge <project>          Merge current branch to main"
        echo "  test <project>           Run project tests"
        echo "  diff <project>           Show current diff"
        echo "  resume <project>         Resume interrupted build"
        echo "  list                     List all projects"
        echo "  status <project>         Show project status"
        ;;
    *)
        log_error "Unknown command: $COMMAND"
        echo "Run 'build-handler help' for usage."
        exit 1
        ;;
esac
