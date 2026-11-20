# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: pcre2-10.32
# Archive: pcre2-10.32.tar.gz
# Upstream copyright and license notices: licenses/third-party/pcre2/

build_info( " Adding pcre2 project" )

# project configuration

# project name
set( project_name "pcre2" )

# project pkg
set( project_pkg ${project_name}-10.32 )

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

# installed files
set( bin_files "pcre2grep${CMAKE_EXECUTABLE_SUFFIX}" "pcre2test${CMAKE_EXECUTABLE_SUFFIX}" )
set( inc_files pcre2.h pcre2posix.h )
set( lib_files pcre2-8 pcre2-16 pcre2-posix )
if( WIN32 AND CMAKE_BUILD_TYPE STREQUAL Debug )
    list( TRANSFORM lib_files APPEND "d" )
endif()
build_add_files( "${bin_files}" "${build_bin_dir}" bin_output )
build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )
build_add_libs( "${lib_files}" "${build_lib_dir}" "${lib_prefix}" "${lib_suffix}" lib_output )

# patch
build_patch_commands( "${project_bin_dir}/${project_pkg}" build_patch
    "${project_src_dir}/msvc/modern-cmake-tests.patch"
)

# configure, make and install
set( build_options
    -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
    "-DCMAKE_PREFIX_PATH=${build_dir}"
    -DPCRE2_BUILD_PCRE2_16=ON
)
build_cmake_commands( "${project_bin_dir}/${project_pkg}" build_make ${build_options} )

# scripts
if( CMAKE_SHARED_LIBS )
    build_install_script(
        "${lib_output}" "${build_dir}" "${build_prefix_lib}" "${build_prefix_framework}" build_script
    )
endif()

# run
set( build_output ${lib_output} ${bin_output} ${inc_output} )
build_add_archive_rule()
add_custom_target( ${project_name} ALL DEPENDS ${build_output} )

if( WIN32 )
    build_add_dependencies( ${project_name} bzip2 zlib-ng )
endif()
