#!/bin/bash
##  Copyright 2022-present Contributors to the 3rdparty project.
##  SPDX-License-Identifier: BSD-3-Clause
##  https://github.com/mikaelsundell/3rdparty

# usage

usage()
{
cat << EOF
find_python.sh -- find python executable, include and library directories
usage: $0 [options]

Options:
   -h, --help              Print help message
   -p, --python3           Find python executable
   -v, --version           Find python version
   -id, --include-dir      Find python include dir
   -ld, --library-dir      Find python library dir
EOF
}

i=0; argv=()
for ARG in "$@"; do
    argv[$i]="${ARG}"
    i=$((i + 1))
done

i=0; findex=0
while test $i -lt $# ; do
    ARG="${argv[$i]}"
    case "${ARG}" in
        -h|--help) 
            usage;
            exit;;
        -p|--python3) 
            PYTHON3=1;;
        -v|--version) 
            VERSION=1;;    
        -id|--include-dir) 
            INCLUDEDIR=1;;
        -ld|--library-dir) 
            LIBRARYDIR=1;;
        *) 
            if ! test -e "${ARG}" ; then
                echo "Unknown argument: '${ARG}'"
            fi;;
    esac
    i=$((i + 1))
done

if [ ! $PYTHON3 ] && [ ! $VERSION ] && [ ! $INCLUDEDIR ] && [ ! $LIBRARYDIR ]; then
    usage
    exit 1
fi

if [ $PYTHON3 ]; then
    echo `which python3`
fi

if [ $VERSION ]; then
    echo `python3 -c \
        "import sys; \
         print(sys.version)"`
fi

if [ $INCLUDEDIR ]; then
    echo `python3 -c \
        "from distutils.sysconfig \
         import get_python_inc; \
         print(get_python_inc())"`
fi

if [ $LIBRARYDIR ]; then
    echo `python3 -c \
        "import distutils.sysconfig as sysconfig; \
         print(sysconfig.get_config_var('LIBDIR'))"` # this gives the library inside the framework
fi
