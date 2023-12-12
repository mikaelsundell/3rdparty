#!/bin/bash
##  Copyright 2022-present Contributors to the 3rdparty project.
##  SPDX-License-Identifier: BSD-3-Clause
##  https://github.com/mikaelsundell/3rdparty

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
machine_arch=$(uname -m)
macos_version=$(sw_vers -productVersion)
major_version=$(echo "$macos_version" | cut -d '.' -f 1)

# exit on error
set -e 

clear
echo "Building 3rdparty for $build_type"
echo "---------------------------------"

build_type="$1"
if [ "$build_type" != "debug" ] && [ "$build_type" != "release" ] && [ "$build_type" != "all" ]; then
    echo "invalid build type: $build_type (use 'debug', 'release', or 'all')"
    exit 1
fi

# check if cmake is in the path
if ! command -v cmake &> /dev/null; then
    echo "cmake not found in the PATH, will try to set to /Applications/CMake.app/Contents/bin"
    export PATH=$PATH:/Applications/CMake.app/Contents/bin
    if ! command -v cmake &> /dev/null; then
        echo "cmake could not be found, please make sure it's installed"
        exit 1
    fi
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
        # deployment target
        sed -i '' "s/QMAKE_MACOSX_DEPLOYMENT_TARGET = 12/QMAKE_MACOSX_DEPLOYMENT_TARGET = $major_version/g" $qt_name/qtbase/mkspecs/common/macx.conf
        # minimum version
        sed -i '' "s/QT_MAC_SDK_VERSION_MIN = 11/QT_MAC_SDK_VERSION_MIN = $major_version/g" $qt_name/qtbase/mkspecs/common/macx.conf
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
    make verbose=1 build_base=1 $build_type &&

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

        # configure Qt with the appropriate options
        echo "Build Qt for type: $build_type"
        ../configure -prefix "$script_dir/build/macosx/$machine_arch.$build_type" -libdir "$script_dir/build/macosx/$machine_arch.$build_type/lib" -opensource -confirm-license -system-libpng -system-libjpeg -system-zlib -system-pcre -system-harfbuzz -system-freetype -skip qtactiveqt -skip qtcharts -skip qtconnectivity -skip qtlocation -skip qtsensors -skip qtspeech -skip qtvirtualkeyboard -skip qtwayland -skip qtwebchannel -skip qtwebengine -skip qtwebview -I"$script_dir/build/macosx/$machine_arch.$build_type/include" -L"$script_dir/build/macosx/$machine_arch.$build_type/lib" $configure_options
    fi

    # make install Qt
    make install &&

    # make extras
    echo "Build 3rdparty extras for type: $build_type"
    cd "$script_dir" &&
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
