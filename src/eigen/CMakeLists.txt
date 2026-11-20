# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: eigen-master
# Archive: eigen-master.tar.gz
# Upstream copyright and license notices: licenses/third-party/eigen/

build_info( " Adding eigen project" )

# project configuration

# project name
set( project_name "eigen" )

# project pkg
set( project_pkg ${project_name}-master )

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
set( inc_dir eigen3 )
set( inc_files eigen3/Eigen/Core )

# cmake files
set( cmake_files Eigen3Config.cmake Eigen3ConfigVersion.cmake Eigen3Targets.cmake )

build_add_dir( "${inc_dir}" "${build_inc_dir}" dir_output )
build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )
build_add_files( "${cmake_files}" "${build_dir}/share/eigen3/cmake" cmake_output )
if( UNIX )
    build_add_files( "eigen3.pc" "${build_dir}/share/pkgconfig" pkg_output )
endif()

# build configuration

# options
set( build_options -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS} )
if( WIN32 )
    list( APPEND build_options
        "-DCMAKE_PREFIX_PATH=${build_dir}"
        -DBUILD_TESTING=OFF
        -DEIGEN_BUILD_TESTING=OFF
        -DEIGEN_BUILD_DOC=OFF
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5
    )
endif()

set( build_output ${inc_output} ${cmake_output} ${pkg_output} )

# configure, make and install
build_cmake_commands( "${project_bin_dir}/${project_pkg}" build_make ${build_options} )

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)
