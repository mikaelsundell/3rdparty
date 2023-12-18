# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# nasm Copyright
# 1996-2017 The NASM Authors

# nasm from github.com 2.16.01
# https://github.com/netwide-assembler/nasm

build_info( " Adding nasm project" )

# project configuration

# project name
set( project_name "nasm" )

# project pkg
set( project_pkg ${project_name}-nasm-2.16.01 )

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
    nasm
    ndisasm
)

IF( UNIX )

    # bin files
    build_add_files( 
        "${bin_files}" "${build_bin_dir}" bin_output
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

    # configure, make and install
    set( build_make
        ${build_env} &&
        export PATH=${build_bin_dir}:$$PATH &&
        cd ${project_pkg} &&
        touch nasm.1 ndisasm.1 &&
        ./autogen.sh &&
        ./configure 
            --prefix=${build_dir}
            ${build_options} &&
        make nasm ndisasm ${build_flags} &&
        make install
    )

    # scripts
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
        OUTPUT ${bin_output}
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
    DEPENDS ${bin_output}
)

# dependencies
add_dependencies( ${project_name} automake )