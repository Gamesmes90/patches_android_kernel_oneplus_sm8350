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

# Download patch from HEAD
curl -O https://raw.githubusercontent.com/JackA1ltman/NonGKI_Kernel_Build_2nd/refs/heads/mainline/Patches/Patch/$PATCH_FILE

# Apply the patch
git apply --reject --whitespace=fix $PATCH_FILE || true

# Check for rej files and merge them
rejs_found=0
while IFS= read -r -d '' rej; do
    rejs_found=1
    orig="${rej%.rej}"
    echo "Found reject file. Running wiggle on: $orig"
    
    if [ -f "$orig" ]; then
        if wiggle --replace "$orig" "$rej"; then
            echo "   Wiggle merged $orig successfully"
            rm -f "$rej" "$orig.porig"
        else
            echo "   Wiggle failed to merge $orig"
            rm -f "$orig.porig"
        fi
    else
        echo "   Error: The original file $orig for $rej does not exist"
    fi
done < <(find . -type f -name "*.rej" -print0)

# Output if no rej files are found
if [ "$rejs_found" -eq 0 ]; then
    echo "No .rej files found (the patch has been 100% applied or it failed from the start)."
fi

if [ -z "$GIT" ]; then
    # Commit
    git add -u && git add '*.h' '*.c' 'Makefile'
    git commit -am "$1"
fi

# Delete patch file
rm $PATCH_FILE

exit 0