# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: glog-master
# Archive: glog-master.tar.gz
# Upstream copyright and license notices: licenses/third-party/glog/

build_info( " Adding glog project" )

# project configuration

# project name
set( project_name "glog" )

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

# inc dir and files
set( inc_dir glog )
set( inc_files glog/logging.h )
build_add_dir( "${inc_dir}" "${build_inc_dir}" dir_output )
build_add_files( "${inc_files}" "${build_inc_dir}" inc_output )

# lib files
set( lib_files glog )

# platform-specific outputs
if( WIN32 )
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        list( TRANSFORM lib_files APPEND "d" )
    endif()
    build_add_libs( "${lib_files}" "${build_lib_dir}" "${lib_prefix}" "${lib_suffix}" lib_output )
    set( cmake_files glog-config.cmake glog-config-version.cmake glog-targets.cmake )
    build_add_files( "${cmake_files}" "${build_dir}/lib/cmake/glog" cmake_output )
else()
    # pkgfiles
    set( pkg_files
        libglog.pc
    )

    # lib files
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        set( lib_dtag "d" )
    endif()

    set( lib_version "0.7.0" )

    foreach( lib_file ${lib_files} )

        if ( APPLE )
            list( APPEND lib_output
                ${build_lib_dir}/${lib_prefix}${lib_file}${lib_dtag}.${lib_version}${lib_suffix}
            )

        else()
            # INFO: on UNIX lib files appends version after suffix
            string( REGEX REPLACE
                "^([^.]+)([.]*)(.*)"
                "${lib_prefix}\\1${lib_suffix}\\2\\3"
                lib_file "${lib_file}"
            )

            list( APPEND lib_output
                ${build_lib_dir}/${lib_file}
            )
        endif()

    endforeach()

    # pkg files
    build_add_files(
        "${pkg_files}" "${build_lib_dir}/pkgconfig" pkg_output
    )
endif()

# build configuration

if( WIN32 )
    # options
    set( build_options
        -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
        "-DCMAKE_PREFIX_PATH=${build_dir}"
        -DBUILD_TESTING=OFF
        -DWITH_GFLAGS=OFF
        -DWITH_GTEST=OFF
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5
    )

    set( build_output ${lib_output} ${runtime_output} ${bin_output} ${inc_output} ${cmake_output} )
else()
    # patch
    if( ${CMAKE_SYSTEM_NAME} MATCHES "Linux" )
        set( build_patch
                COMMAND patch ${lib_bin_dir}/${lib_pkg}/exrenvmap/blurImage.cpp
                      ${lib_src_dir}/blurImage.cpp.patch
        )
    endif()

    # options
    if( CMAKE_SHARED_LIBS )
        set( build_options ${build_options} -DBUILD_SHARED_LIBS=TRUE )
    else()
        set( build_options ${build_options} -DBUILD_SHARED_LIBS=FALSE )
    endif()

    # config
    set( build_config ${build_config} -DCMAKE_CXX_STANDARD=14 )

    list( APPEND build_options ${build_config} )

    # scripts
    set( build_output ${bin_output} )

    if ( CMAKE_SHARED_LIBS )
        set( build_output ${build_output} ${lib_output} )
    endif()

    build_install_script(
        "${build_output}"
        ${build_dir}
        ${build_prefix_lib}
        ${build_prefix_framework}
        build_script
    )

    build_install_check(
        "${build_output}"
        build_check
    )

    set( build_output ${inc_output} )
endif()

# configure, make and install
build_cmake_commands( "${project_bin_dir}/${project_pkg}" build_make ${build_options} )

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)
