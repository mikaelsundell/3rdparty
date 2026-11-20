# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: zlib-ng-2.3.3
# Archive: zlib-ng-2.3.3.tar.gz
# Upstream copyright and license notices: licenses/third-party/zlib-ng/

build_info( " Adding zlib-ng project" )

# project configuration

# project name
set( project_name "zlib-ng" )

# project pkg
set( project_pkg ${project_name}-2.3.3 )

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

# include files
set( inc_files zconf.h zlib.h zlib_name_mangling.h )
build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )

# lib files
if( WIN32 )
    set( lib_files zlib )
    if( NOT CMAKE_SHARED_LIBS )
        set( lib_files zlibstatic )
    endif()
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        string( APPEND lib_files "d" )
    endif()
    if( CMAKE_SHARED_LIBS )
        build_add_files( "${lib_files}1${CMAKE_SHARED_LIBRARY_SUFFIX}" "${build_bin_dir}" bin_output )
        build_add_files( "${lib_files}${CMAKE_IMPORT_LIBRARY_SUFFIX}" "${build_lib_dir}" lib_output )
    endif()
elseif( CMAKE_SHARED_LIBS )
    set( lib_files z.1.3.1.zlib-ng )
else()
    set( lib_files z )
endif()
if( NOT lib_output )
    build_add_libs( "${lib_files}" "${build_lib_dir}" "${lib_prefix}" "${lib_suffix}" lib_output )
endif()

# package files
string( TOLOWER "${CMAKE_BUILD_TYPE}" build_variant )
set( cmake_files
    zlib-config.cmake zlib-config-version.cmake ZLIB-targets.cmake "ZLIB-targets-${build_variant}.cmake"
)
build_add_files( zlib.pc "${build_lib_dir}/pkgconfig" pkg_output )
build_add_files( "${cmake_files}" "${build_lib_dir}/cmake/ZLIB" cmake_output )

# patch
if( WIN32 )
    build_patch_commands( "${project_bin_dir}/${project_pkg}" build_patch
        "${project_src_dir}/msvc/windows-pkg-config-library.patch"
    )
endif()

# configure, make and install
set( build_options
    -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
    -DZLIB_COMPAT=ON -DBUILD_TESTING=OFF
)
build_cmake_commands( "${project_bin_dir}/${project_pkg}" build_make ${build_options} )

# scripts
if( CMAKE_SHARED_LIBS )
    build_install_script(
        "${lib_output}" "${build_dir}" "${build_prefix_lib}" "${build_prefix_framework}" build_script
    )
endif()

# run
set( build_output ${lib_output} ${bin_output} ${inc_output} ${pkg_output} ${cmake_output} )
build_add_archive_rule()
add_custom_target( ${project_name} ALL DEPENDS ${build_output} )
