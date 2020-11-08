##-*****************************************************************************
##  Copyright 2012-2014 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  gettext CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# gettext Copyright
# Copyright © 1992-1996, 1998-2012 Free Software Foundation, Inc.

# gettext from ftp.gnu.org 2014-02-04
# http://ftp.gnu.org/gnu/gettext/

build_info( " Adding gettext project" )

# project configuration

# project name
set( project_name "gettext" )

# project pkg
set( project_pkg ${project_name}-0.18.3.1)

# project archive
set( project_arc ${project_pkg}.tar.gz )

# project url
set( project_url ${repo_url}/${project_arc} )

# project src dir
set( project_src_dir
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# project bin dir
set( project_bin_dir
    ${CMAKE_CURRENT_BINARY_DIR}
)

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

# inc files
set( inc_files
    autosprintf.h
    gettext-po.h
)

if( APPLE )
    set( inc_files
        ${inc_files}
        libintl.h
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

# pkgfiles
set( pkg_files
)

if( UNIX )

    # bin files
    build_add_files( 
        "${bin_files}" "${build_bin_dir}" bin_output
    )

    # inc files
    build_add_files( 
        "${inc_files}" "${build_inc_dir}" inc_output
    )

    # lib files
    build_add_libs( 
        "${lib_files}" "${build_lib_dir}" ${lib_prefix} ${lib_suffix} lib_output
    )

    # pkg files
    build_add_files( 
        "${pkg_files}" "${build_lib_dir}/pkgconfig" pkg_output
    )
    
endif()

# build configuration

# unix

if( UNIX )

    # download
    set( build_download 
        ${download} ${project_url}
    )

    # tar uncompress
    set( build_uncompress
        ${untar} ${project_bin_dir}/${project_arc} -C ${project_bin_dir}
    )

    # options
    if( CMAKE_SHARED_LIBS )
        set( build_options --enable-shared --disable-static )
    else()
        set( build_options --enable-static --disable-shared )
    endif()

    # configure, make and install
    SET( build_make
        ${build_env} &&
        export PATH=${build_bin_dir}:$$PATH &&
        cd ${project_pkg} &&
        ./configure 
            --prefix=${build_dir}
            ${build_options} &&
        make ${build_flags} &&
        make install
    )

    # scripts
    
    IF ( APPLE )
    
        # build output

        SET( build_output ${bin_output} )

        IF ( CMAKE_SHARED_LIBS )
            SET( build_output ${build_output} ${lib_output} )
        ENDIF()
    
        SET( build_script 
            ${PROJECT_SOURCE_DIR}/src/scripts/install_name.sh 
                --prefix-lib ${build_prefix_lib}
                --prefix-framework ${build_prefix_framework}
                --absolute-path ${build_dir}
                ${build_output}
        )
    ENDIF()

    # scripts
    set( build_output ${bin_output} )

    if ( CMAKE_SHARED_LIBS )
        set( build_output ${build_output} ${lib_output} )
    endif()

    build_add_script( 
        "${build_output}" 
        ${build_dir} 
        ${build_prefix_lib} 
        ${build_prefix_framework} 
        build_script
    )

    build_add_check( 
        "${build_output}" 
        build_check
    )

    # run
    add_custom_command( 
        OUTPUT ${bin_output} ${lib_output}
        COMMAND ${build_download}
        COMMAND ${build_uncompress}
        COMMAND ${build_make}
        COMMAND ${build_script}
        COMMAND ${build_check}
    )     

ENDIF()

# custom target, always build
add_custom_target(
    ${project_name} ALL
    DEPENDS ${bin_output} ${lib_output}
)

# dependencies
add_dependencies( ${project_name} autoconf )

