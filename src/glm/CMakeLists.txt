# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# ogl-math Copyright
# Copyright (c) 2005 - 2013 G-Truc Creation (www.g-truc.net)

# ogl-math from sourceforge.net 0.9.4.3 2013-04-26
# http://sourceforge.net/projects/ogl-math/

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
    add_custom_command( 
        OUTPUT ${inc_output}
        COMMAND ${build_download}
        COMMAND ${build_uncompress}
        COMMAND ${build_include}
    )

endif()

# custom target, always build
add_custom_target(
    ${project_name} ALL
    DEPENDS ${inc_output}
)
