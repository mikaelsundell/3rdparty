#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
set -e

usage() {
    echo "Usage: $(basename "$0") [debug|release]"
}

if [[ "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi
configuration=${1:-debug}
if [[ $# -gt 1 || ( "$configuration" != "debug" && "$configuration" != "release" ) ]]; then
    usage >&2
    exit 2
fi

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo=$(cd "$script_dir/.." && pwd)
machine_arch=$(uname -m)
export THIRDPARTY_PREFIX="$repo/build/macosx/$machine_arch.$configuration"
if [[ ! -d "$THIRDPARTY_PREFIX/bin" || ! -f "$THIRDPARTY_PREFIX/CMakeCache.txt" ]]; then
    echo "SDK prefix not built: $THIRDPARTY_PREFIX" >&2
    echo "Run ./build.sh $configuration from the repository root first." >&2
    exit 1
fi

# Use installed Mach-O paths rather than inherited overrides from another SDK.
unset DYLD_LIBRARY_PATH DYLD_FRAMEWORK_PATH DYLD_FALLBACK_LIBRARY_PATH
unset DYLD_FALLBACK_FRAMEWORK_PATH DYLD_IMAGE_SUFFIX

# Use the interpreter that configured this SDK, including its Python ABI.
THIRDPARTY_PYTHON=$(awk '/^(Python3_EXECUTABLE|_Python3_EXECUTABLE):[^=]*=/ {
    print substr($0, index($0, "=") + 1)
    exit
}' "$THIRDPARTY_PREFIX/CMakeCache.txt")
if [[ ! -x "$THIRDPARTY_PYTHON" ]]; then
    echo "Configured Python is unavailable: $THIRDPARTY_PYTHON" >&2
    echo "Reconfigure the SDK with an available Python interpreter." >&2
    exit 1
fi
export THIRDPARTY_PYTHON
SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
export SDKROOT
deployment_target=$(awk '/^CMAKE_OSX_DEPLOYMENT_TARGET:[^=]*=/ {
    print substr($0, index($0, "=") + 1)
    exit
}' "$THIRDPARTY_PREFIX/CMakeCache.txt")
if [[ -n "$deployment_target" ]]; then
    export MACOSX_DEPLOYMENT_TARGET="$deployment_target"
    export CMAKE_OSX_DEPLOYMENT_TARGET="$deployment_target"
else
    unset MACOSX_DEPLOYMENT_TARGET CMAKE_OSX_DEPLOYMENT_TARGET
fi
python_version=$("$THIRDPARTY_PYTHON" -I -c 'import sys; print("%s.%s" % sys.version_info[:2])')

# Opening Release from a Debug SDK shell must start with the original paths.
if [[ -z "${THIRDPARTY_BASE_PATH+x}" ]]; then
    export THIRDPARTY_BASE_PATH="$PATH"
    export THIRDPARTY_BASE_PYTHONPATH="${PYTHONPATH:-}"
    export THIRDPARTY_BASE_CMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH:-}"
    export THIRDPARTY_BASE_PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}"
fi
export PATH="$script_dir/mac:$THIRDPARTY_PREFIX/bin:$THIRDPARTY_PREFIX/ninja:$THIRDPARTY_PREFIX/libexec:$THIRDPARTY_PREFIX/libjpeg-turbo/bin:$THIRDPARTY_BASE_PATH"
export PYTHONPATH="$THIRDPARTY_PREFIX/site-packages:$THIRDPARTY_PREFIX/lib/python$python_version/site-packages:$THIRDPARTY_PREFIX/python/OpenEXR:$THIRDPARTY_PREFIX/lib/python${THIRDPARTY_BASE_PYTHONPATH:+:$THIRDPARTY_BASE_PYTHONPATH}"
export CMAKE_PREFIX_PATH="$THIRDPARTY_PREFIX${THIRDPARTY_BASE_CMAKE_PREFIX_PATH:+:$THIRDPARTY_BASE_CMAKE_PREFIX_PATH}"
export PKG_CONFIG_PATH="$THIRDPARTY_PREFIX/lib/pkgconfig:$THIRDPARTY_PREFIX/share/pkgconfig:$THIRDPARTY_PREFIX/pkgconfig${THIRDPARTY_BASE_PKG_CONFIG_PATH:+:$THIRDPARTY_BASE_PKG_CONFIG_PATH}"

cd "$repo"
export PS1="[3rdparty $configuration] %~ %# "
printf '3rdparty SDK (%s)\nPrefix: %s\nPython: %s\nType exit to return.\n' "$configuration" "$THIRDPARTY_PREFIX" "$THIRDPARTY_PYTHON"
# Skip user startup files so they cannot replace the selected SDK environment.
exec /bin/zsh -f -i
