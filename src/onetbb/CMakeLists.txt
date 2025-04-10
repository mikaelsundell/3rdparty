# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# onetbb Copyright
# Copyright (c) 2005-2021 Intel Corporation

# onetbb from github.com 2022.0.0 2025-03-06
# https://github.com/uxlfoundation/oneTBB/releases/tag/v2022.0.0

build_info( " Adding onetbb project" )

# project configuration

# project name
set( project_name "onetbb" )

# project pkg
set( project_pkg oneTBB-2022.0.0 )

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
    tbbmalloc
    tbbmalloc_proxy
)

if( UNIX )

    # bin files
    build_add_files( 
        "${bin_files}" "${build_bin_dir}" bin_output
    )

    # inc dir
    build_add_dir( 
        "${inc_dir}" "${build_inc_dir}" dir_output
    )

    # lib files
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        set( lib_dtag "_debug" )
    endif()

    set( default_version "12.14" )
    set( tbb_version "2.14" )
    
    foreach( lib_file ${lib_files} )
        if( lib_file MATCHES "malloc|proxy" )
            set( lib_version "${tbb_version}" )
        else()
            set( lib_version "${default_version}" )
        endif()
        
        list( APPEND lib_output 
            ${build_lib_dir}/${lib_prefix}${lib_file}${lib_dtag}.${lib_version}${lib_suffix}
        )
    endforeach()

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

    # options
    if( CMAKE_SHARED_LIBS )
        SET( build_options -DBUILD_SHARED_LIBS=TRUE )
    ELSE()
        SET( build_options -DBUILD_SHARED_LIBS=FALSE )
    ENDIF()

     # configure, make and install
     SET( build_make
        ${build_env} &&
        cd ${project_pkg} &&
        mkdir -p ${build_cmake} &&
        cd ${build_cmake} &&
        cmake ../ -DCMAKE_PREFIX_PATH=${build_dir}
            -DCMAKE_INSTALL_PREFIX=${build_dir}
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            ${build_options}
            ${build_config} &&
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
    DEPENDS ${lib_output}
)
