#!/bin/bash
# This script applies the SUSFS patch for kernel version 5.4
#
# Derived from: https://github.com/Gamesmes90/android_kernel_oneplus_sm8350/blob/android-17/scripts/susfs/susfs_patch.sh
set -euo pipefail

PATCH_FILE=susfs_patch_to_5.4.patch
TARGET=android-17

REPO_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
GIT="${2:-}"

cd $REPO_ROOT

# Check if wiggle is installed
command -v wiggle >/dev/null || { echo "ERROR: wiggle not installed" >&2; exit 1; }

# Download patch from HEAD
curl -fsSL -o "$PATCH_FILE" \
    https://raw.githubusercontent.com/JackA1ltman/NonGKI_Kernel_Build_2nd/refs/heads/mainline/Patches/Patch/$PATCH_FILE

# Apply the patch
git apply --reject --whitespace=fix $PATCH_FILE || echo "WARNING: git apply left rejects, merging with wiggle"

# Check for rej files and merge them
failed=0
while IFS= read -r -d '' rej; do
  orig="${rej%.rej}"
  echo "Found reject file. Running wiggle on: $orig"
  if [ -f "$orig" ] && wiggle --replace "$orig" "$rej"; then
    echo "   Wiggle merged $orig successfully"
    rm -f "$rej" "$orig.porig"
  else
    echo "   ERROR: could not merge $orig" >&2
    failed=1
  fi
done < <(find . -type f -name '*.rej' -print0)

# Fail if merge failed
[ "$failed" -eq 0 ] || exit 1

if [ -z "$GIT" ]; then
    # Commit
    git add -u && git add '*.h' '*.c' 'Makefile'
    git commit -am "$1"
fi

# Delete patch file
rm $PATCH_FILE

exit 0