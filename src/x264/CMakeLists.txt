##-*****************************************************************************
##  Copyright 2012-2022 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  x264 CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# x264 Copyright
# Copyright (C) 2003-2013 x264 project

# x264 from ftp.videolan.org 2014-02-04
# ftp://ftp.videolan.org/pub/videolan/x264/snapshots/

build_info( " Adding x264 project" )

# project configuration

# project name
set( project_name "x264" )

# project pkg
set( project_pkg ${project_name}-master )

# project archive
set( project_arc ${project_pkg}.tar.bz2 )

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
)

# inc files
set( inc_files
    x264.h
    x264_config.h
)

# lib files
set( lib_files
    x264.164
)

# pkgfiles
set( pkg_files
    x264.pc
)

IF( UNIX )

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
        set( build_options --enable-shared )
    else()
        set( build_options --enable-static )
    endif()

    # configure, make and install
    set( build_make
        ${build_env} &&
        export PATH=${build_bin_dir}:$$PATH &&
        export PKG_CONFIG_PATH=${build_lib_dir}/pkgconfig &&
        cd ${project_pkg} &&
        ./configure 
            --prefix=${build_dir} --disable-cli
            ${build_options} &&
        make ${build_flags} &&
        make install
    )

    # scripts
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

endif()

# custom target, always build
add_custom_target(
    ${project_name} ALL
    DEPENDS ${bin_output} ${lib_output}
)

# dependencies
add_dependencies( ${project_name} yasm )
