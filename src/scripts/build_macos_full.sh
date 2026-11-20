#!/bin/bash
##  Copyright 2022-present Contributors to the 3rdparty project.
##  SPDX-License-Identifier: BSD-3-Clause
##  https://github.com/mikaelsundell/3rdparty

set -e

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
machine_arch=$(uname -m)
build_type="$1"
major_version="$MACOSX_DEPLOYMENT_TARGET"

# check if numpy is installed
if ! python3 -c "import numpy" &>/dev/null; then
    echo "python3 numpy could not be found, please install it using \"pip3 install numpy\""
    exit 1
fi

# Check if typing_extensions is installed (required for Python < 3.11)
if ! python3 - <<EOF
import sys
# typing_extensions is only needed for Python < 3.11
if sys.version_info < (3, 11):
    import typing_extensions
EOF
then
    echo "python3: 'typing_extensions' module is missing for Python < 3.11."
    echo "Please install it via: pip3 install typing_extensions"
    exit 1
fi

# Check if pyopengl is installed
if ! python3 -c "import OpenGL" &>/dev/null; then
    echo "python3 PyOpenGL could not be found, please install it using: pip3 install PyOpenGL PyOpenGL-accelerate"
    exit 1
fi

# build qt
qt_name="qt-everywhere-src-6.10.1"
qt_url="https://mikaelsundell.s3.eu-west-1.amazonaws.com/3rdparty/$qt_name.tar.xz"
build_qt() {
    mkdir -p "$script_dir/qt"
    cd "$script_dir/qt"
    if [ ! -f "$qt_name.tar.xz" ]; then
        echo "Downloading Qt from: $qt_url"
        curl -O -L "$qt_url"
        tar -xJvf "$qt_name.tar.xz"
    fi

    if [ ! -f "$qt_name" ]; then
        echo "Path Qt: $qt_name"
        echo "Set Qt deployment target to: $major_version"
    fi
}

if [ ! -d "$script_dir/qt/$qt_name" ]; then
    build_qt
fi

# Keep source compatibility fixes reproducible for fresh and reused Qt trees.
python3 "$script_dir/src/scripts/patch_qt.py" "$script_dir/qt/$qt_name"

# build 3rdparty
build_3rdparty() {
    local build_type="$1"

    # set an alias for Python
    alias python=/usr/bin/python3 &&

    # script dir
    cd "$script_dir"

    # make base
    echo "Build 3rdparty base for type: $build_type"
    echo "MacOS target: $major_version"
    make verbose=1 build_base=1 build_libs=0 build_extras=0 $build_type || return $?

    # path
    export PATH=$PATH:"$script_dir/build/macosx/$machine_arch.$build_type/ninja" &&

    # build
    echo "Build Qt for type: $build_type"
    cd "qt/$qt_name" &&

    # deployment target
    export MACOSX_DEPLOYMENT_TARGET=$major_version &&
    echo "Qt deployment target: $major_version" || return $?

    mkdir -p "build.$build_type" &&
    cd "build.$build_type" &&

    # build minimum Qt
    # changing these will also change the output of PySide
    qt_params=(
        -DBUILD_qtactiveqt=OFF
        -DBUILD_qtcharts=OFF
        -DBUILD_qtcoap=OFF
        -DBUILD_qtconnectivity=OFF
        -DBUILD_qtdeclarative=OFF
        -DBUILD_qtdoc=OFF
        -DBUILD_qtgraphs=OFF
        -DBUILD_qtharfbuzz=OFF
        -DBUILD_qtlocation=OFF
        -DBUILD_qtlottie=OFF
        -DBUILD_qtmqtt=OFF
        -DBUILD_qtopcua=OFF
        -DBUILD_qtquick3d=OFF
        -DBUILD_qtquick3dphysics=OFF
        -DBUILD_qtquicktimeline=OFF
        -DBUILD_qtquickeffectmaker=OFF
        -DBUILD_qtremoteobjects=OFF
        -DBUILD_qtsensors=OFF
        -DBUILD_qtserialbus=OFF
        -DBUILD_qtspeech=OFF
        -DBUILD_qtvirtualkeyboard=OFF
        -DBUILD_qtwayland=OFF
        -DBUILD_qtwebchannel=OFF
        -DBUILD_qtwebengine=OFF
        -DBUILD_qtwebview=OFF
        -DFEATURE_dup3=OFF
        -DQT_FEATURE_system_freetype=ON
        -DQT_FEATURE_system_zlib=ON
        -DCMAKE_OSX_DEPLOYMENT_TARGET=$major_version
        -DCMAKE_OSX_SYSROOT=$SDKROOT
    ) || return $?

    echo "Build Qt for type: $build_type"
    cmake .. -DCMAKE_INSTALL_PREFIX="$script_dir/build/macosx/$machine_arch.$build_type" -DCMAKE_PREFIX_PATH="$script_dir/build/macosx/$machine_arch.$build_type" "${qt_params[@]}" -G"Ninja Multi-Config" &&
    cmake --build . --parallel &&

    # ninja install Qt
    ninja install || return $?

    # make extras
    echo "Build 3rdparty libs and extras for type: $build_type"
    cd "$script_dir"
    make verbose=1 build_libs=1 build_extras=1 $build_type
}

build_clean() {
    cd "$script_dir"
    echo "Clean 3rdparty for all"
    make clean
}

confirm_clean() {
    if [ -d "$script_dir/build" ]; then
        echo ""
        echo "Build directory already exists:"
        echo "  $script_dir/build"
        echo ""
        read -p "Do you really want to wipe it before building all configurations? (y/N): " answer
        case "$answer" in
            [yY]|[yY][eE][sS])
                echo "Cleaning build directory..."
                build_clean
                ;;
            *)
                echo "Skipping clean step."
                ;;
        esac
    fi
}

# build types
if [ "$build_type" == "all" ]; then
    confirm_clean
    build_3rdparty "debug"
    build_3rdparty "release"
else
    build_3rdparty "$build_type"
fi
