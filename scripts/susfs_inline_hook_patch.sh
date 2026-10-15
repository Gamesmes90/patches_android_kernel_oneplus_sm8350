#!/bin/bash

REPO_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

cd $REPO_ROOT

wget https://raw.githubusercontent.com/JackA1ltman/NonGKI_Kernel_Build_2nd/refs/heads/mainline/Patches/susfs_inline_hook_patches.sh

bash susfs_inline_hook_patches.sh

rm susfs_inline_hook_patches.sh

git add .
git restore --staged drivers/kernelsu
git restore --staged KernelSU
git commit -m "SUSFS Inline Hook"