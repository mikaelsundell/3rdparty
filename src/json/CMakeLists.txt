# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: json-master-231214
# Archive: json-master-231214.tar.gz
# Upstream copyright and license notices: licenses/third-party/json/

build_info( " Adding json project" )

# project configuration

# project name
set( project_name "json" )

# project pkg
set( project_pkg ${project_name}-master-231214 )

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
set( inc_dir nlohmann )
set( inc_files
    nlohmann/json.hpp
    nlohmann/json_fwd.hpp
)

# pkg files
set( pkg_files nlohmann_json.pc )
set( cmake_files
    nlohmann_jsonConfig.cmake
    nlohmann_jsonConfigVersion.cmake
    nlohmann_jsonTargets.cmake
)

build_add_dir( "${inc_dir}" "${build_inc_dir}" dir_output )
build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )
build_add_files( "${pkg_files}" "${build_dir}/share/pkgconfig" pkg_output )
build_add_files( "${cmake_files}" "${build_dir}/share/cmake/nlohmann_json" cmake_output )

# build configuration

# options
set( build_options
    -DJSON_BuildTests=OFF
    -DJSON_Install=ON
)

# configure, make and install
build_cmake_commands( "${project_bin_dir}/${project_name}" build_make ${build_options} )

# run
set( build_output ${inc_output} ${pkg_output} ${cmake_output} )
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)
