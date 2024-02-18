#!/bin/bash
##  Copyright 2022-present Contributors to the 3rdparty project.
##  SPDX-License-Identifier: BSD-3-Clause
##  https://github.com/mikaelsundell/3rdparty

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
machine_arch=$(uname -m)

# major version
parse_args() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --target=*) major_version="${1#*=}"; shift ;;
            *) shift ;;
        esac
    done
}
parse_args "$@"

if [ -z "$major_version" ]; then
    macos_version=$(sw_vers -productVersion)
    major_version=$(echo "$macos_version" | cut -d '.' -f 1)
fi

# exports
export MACOSX_DEPLOYMENT_TARGET=$major_version
export CMAKE_OSX_DEPLOYMENT_TARGET=$major_version

# exit on error
set -e 

build_type="$1"
if [ "$build_type" != "debug" ] && [ "$build_type" != "release" ] && [ "$build_type" != "all" ]; then
    echo "invalid build type: $build_type (use 'debug', 'release', or 'all')"
    exit 1
fi

clear
echo "Building 3rdparty for $build_type"
echo "---------------------------------"

# check if cmake is in the path
if ! command -v cmake &> /dev/null; then
    echo "cmake not found in the PATH, will try to set to /Applications/CMake.app/Contents/bin"
    export PATH=$PATH:/Applications/CMake.app/Contents/bin
    if ! command -v cmake &> /dev/null; then
        echo "cmake could not be found, please make sure it's installed"
        exit 1
    fi
fi

# check if numpy is installed
if ! python3 -c "import numpy" &>/dev/null; then
    echo "python3 numpy could not be found, please install using \"pip3 install numpy\""
    exit 1
fi

# build qt
qt_name="qt-everywhere-src-6.6.0"
qt_url="https://mikaelsundell.s3.eu-west-1.amazonaws.com/3rdparty/$qt_name.tar.gz"
build_qt() {
    mkdir -p "$script_dir/qt"
    cd "$script_dir/qt"
    if [ ! -f "$qt_name.tar.gz" ]; then
        echo "Downloading Qt from: $qt_url"
        curl -O -L "$qt_url"
        tar -xvf "$qt_name.tar.gz"
    fi

    if [ ! -f "$qt_name" ]; then
        echo "Path Qt: $qt_name"
        echo "Set Qt deployment target to: $major_version"
    fi
}

if [ ! -d "$script_dir/qt/$qt_name" ]; then
    build_qt
fi

# build 3rdparty
build_3rdparty() {
    local build_type="$1"

    # cmake
    export PATH=$PATH:/Applications/CMake.app/Contents/bin &&

    # set an alias for Python
    alias python=/usr/bin/python3 &&

    # script dir
    cd "$script_dir"

    # make base
    echo "Build 3rdparty base for type: $build_type"
    echo "MacOS target: $major_version"
    make verbose=1 build_base=1 $build_type &&

    # path
    export PATH=$PATH:"$script_dir/build/macosx/$machine_arch.$build_type/ninja" &&

    # build
    echo "Build Qt for type: $build_type"
    cd "qt/$qt_name" &&

    # deployment target
    export MACOSX_DEPLOYMENT_TARGET=$major_version &&
    echo "Qt deployment target: $major_version"
      
    if [ -d "build.$build_type" ]; then
        # reuse existing build
        echo "Qt build for type: $build_type exists, will reuse"
        cd build.$build_type
    else
        # create new build
        mkdir build.$build_type &&
        cd build.$build_type &&

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
            -DBUILD_qtmultimedia=OFF
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
            -DQT_FEATURE_system_freetype=ON
            -DQT_FEATURE_system_zlib=ON
            -DCMAKE_OSX_DEPLOYMENT_TARGET=$major_version
            -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
        )

        echo "Build Qt for type: $build_type"
        cmake .. -DCMAKE_INSTALL_PREFIX="$script_dir/build/macosx/$machine_arch.$build_type" -DCMAKE_PREFIX_PATH="$script_dir/build/macosx/$machine_arch.$build_type" "${qt_params[@]}" -G"Ninja Multi-Config" && 
        cmake --build . --parallel
    fi

    # ninja install Qt
    ninja install  &&

    # make extras
    echo "Build 3rdparty extras for type: $build_type"
    cd "$script_dir"
    make verbose=1 build_libs=1 build_extras=1 $build_type
}

build_clean() {
    cd "$script_dir"
    echo "Clean 3rdparty for all"
    make clean
}

# build types
if [ "$build_type" == "all" ]; then
    build_clean
    build_3rdparty "debug"
    build_3rdparty "release"
else
    build_3rdparty "$build_type"
fi
