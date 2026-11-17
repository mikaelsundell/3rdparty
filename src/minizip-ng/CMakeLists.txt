# Copyright 2026-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: minizip-ng-4.2.2
# Archive: minizip-ng-4.2.2.tar.gz
# Upstream copyright and license notices: licenses/third-party/minizip-ng/

build_info( " Adding minizip-ng project" )

# project configuration

# project name
set( project_name "minizip-ng" )

# project pkg
set( project_pkg "minizip-ng-4.2.2" )

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

# inc files
set( inc_output
    ${build_inc_dir}/minizip-ng/mz.h
)

# inc dir
set( inc_dir
    minizip-ng
)

# lib files
set( lib_files
    minizip-ng
)

# pkgfiles
set( pkg_files
    pkgconfig/minizip-ng.pc
    cmake/minizip-ng/minizip-ng-config.cmake
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
    set( lib_version "4.2.2" )

    foreach( lib_file ${lib_files} )

        if ( APPLE )
            if( CMAKE_SHARED_LIBS )
                list( APPEND lib_output
                    ${build_lib_dir}/${lib_prefix}${lib_file}.${lib_version}${lib_suffix}
                )
            else()
                list( APPEND lib_output
                    ${build_lib_dir}/${lib_prefix}${lib_file}${lib_suffix}
                )
            endif()
        endif()
    endforeach()

    # pkg files
    build_add_files( 
        "${pkg_files}" "${build_lib_dir}" pkg_output
    )
endif()

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
        SET( build_options -DBUILD_SHARED_LIBS=true )
    else()
        SET( build_options -DBUILD_SHARED_LIBS=false )
    endif()

    # config
    set( build_config
        -DMZ_COMPAT=OFF
        -DMZ_ZLIB=ON
        -DMZ_ZLIB_FLAVOR=zlib
        -DMZ_BZIP2=ON
        -DMZ_LZMA=OFF
        -DMZ_PPMD=OFF
        -DMZ_ZSTD=OFF
        -DMZ_LIBCOMP=OFF
        -DMZ_PKCRYPT=OFF
        -DMZ_WZAES=OFF
        -DMZ_OPENSSL=OFF
        -DMZ_LIBBSD=OFF
        -DMZ_ICONV=OFF
        -DMZ_FETCH_LIBS=OFF
        -DMZ_BUILD_TESTS=OFF
        -DMZ_BUILD_UNIT_TESTS=OFF
    )

    # configure, make and install
    set( build_make
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
    set( build_output ${inc_output} ${lib_output} ${pkg_output} )
    
    build_install_script( 
        "${lib_output}" 
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
        OUTPUT ${build_output} ${dir_output}
        COMMAND ${build_download}
        COMMAND ${build_uncompress}
        COMMAND ${build_make}
        COMMAND ${build_script}
        COMMAND ${build_check}
    )

endif()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)

# dependencies
build_add_dependencies( ${project_name} bzip2 zlib-ng )
