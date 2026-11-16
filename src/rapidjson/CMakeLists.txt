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
set( inc_dir
    rapidjson
)

# inc files
set( inc_files
    rapidjson/cursorstreamwrapper.h
)

# pkg files
set( pkg_files
    cmake/RapidJSON/RapidJSONConfig.cmake
    pkgconfig/RapidJSON.pc
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
        "${pkg_files}" "${build_lib_dir}" pkg_output
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
        ${untar} ${project_bin_dir}/${project_pkg}.tar.gz -C ${project_bin_dir}
    )

    # options
    set( build_options -DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON )

    # config
    set( build_config
        -DRAPIDJSON_BUILD_DOC=OFF
        -DRAPIDJSON_BUILD_EXAMPLES=OFF
        -DRAPIDJSON_BUILD_TESTS=OFF
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
    build_add_custom_command(
        OUTPUT ${dir_output} ${build_output}
        COMMAND ${build_download}
        COMMAND ${build_uncompress}
        COMMAND ${build_make}
        COMMAND ${build_check}
    )

endif()

# Custom target builds missing or outdated installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${dir_output} ${build_output}
)
