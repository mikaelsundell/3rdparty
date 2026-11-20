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
set( inc_dir pybind11 )
set( inc_files pybind11/pybind11.h )

# cmake files
set( cmake_files
    pybind11Config.cmake
    pybind11ConfigVersion.cmake
    pybind11Targets.cmake
)

build_add_dir( "${inc_dir}" "${build_inc_dir}" dir_output )
build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )
build_add_files( "${cmake_files}" "${build_dir}/share/cmake/pybind11" cmake_output )

# options
set( build_options "-DCMAKE_PREFIX_PATH=${build_dir}" )
if( WIN32 )
    build_patch_commands( "${project_bin_dir}/${project_pkg}" build_patch
        "${project_src_dir}/msvc/debug-python-abi.patch"
        "${project_src_dir}/msvc/dependent-rvalue-cast.patch"
    )
    list( APPEND build_options
        -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
        -DPYBIND11_TEST=OFF
        -DPYBIND11_NOPYTHON=ON
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5
    )
else()
    list( APPEND build_options
        -DCMAKE_VERBOSE_MAKEFILE=true
        -DBUILD_TESTING=OFF
        "-DPYTHON_EXECUTABLE=${build_python3}"
        "-DPYTHON_INCLUDE_DIR=${build_python3_include_dir}"
        "-DPYTHON_LIBRARY=${build_python3_library}"
    )
endif()

# configure, make and install
build_cmake_commands( "${project_bin_dir}/${project_pkg}" build_make ${build_options} )

set( build_output ${inc_output} ${cmake_output} )

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)
