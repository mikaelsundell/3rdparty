##-*****************************************************************************
##  Copyright 2012-2022 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  libtool CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# libtool Copyright
# Copyright © 1992-1996, 1998-2012 Free Software Foundation, Inc.

# libtool from ftp.gnu.org 2014-02-04
# http://ftp.gnu.org/gnu/libtool/

build_info( " Adding libtool project" )

# project configuration

# project name
set( project_name "libtool" )

# project pkg
set( project_pkg ${project_name}-2.4)

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
    libtool
    libtoolize
)

# inc files
set( inc_files
)

# lib files
set( lib_files
)

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
    
ENDIF()

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
    set( build_make
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
    set( build_output ${bin_output} )

    if ( CMAKE_SHARED_LIBS )
        set( build_output ${build_output} ${lib_output} )
    endif()

    build_install_script( 
        "${build_output}" 
        ${build_dir} 
        ${build_prefix_lib} 
        ${build_prefix_framework} 
        build_script
    )

    build_install_check( 
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

endif()

# custom target, always build
add_custom_target(
    ${project_name} ALL
    DEPENDS ${bin_output} ${lib_output}
)
