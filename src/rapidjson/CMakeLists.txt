# Copyright 2026-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: Tencent/rapidjson 24b5e7a8b27f42fa16b96fc70aade9106cf7102f
# Archive: rapidjson-master-250205.tar.gz
# Upstream copyright and license notices: licenses/third-party/rapidjson/

build_info( " Adding rapidjson project" )

# project configuration

# project name
set( project_name "rapidjson" )

# project pkg
set( project_pkg "rapidjson-master-250205" )

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
set( inc_dir rapidjson )
set( inc_files rapidjson/document.h rapidjson/cursorstreamwrapper.h )

build_add_dir( "${inc_dir}" "${build_inc_dir}" dir_output )
build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )

# pkg files
if( WIN32 )
    set( cmake_files RapidJSONConfig.cmake RapidJSONConfigVersion.cmake )
    build_add_files( "${cmake_files}" "${build_cmake_dir}" pkg_output )
else()
    set( pkg_files cmake/RapidJSON/RapidJSONConfig.cmake pkgconfig/RapidJSON.pc )
    build_add_files( "${pkg_files}" "${build_lib_dir}" pkg_output )
endif()

# options
set( build_options
    "-DCMAKE_PREFIX_PATH=${build_dir}"
    -DRAPIDJSON_BUILD_DOC=OFF
    -DRAPIDJSON_BUILD_EXAMPLES=OFF
    -DRAPIDJSON_BUILD_TESTS=OFF
)
if( WIN32 )
    list( APPEND build_options
        -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5
    )
else()
    list( APPEND build_options -DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON )
endif()

# configure, make and install
build_cmake_commands( "${project_bin_dir}/${project_pkg}" build_make ${build_options} )

set( build_output ${inc_output} ${pkg_output} )

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)
