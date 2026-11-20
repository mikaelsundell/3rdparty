# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: nanobind-master-251225
# Archive: nanobind-master-251225.tar.gz
# Upstream copyright and license notices: licenses/third-party/nanobind/

build_info( " Adding nanobind project" )

# project configuration

# project name
set( project_name "nanobind" )

# project pkg
set( project_pkg "nanobind-master-251225" )

# project archive
set( project_arc ${project_pkg}.tar.gz )

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
set( inc_dir nanobind )
set( inc_files nanobind/nanobind.h )

# cmake files
set( cmake_files nanobind-config.cmake nanobind-config-version.cmake )

build_add_dir( "${inc_dir}" "${build_dir}/nanobind/include" dir_output )
build_add_files( "${inc_files}" "${build_dir}/nanobind/include" inc_output )
build_add_files( "${cmake_files}" "${build_dir}/nanobind/cmake" cmake_output )

# options
set( build_options "-DCMAKE_PREFIX_PATH=${build_dir}" )
if( WIN32 )
    list( APPEND build_options -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS} -DNB_TEST=OFF )
else()
    list( APPEND build_options -DCMAKE_VERBOSE_MAKEFILE=true )
endif()

# configure, make and install
build_cmake_commands( "${project_bin_dir}/${project_name}" build_make ${build_options} )

set( build_output ${inc_output} ${cmake_output} )

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)
