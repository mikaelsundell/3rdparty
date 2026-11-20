# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: ninja-1.11.1
# Archive: ninja-1.11.1.tar.gz
# Upstream copyright and license notices: licenses/third-party/ninja/

build_info( " Adding ninja project" )

# project configuration

# project name
set( project_name "ninja" )

# project pkg
set( project_pkg ${project_name}-1.11.1 )

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
set( bin_files "ninja${CMAKE_EXECUTABLE_SUFFIX}" )
build_add_files( "${bin_files}" "${build_ninja_dir}" bin_output )

# configure, make and install
set( build_options
    -DBUILD_TESTING=OFF
    "-DCMAKE_INSTALL_BINDIR=${build_ninja_dir}"
)
build_cmake_commands( "${project_bin_dir}/${project_pkg}" build_make ${build_options} )

# run
set( build_output ${bin_output} )
build_install_script(
    "${build_output}" "${build_dir}" "${build_prefix_lib}" "${build_prefix_framework}" build_script
)
build_add_archive_rule()
add_custom_target( ${project_name} ALL DEPENDS ${build_output} )
