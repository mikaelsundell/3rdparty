# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: tclap-1.2.5
# Archive: tclap-1.2.5.tar.gz
# Upstream copyright and license notices: licenses/third-party/tclap/

build_info( " Adding tclap project" )

# project configuration

# project name
set( project_name "tclap" )

# project pkg
set( project_pkg ${project_name}-1.2.5 )

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

# inc dir and files
set( inc_dir tclap )
set( inc_files tclap/CmdLine.h )
build_add_dir( "${inc_dir}" "${build_inc_dir}" dir_output )
build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )

# build configuration

if( WIN32 )
    set( build_make
        COMMAND ${copy_dir} "${project_bin_dir}/${project_pkg}/include/tclap" "${build_inc_dir}/tclap"
    )
else()
    # configure, make and install
    set( build_make
        ${build_env} &&
        cd ${project_pkg} &&
        ./configure
            --prefix=${build_dir}
            ${CFLAGS}
            CPPFLAGS=-I${build_inc_dir}
            LDFLAGS=-L${build_lib_dir} &&
        make ${build_flags} &&
        make install
    )

    string( JOIN " " build_make ${build_make} )
    set( build_make COMMAND sh -c "${build_make}" )
endif()

# run
set( build_output ${inc_output} )
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)
