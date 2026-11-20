#!/bin/bash
##  Copyright 2022-present Contributors to the 3rdparty project.
##  SPDX-License-Identifier: BSD-3-Clause
##  https://github.com/mikaelsundell/3rdparty

set -e

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
if ! command -v cmake >/dev/null 2>&1; then
    export PATH="$PATH:/Applications/CMake.app/Contents/bin"
fi

exec python3 "$script_dir/build.py" "$@"
