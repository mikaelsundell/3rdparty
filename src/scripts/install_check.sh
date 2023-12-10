#!/bin/bash
##  Copyright 2022-present Contributors to the 3rdparty project.
##  SPDX-License-Identifier: BSD-3-Clause
##  https://github.com/mikaelsundell/3rdparty

# usage

usage()
{
cat << EOF
install_check.sh -- Check argument files

usage: $0 [options] files

Options:
   -h, --help              Print help message
   -v, --verbose           Print verbose
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
        -v|--verbose)
            VERBOSE=1;;
        *) 

            FILES[$findex]="${ARG}"
            findex=$((findex + 1))
    esac
    i=$((i + 1))
done

# check files
for i in ${FILES[@]}
do
    if [ -f "${i}" ]; then
        echo -e "Install check valid for file '${i}'${reset}"
    else 
        echo -e "Install check failed for file '${i}'"
        exit 1
    fi
done
