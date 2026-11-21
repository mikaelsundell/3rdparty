#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
set -e
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
exec "$script_dir/3rdparty-shell.sh" "$@"
