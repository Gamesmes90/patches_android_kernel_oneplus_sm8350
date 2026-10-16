#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
PATCHES_DIR="${3:-$(pwd)/patches}"
GIT="${2:-}"

if [ ! -d "$PATCHES_DIR" ]; then
    echo "Patches directory not found: $PATCHES_DIR" >&2
    exit 1
fi

cd "$REPO_ROOT"

find "$PATCHES_DIR" -type f \( -iname "*.patch" -o -iname "*.diff" \) | sort | while IFS= read -r patch; do
    echo "Applying: $(basename "$patch")"
    git apply --check --whitespace=nowarn < "$patch" || {
        echo "Patch failed validation: $patch" >&2
        exit 1
    }
    if [ -z "$GIT" ]; then
        git am --keep-cr --signoff "$patch"
    else
        git apply "$patch"
    fi
done

echo "All patches applied successfully."
