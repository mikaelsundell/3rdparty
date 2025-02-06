#!/bin/bash
##  Copyright 2022-present Contributors to the 3rdparty project.
##  SPDX-License-Identifier: BSD-3-Clause
##  https://github.com/mikaelsundell/3rdparty

# usage

usage()
{
cat << EOF
install_pkg.sh -- install pkgconfig file

usage: $0 [options] files

Options:
   -h, --help              Print help message
   -v, --verbose           Print verbose
   -bp, --build-path       Path for the build files
   -dp, --dist-path        Path for the dist files
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
        -v|--verbose)
            VERBOSE=1;;
        -bp|--build-path) 
            i=$((i + 1)); 
            BUILDPATH=${argv[$i]};;
        -dp|--dist-path) 
            i=$((i + 1)); 
            DISTPATH=${argv[$i]};;
        *) 
            if ! test -e "${ARG}" ; then
                echo "Unknown argument or file '${ARG}'"
            else
                FILES[$findex]="${ARG}"
                findex=$((findex + 1))
            fi;;
    esac
    i=$((i + 1))
done

if [ -z "${BUILDPATH}" ] || [ -z "${DISTPATH}" ]; then
    usage
    exit 1
fi

os=`uname`
for i in ${FILES[@]}
do
    if [ ! -L "${i}" ]; then     
        if [ "${os}" == "Darwin" ]; then # double quotes needed for -i on darwin
            sed -i "" s="${BUILDPATH}"="${DISTPATH}"=g "${i}"
        else
            sed -i s="${BUILDPATH}"="${DISTPATH}"=g "${i}"
        fi            
        if [ $VERBOSE ]; then
            echo "Changed paths to '${DISTPATH}' for '${i}'"
        fi
    else
        if [ $VERBOSE ]; then
            echo "Symbolic link will be skipped '${i}'"
        fi
    fi
done
