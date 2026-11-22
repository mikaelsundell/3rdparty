# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: imath-3.2.2
# Archive: imath-3.2.2.tar.gz
# Upstream copyright and license notices: licenses/third-party/imath/

build_info( " Adding imath project" )

# project configuration

# project name
set( project_name "imath" )

# project pkg
set( project_pkg ${project_name}-3.2.2 )

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
set( inc_dir Imath )
set( inc_files Imath/half.h Imath/ImathConfig.h )

# lib files
set( lib_files Imath-3_2 )
string( TOLOWER "${CMAKE_BUILD_TYPE}" build_config_name )
if( build_config_name STREQUAL "debug" )
    string( APPEND lib_files "_d" )
elseif( build_config_name STREQUAL "" )
    set( build_config_name noconfig )
endif()

# pkg files
set( pkg_files Imath.pc )
set( cmake_files
    ImathConfig.cmake
    ImathConfigVersion.cmake
    ImathTargets.cmake
    ImathTargets-${build_config_name}.cmake
)

build_add_dir( "${inc_dir}" "${build_inc_dir}" dir_output )
build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )
build_add_versioned_lib( "${lib_files}" 30.3.2.2 30 lib_output shared_output )
build_add_files( "${pkg_files}" "${build_lib_dir}/pkgconfig" pkg_output )
build_add_files( "${cmake_files}" "${build_lib_dir}/cmake/Imath" cmake_output )

# build configuration

# options
set( build_options
    -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
    -DBUILD_TESTING=OFF
    -DCMAKE_INSTALL_LIBDIR=lib
)

# configure, make and install
build_cmake_commands( "${project_bin_dir}/Imath-3.2.2" build_make ${build_options} )

# scripts
set( build_output ${lib_output} ${inc_output} ${pkg_output} ${cmake_output} )

if( shared_output )
    build_install_script(
        "${shared_output}"
        "${build_dir}"
        "${build_prefix_lib}"
        "${build_prefix_framework}"
        build_script
    )
endif()

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)
