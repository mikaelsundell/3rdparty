##-*****************************************************************************
##  Copyright 2012-2020 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  Pybind CMakeLists.txt for 3rdparty
##
##-*****************************************************************************

# Pybind Copyright
# Copyright (c) 2016 Wenzel Jakob <wenzel.jakob@epfl.ch>, All rights reserved.

# pybind from github.com 2.6.0 2020-11-07
# https://github.com/pybind/pybind11

build_info( " Adding pybind project" )

# project configuration

# project name
set( project_name "pybind" )

# lib pkg
set( project_pkg "pybind11-2.6.0" )

# project archive
set( project_arc ${project_pkg}.zip )

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
set( inc_dir
    pybind11
)

SET( inc_output
    ${build_inc_dir}/${inc_dir}
)

IF( UNIX )

    # inc dir
    build_add_dir( 
        "${inc_dir}" "${build_inc_dir}" dir_output
    )
    
ENDIF()

# build configuration

# unix

IF( UNIX )

    # download
    set( build_download 
        ${download} ${project_url}
    )

    # tar uncompress
    set( build_uncompress
        ${untar} ${project_bin_dir}/${project_arc} -C ${project_bin_dir}
    )

    # options
    set( build_options -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} )
    set( build_options ${build_options} -DCMAKE_VERBOSE_MAKEFILE=true )

    set( build_make
        ${build_make}
        cd ${project_pkg} &&
        mkdir ${build_cmake} &&
        cd ${build_cmake} &&
        export OIIO_PATH=${build_dir} &&
        cmake ../ -DCMAKE_PREFIX_PATH=${build_dir}
              -DCMAKE_INSTALL_PREFIX=${build_dir} ${build_options} &&
        make ${build_flags} &&
        make install
    )

    # run
    add_custom_command( 
        OUTPUT ${inc_output}
        COMMAND ${build_download}
        COMMAND ${build_uncompress}
        COMMAND ${build_include}
    )   

endif()

# custom target, always run
add_custom_target(
    ${project_name} ALL
    DEPENDS ${inc_output}
)
