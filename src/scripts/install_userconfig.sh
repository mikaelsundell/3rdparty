#!/bin/bash
##  Copyright 2022-present Contributors to the 3rdparty project.
##  SPDX-License-Identifier: BSD-3-Clause
##  https://github.com/mikaelsundell/3rdparty
# usage

usage()
{
cat << EOF
install_userconfig.sh -- install user-config file for python3

usage: $0 [options] files

Options:
   -h, --help              Print help message
   -p, --python3           Python3 executable 
   -v, --version           Python3 version
   -id, --include-dir      Python3 include dir
   -ld, --library-dir      Python3 library dir
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
            i=$((i + 1)); 
            PYTHON3=${argv[$i]};;
        -v|--version)
            i=$((i + 1)); 
            VERSION=${argv[$i]};;
        -id|--include-dir) 
            i=$((i + 1)); 
            INCLUDEDIR=${argv[$i]};;
        -ld|--library-dir) 
            i=$((i + 1)); 
            LIBRARYDIR=${argv[$i]};;
        *) 
            FILES[$findex]="${ARG}"
            findex=$((findex + 1))
    esac
    i=$((i + 1))
done

# test arguments

if [ -z "${PYTHON3}" ] || [ -z "${VERSION}" ] || [ -z "${INCLUDEDIR}" ] || [ -z "${LIBRARYDIR}" ] ; then
    usage
    exit 1
fi

# install user-config for files

for i in ${FILES[@]}
do
    echo "using python : ${VERSION} : ${PYTHON3} : ${INCLUDEDIR} : ${LIBRARYDIR} ;" > ${i}

done
