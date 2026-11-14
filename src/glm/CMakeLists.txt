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
SET( inc_dir
    glm
)

SET( inc_output
    ${build_inc_dir}/${inc_dir}
)

# build configuration

# unix

if( UNIX )

    # download
    set( build_download 
        ${download} ${project_url}
    )

    # tar uncompress
    set( build_uncompress
        ${untar} ${project_bin_dir}/${project_arc} -C ${project_bin_dir}
    )

    # copy include
    set( build_include
        cd ${project_pkg} &&
        ${make_dir} ${build_dir}/include &&
        ${copy_dir} ./glm ${build_dir}/include/glm
    )
	
    # run
    build_add_custom_command(
        OUTPUT ${inc_output}
        COMMAND ${build_download}
        COMMAND ${build_uncompress}
        COMMAND ${build_include}
    )

endif()

# Custom target builds missing or outdated installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${inc_output}
)
