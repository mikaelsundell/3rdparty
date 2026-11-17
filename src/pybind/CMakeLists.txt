# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: pybind11-2.9.1
# Archive: pybind11-2.9.1.tar.gz
# Upstream copyright and license notices: licenses/third-party/pybind/

build_info( " Adding pybind project" )

# project configuration

# project name
set( project_name "pybind" )

# project pkg
set( project_pkg "pybind11-2.9.1" )

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
set( inc_dir
    pybind11
)

# inc files
set( inc_files
    pybind11/pybind11.h
)

# pkg files
set( pkg_files
    pybind11Config.cmake
)

if( UNIX )

    # inc dir
    build_add_dir( 
        "${inc_dir}" "${build_inc_dir}" dir_output
    )

    build_add_files(
        "${inc_files}" "${build_inc_dir}" inc_output
    )

    build_add_files(
        "${pkg_files}" "${build_dir}/share/cmake/pybind11" pkg_output
    )
endif()

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
    set( build_options -DCMAKE_VERBOSE_MAKEFILE=true )

    # config
    set( build_config
        -DBUILD_TESTING=OFF
        -DPYTHON_EXECUTABLE=${build_python3}
        -DPYTHON_INCLUDE_DIR=${build_python3_include_dir}
        -DPYTHON_LIBRARY=${build_python3_library}
    )

    # configure, make and install
    set( build_make
        ${build_env} &&
        cd ${project_pkg} &&
        mkdir -p ${build_cmake} &&
        cd ${build_cmake} &&
        cmake ../ -DCMAKE_PREFIX_PATH=${build_dir}
            -DCMAKE_INSTALL_PREFIX=${build_dir}
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            ${build_options}
            ${build_config} &&
        make ${build_flags} &&
        make install
    )

    # scripts
    set( build_output ${inc_output} ${pkg_output} )

    build_install_check(
        "${build_output}"
        build_check
    )

    # run
    add_custom_command(
        OUTPUT ${build_output} ${dir_output}
        COMMAND ${build_download}
        COMMAND ${build_uncompress}
        COMMAND ${build_make}
        COMMAND ${build_check}
    )

endif()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)
