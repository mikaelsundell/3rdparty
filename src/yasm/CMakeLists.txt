##-*****************************************************************************
##  Copyright 2012-2022 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  yasm CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# yasm Copyright
# Copyright (c) 2001-2007 Peter Johnson

# yasm from www.tortall.net 1.2.0 2014-02-03
# http://www.tortall.net/projects/yasm/releases

build_info( " Adding yasm project" )

# project configuration

# project name
set( project_name "yasm" )

# project pkg
set( project_pkg ${project_name}-1.3.0 )

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
    vsyasm
    yasm
    ytasm
)

# inc dirs
set( inc_dirs
    libyasm-stdint.h
    libyasm.h
)

# lib files
set( lib_files
    yasm
)

# pkgfiles
set( pkg_files
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
    # yasm only provides static libraries
    build_add_libs( 
        "${lib_files}" "${build_lib_dir}" ${lib_prefix} ${static_lib_suffix} lib_output
    )

    # pkg files
    build_add_files( 
        "${pkg_files}" "${build_lib_dir}/pkgconfig" pkg_output
    )
    
endif()

# build configuration

# unix

IF( UNIX )

    # download
    SET( build_download 
        ${download} ${project_url}
    )

    # tar uncompress
    SET( build_uncompress
        ${untar} ${project_bin_dir}/${project_arc} -C ${project_bin_dir}
    )

    # configure, make and install
    SET( build_make
        ${build_env} &&
        cd ${project_pkg} &&
        ./configure 
            --prefix=${build_dir}
            CFLAGS=-I${build_inc_dir}
            CPPFLAGS=-I${build_inc_dir}
            LDFLAGS=-L${build_lib_dir}
            ${build_options} &&
        make ${build_flags} &&
        make install
    )

    # scripts
    set( build_output ${bin_output} ${lib_output} )

    build_add_check( 
        "${build_output}" 
        build_check
    )

    # run
    ADD_CUSTOM_COMMAND( 
        OUTPUT ${bin_output} ${lib_output}
        COMMAND ${build_download}
        COMMAND ${build_uncompress}
        COMMAND ${build_make}
        COMMAND ${build_check}
    )

endif()

# custom target, always build
add_custom_target(
    ${project_name} ALL
    DEPENDS ${bin_output} ${lib_output}
)
