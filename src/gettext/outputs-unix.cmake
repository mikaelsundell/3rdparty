# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# bin files
set( bin_files
    envsubst
    gettext
    gettext.sh
    gettextize
    msgattrib
    msgcat
    msgcmp
    msgcomm
    msgconv
    msgen
    msgexec
    msgfilter
    msgfmt
    msggrep
    msginit
    msgmerge
    msgunfmt
    msguniq
    ngettext
    recode-sr-latin
    xgettext
)

if( APPLE )
    set( bin_files
        ${bin_files}
        autopoint
    )
endif()

# lib files
if( APPLE )
    set( lib_files
        asprintf
        asprintf.0
        gettextlib
        gettextlib-0.18.3
        gettextpo
        gettextpo.0
        gettextsrc
        gettextsrc-0.18.3
        intl
        intl.8
    )
else()
    set( lib_files
        ${lib_prefix}asprintf${lib_suffix}
        ${lib_prefix}asprintf${lib_suffix}.0
        ${lib_prefix}asprintf${lib_suffix}.0.0.0
        ${lib_prefix}gettextlib${lib_suffix}
        ${lib_prefix}gettextlib-0.18.3${lib_suffix}
        ${lib_prefix}gettextpo${lib_suffix}
        ${lib_prefix}gettextpo${lib_suffix}.0
        ${lib_prefix}gettextpo${lib_suffix}.0.5.2
        ${lib_prefix}gettextsrc${lib_suffix}
        ${lib_prefix}gettextsrc-0.18.3${lib_suffix}
        preloadable_libintl${lib_suffix}
    )
endif()
