#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
GIT="${2:-}"

cd $REPO_ROOT

curl -LSs "https://raw.githubusercontent.com/Baka-SU/BakaSU/main/kernel/setup.sh" | bash

if [ -z "$GIT" ]; then
    git add drivers/Kconfig
    git add drivers/Makefile

    git commit -m "BakaSU"
fi