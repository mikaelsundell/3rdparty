# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: glm-0.9.4.3
# Archive: glm-0.9.4.3.tar.gz
# Upstream copyright and license notices: licenses/third-party/glm/

build_info( " Adding glm project" )

# project configuration

# project name
set( project_name "glm" )

# project pkg
set( project_pkg ${project_name}-0.9.4.3 )

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
set( inc_dir glm )
set( inc_files glm/glm.hpp )

build_add_dir( "${inc_dir}" "${build_inc_dir}" dir_output )
build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )

# copy include
set( build_make
    COMMAND ${copy_dir} "${project_bin_dir}/${project_pkg}/${inc_dir}" "${build_inc_dir}/${inc_dir}"
)

set( build_output ${inc_output} )

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)
