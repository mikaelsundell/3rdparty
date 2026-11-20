# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: harfbuzz-4.3.0
# Archive: harfbuzz-4.3.0.tar.gz
# Upstream copyright and license notices: licenses/third-party/harfbuzz/

build_info( " Adding harfbuzz project" )

# project configuration

# project name
set( project_name "harfbuzz" )

# project pkg
set( project_pkg ${project_name}-4.3.0 )

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
set( inc_files harfbuzz/hb.h harfbuzz/hb-subset.h )
build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )

# lib files
set( lib_files harfbuzz harfbuzz-subset )
build_add_libs( "${lib_files}" "${build_lib_dir}" "${lib_prefix}" "${lib_suffix}" lib_output )

# CMake package files
string( TOLOWER "${CMAKE_BUILD_TYPE}" build_variant )
set( cmake_files harfbuzzConfig.cmake "harfbuzzConfig-${build_variant}.cmake" )
build_add_files( "${cmake_files}" "${build_lib_dir}/cmake/harfbuzz" cmake_output )

# patch
if( WIN32 )
    build_patch_commands( "${project_bin_dir}/${project_pkg}" build_patch
        "${project_src_dir}/msvc/install-subset-runtime.patch"
    )
endif()

# configure, make and install
set( build_options
    -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
    # The upstream target refers to this before including GNUInstallDirs.
    -DCMAKE_INSTALL_INCLUDEDIR=include
)
build_cmake_commands( "${project_bin_dir}/${project_pkg}" build_make ${build_options} )

# scripts
if( CMAKE_SHARED_LIBS )
    build_install_script(
        "${lib_output}" "${build_dir}" "${build_prefix_lib}" "${build_prefix_framework}" build_script
    )
endif()

# run
set( build_output ${lib_output} ${inc_output} ${cmake_output} )
build_add_archive_rule()
add_custom_target( ${project_name} ALL DEPENDS ${build_output} )
