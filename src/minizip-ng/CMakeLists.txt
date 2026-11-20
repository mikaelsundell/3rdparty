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

# inc dir
set( inc_dir minizip-ng )
set( inc_files minizip-ng/mz.h minizip-ng/mz_zip.h )

# lib files
set( lib_files minizip-ng )

# pkg files
set( cmake_files minizip-ng-config.cmake )
if( WIN32 )
    list( APPEND cmake_files minizip-ng-config-version.cmake minizip-ng-targets.cmake )
else()
    build_add_files( "minizip-ng.pc" "${build_lib_dir}/pkgconfig" pkg_output )
endif()

build_add_dir( "${inc_dir}" "${build_inc_dir}" dir_output )
build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )
build_add_versioned_lib( "${lib_files}" 4.2.2 4 lib_output shared_output )
build_add_files( "${cmake_files}" "${build_lib_dir}/cmake/minizip-ng" cmake_output )

# build configuration

# options
set( build_options
    -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
    "-DCMAKE_PREFIX_PATH=${build_dir}"
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
    -DMZ_ICONV=OFF
    -DMZ_FETCH_LIBS=OFF
    -DMZ_BUILD_TESTS=OFF
    -DMZ_BUILD_UNIT_TESTS=OFF
)
if( WIN32 )
    list( APPEND build_options -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON )
else()
    list( APPEND build_options -DMZ_LIBBSD=OFF )
endif()

# scripts
if( shared_output )
    build_install_script(
        "${shared_output}" "${build_dir}" "${build_prefix_lib}" "${build_prefix_framework}" build_script
    )
endif()

set( build_output ${lib_output} ${inc_output} ${pkg_output} ${cmake_output} )

# configure, make and install
build_cmake_commands( "${project_bin_dir}/${project_pkg}" build_make ${build_options} )

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)

build_add_dependencies( ${project_name} bzip2 zlib-ng )
