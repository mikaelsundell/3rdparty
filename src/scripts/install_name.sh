#!/bin/bash
##  Copyright 2022-present Contributors to the 3rdparty project.
##  SPDX-License-Identifier: BSD-3-Clause
##  https://github.com/mikaelsundell/3rdparty

# usage

usage()
{
cat << EOF
install_name.sh -- Change dynamic shared library install names

usage: $0 [options] files

Options:
   -h, --help              Print help message
   -v, --verbose           Print verbose
   -pl, --prefix-lib       Prefix for id and library install name
   -pf, --prefix-framework Prefix for id and framework install name
   -sd, --suffix-debug     Suffix for debug framework install name
   -ap, --absolute-path    Absolute path for the framework files
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
        -pl|--prefix-lib) 
            i=$((i + 1)); 
            PREFIXLIB=${argv[$i]};;
        -pf|--prefix-framework) 
            i=$((i + 1)); 
            PREFIXFRAMEWORK=${argv[$i]};;
        -sd|--suffix-debug) 
            i=$((i + 1)); 
            SUFFIXDEBUG=${argv[$i]};;
        -ap|--absolute-path) 
            i=$((i + 1)); 
            ABSOLUTEPATH=${argv[$i]};;
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

if [ -z "${PREFIXLIB}" ] || [ -z "${PREFIXFRAMEWORK}" ] || [ -z "${ABSOLUTEPATH}" ]; then
    usage
    exit 1
fi

RPATHS=( # portable rpaths
)

for i in ${FILES[@]}
do
    if [ ! -L "${i}" ]; then    
        FDIR=`dirName "${i}"`
        FNAME=`basename "${i}"`
        DNAME=       

        # change name
        if [[ `file "${i}" | grep 'shared library'` ]]; then        
            # debug                    
            if [ $SUFFIXDEBUG ] && [[ $FNAME = *"${SUFFIXDEBUG}" ]]; then
                DNAME="${FNAME}"
                FNAME=`echo "${FNAME}" | sed "s/${SUFFIXDEBUG}//g"`
            fi             
            if [[ `echo ${FDIR} | grep "${FNAME}.framework"` ]]; then
                if [ $DNAME ]; then
                    NAME="${PREFIXFRAMEWORK}/${FNAME}.framework/Versions/Current/${DNAME}"
                else
                    NAME="${PREFIXFRAMEWORK}/${FNAME}.framework/Versions/Current/${FNAME}"
                fi
            else
                NAME="${PREFIXLIB}"/"${FNAME}"
            fi
            install_name_tool -id "${NAME}" "${i}"
            if [ $VERBOSE ]; then
                echo "Changed shared library id to '${NAME}' for '${i}'"
            fi
        fi
        
        # changed dependent names
        LIBS=`otool -L "${i}" | tail -n+2 | awk '{print $1}'`        
        for l in ${LIBS[@]}
        do
            LDIR=`dirName "${l}"`
            LNAME=`basename ${l}`
            DNAME=
            DEPENDENTNAME=
            if [[ `echo ${LDIR} | grep "${ABSOLUTEPATH}"` ]] || [[ `echo ${LDIR} | grep "@rpath"` ]] || [ $LDIR == "." ]; then            
                # debug            
                if [ $SUFFIXDEBUG ] && [[ $LNAME = *"${SUFFIXDEBUG}" ]]; then
                    DNAME="${LNAME}"
                    LNAME=`echo "${LNAME}" | sed "s/${SUFFIXDEBUG}//g"`
                fi                        
                if [[ `echo ${LDIR} | grep "${LNAME}.framework"` ]]; then
                    if [ $DNAME ]; then
                        DEPENDENTNAME=${LNAME}.framework/Versions/Current/${DNAME}
                    else
                        DEPENDENTNAME=${LNAME}.framework/Versions/Current/${LNAME}
                    fi
                    NAME="${PREFIXFRAMEWORK}/${DEPENDENTNAME}"
                else
                    NAME="${PREFIXLIB}"/"${LNAME}"
                    DEPENDENTNAME=${NAME}
                fi

                INSTALLNAME=
                if [ -e "${NAME}" ]; then
                    INSTALLNAME=${NAME}
                    install_name_tool -change "${l}" "${NAME}" "${i}"
                else
                    for rpath in "${RPATHS[@]}"; do
                        if [ -e "${rpath}/${DEPENDENTNAME}" ]; then
                            INSTALLNAME=${rpath}/${DEPENDENTNAME}
                            break
                        fi
                    done
                fi

                if [ -n "${INSTALLNAME}" ]; then
                    install_name_tool -change "${l}" "${INSTALLNAME}" "${i}"
                    if [ $VERBOSE ]; then
                        echo "Changed dependent shared/framework library to '${INSTALLNAME}' for '${i}'"
                    fi
                fi
            fi        
        done        
    else
        if [ $VERBOSE ]; then
            echo "Symbolic link will be skipped '${i}'"
        fi
    fi
done
