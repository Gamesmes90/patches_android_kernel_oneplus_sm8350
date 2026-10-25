#!/usr/bin/env bash

set -euo pipefail

if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    BOLD=''
    RESET=''
fi

info() { printf '%b%s%b\n' "$BLUE" "$1" "$RESET"; }
ok() { printf '%b%s%b\n' "$GREEN" "$1" "$RESET"; }
warn() { printf '%b%s%b\n' "$YELLOW" "$1" "$RESET"; }
err() { printf '%b%s%b\n' "$RED" "$1" "$RESET" >&2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${1:-}"
GIT="${2:-}"

echo $GIT

cd "$SCRIPT_DIR"

if [ -z "$REPO_ROOT" ]; then
    err "[ERROR] Missing kernel repository path."
    err "Usage: $0 /path/to/kernel/repo"
    exit 1
fi

if [ -z "$GIT" ]; then
    warn "[WARNING] Missing nogit argument, all changes will be commited."
elif [ "$GIT" = "nogit" ]; then
    info "Detected nogit argument, changes won't be commited."
fi

echo
printf '%b=======================================================%b\n' "$CYAN" "$RESET"
printf '%b  Kernel Repository: %s%b\n' "$BOLD" "$REPO_ROOT" "$RESET"
printf '%b=======================================================%b\n' "$CYAN" "$RESET"
echo

info "[1/4] Applying patches..."
if ! bash scripts/apply_patches.sh "$REPO_ROOT" "$GIT"; then
    err "[ERROR] Failed to apply patches."
    exit 1
fi
ok "  ✓ Patches applied successfully."

echo
info "[2/4] Initializing BakaSU..."
if ! bash scripts/init_bakasu.sh "$REPO_ROOT" "$GIT"; then
    err "[ERROR] Failed to initialize BakaSU."
    exit 1
fi
ok "  ✓ BakaSU initialized successfully."

echo
info "[3/4] Applying SUSFS Inline Hook..."
if ! bash scripts/susfs_inline_hook_patch.sh "$REPO_ROOT" "$GIT"; then
    err "[ERROR] Failed to apply SUSFS Inline Hook."
    exit 1
fi
ok "  ✓ SUSFS Inline Hook applied successfully."

echo
info "[4/4] Applying SUSFS Patch..."
if ! bash scripts/susfs_patch.sh "$REPO_ROOT" "$GIT"; then
    err "[ERROR] Failed to apply SUSFS Patch."
    exit 1
fi
ok "  ✓ SUSFS Patch applied successfully."

echo
ok "[OK] All steps completed successfully."