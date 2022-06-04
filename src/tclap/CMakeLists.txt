##-*****************************************************************************
##  Copyright 2012-2022 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  tclap CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# tclap Copyright
# Copyright (c) 2018 Google LLC
# All rights reserved.

# tclap from ourceforge.net 2022-03-29
# https://sourceforge.net/projects/tclap/

build_info( " Adding tclap project" )

# project configuration

# project name
set( project_name "tclap" )

# project pkg
set( project_pkg ${project_name}-1.2.5 )

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

# inc dir
set( inc_dir
    tclap
)

if( UNIX )

    # inc dir
    build_add_dir( 
        "${inc_dir}" "${build_inc_dir}" include_output
    )
    
ENDIF()

# build configuration

# unix

IF( UNIX )

    # download
    set( build_download 
        ${download} ${project_url}
    )

    # tar uncompress
    set( build_uncompress
        ${untar} ${project_bin_dir}/${project_pkg}.tar.gz -C ${project_bin_dir}
    )

    # configure, make and install
    set( build_make
        ${build_env} &&
        cd ${project_pkg} &&
        ./configure 
            --prefix=${build_dir}
            ${CFLAGS}
            CPPFLAGS=-I${build_inc_dir}
            LDFLAGS=-L${build_lib_dir} &&
        make ${build_flags} &&
        make install
    )

    # scripts
    if ( CMAKE_SHARED_LIBS )
        set( build_output ${build_output} ${lib_output} )
    endif()
    
    # run
    add_custom_command( 
        OUTPUT ${include_output}
        COMMAND ${build_download}
        COMMAND ${build_uncompress}
        COMMAND ${build_make}
    )

endif()

# custom target, always build
add_custom_target(
    ${project_name} ALL
    DEPENDS ${include_output}
)
