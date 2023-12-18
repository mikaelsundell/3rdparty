# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# onetbb Copyright
# Copyright (c) 2005-2021 Intel Corporation

# onetbb from github.com 2018_U1 2022-03-19
# https://github.com/oneapi-src/oneTBB/archive/

build_info( " Adding onetbb project" )

# project configuration

# project name
set( project_name "onetbb" )

# project pkg
set( project_pkg ${project_name}-2018_U1 )

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
    tbb
)

# lib files
set( lib_files
    tbb
    tbb_debug
    tbbmalloc
    tbbmalloc_debug
    tbbmalloc_proxy
    tbbmalloc_proxy_debug
)

if( UNIX )

    # inc dir
    build_add_dir( 
        "${inc_dir}" "${build_inc_dir}" dir_output
    )

    # lib files
    build_add_libs( 
        "${lib_files}" "${build_lib_dir}" ${lib_prefix} ${lib_suffix} lib_output
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

    # options
    if( CMAKE_SHARED_LIBS )
        set( build_options --enable-shared --disable-static )
    else()
        set( build_options --enable-static --disable-shared )
    endif()

    set( build_options "arch=${lib_arch}" )

    # configure, make and install
    set( build_make
        ${build_env} &&
        cd ${project_pkg} &&
        make ${build_options} ${build_flags}
    )

    # copy include
    set( build_include
        cd ${project_pkg} &&
        ${make_dir} ${build_dir}/include &&
        ${copy_dir} ./include/tbb ${build_dir}/include/tbb &&
        ${copy_dir} ./include/serial ${build_dir}/include/serial
    )

    # copy libs
    if( APPLE )
        set( build_lib
            ${copy} ${project_pkg}/build/macos_*_debug/*.dylib ${build_dir}/lib &&
            ${copy} ${project_pkg}/build/macos_*_release/*.dylib ${build_dir}/lib
        )
    else()
        set( build_lib
            ${copy} ${project_pkg}/build/linux_*_debug/*.dylib ${build_dir}/lib &&
            ${copy} ${project_pkg}/build/linux_*_release/*.dylib ${build_dir}/lib
        )
    endif()

    # scripts
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
        COMMAND ${build_include}
        COMMAND ${build_lib}
        COMMAND ${build_script}
        COMMAND ${build_check}
    )

endif()

# custom target, always build
add_custom_target(
    ${project_name} ALL
    DEPENDS ${lib_output}
)
