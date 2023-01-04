#!/bin/bash
##-*****************************************************************************
##  Copyright 2012-2014 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  find_python.sh - change dynamic shared library install names
##
##-*****************************************************************************

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

# parse arguments

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

# test arguments

if [ ! $PYTHON3 ] && [ ! $VERSION ] && [ ! $INCLUDEDIR ] && [ ! $LIBRARYDIR ]; then
    usage
    exit 1
fi

# executable

if [ $PYTHON3 ]; then
    echo `which python3`
fi

# version

if [ $VERSION ]; then
    echo `python3 -c \
        "import sys; \
         print(sys.version)"`
fi

# include dirs

if [ $INCLUDEDIR ]; then
    echo `python3 -c \
        "from distutils.sysconfig \
         import get_python_inc; \
         print(get_python_inc())"`
fi

# library dirs

if [ $LIBRARYDIR ]; then
    echo `python3 -c \
        "import distutils.sysconfig as sysconfig; \
         print(sysconfig.get_config_var('LIBDIR'))"`
fi
