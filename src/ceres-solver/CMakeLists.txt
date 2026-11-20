# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: ceres-solver-master
# Archive: ceres-solver-master.tar.gz
# Upstream copyright and license notices: licenses/third-party/ceres-solver/

build_info( " Adding ceres-solver project" )

# project configuration

# project name
set( project_name "ceres-solver" )

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

# lib files
set( lib_files ceres )

# platform-specific outputs
if( WIN32 )
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        list( TRANSFORM lib_files APPEND "-debug" )
    endif()
    build_add_libs( "${lib_files}" "${build_lib_dir}" "${lib_prefix}" "${lib_suffix}" lib_output )
    set( inc_files ceres/ceres.h )
    build_add_files( "${inc_files}" "${build_dir}/include" inc_output )
    set( cmake_files CeresConfig.cmake CeresConfigVersion.cmake CeresTargets.cmake )
    build_add_files( "${cmake_files}" "${build_dir}/lib/cmake/Ceres" cmake_output )
else()
    # bin files
    set( bin_files
    )

    # bin files
    build_add_files(
        "${bin_files}" "${build_bin_dir}" bin_output
    )

    # lib files
    if( CMAKE_BUILD_TYPE STREQUAL Debug )
        set( lib_dtag "-debug" )
    endif()

    set( lib_version "2.2.0" )

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
endif()

# build configuration

if( WIN32 )
    # patches
    build_patch_commands( "${project_bin_dir}/${project_pkg}" build_patch
        "${project_src_dir}/msvc/ignore-appledouble-sources.patch"
    )
    # options
    set( build_options
        "-DCMAKE_PREFIX_PATH=${build_dir}"
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_BENCHMARKS=OFF
        -DSUITESPARSE=OFF
        -DLAPACK=OFF
        -DCXSPARSE=OFF
        -DUSE_CUDA=OFF
    )

    set( build_output ${lib_output} ${runtime_output} ${bin_output} ${inc_output} ${cmake_output} ${sitepackages_output} )
else()
    # patch
    if( ${CMAKE_SYSTEM_NAME} MATCHES "Linux" )
        set( build_patch
            COMMAND patch ${lib_bin_dir}/${lib_pkg}/exrenvmap/blurImage.cpp
            ${lib_src_dir}/blurImage.cpp.patch
        )
    endif()

    # config
    set( build_config ${build_config} -DCMAKE_CXX_STANDARD=14 )

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

    set( build_output ${bin_output} ${lib_output} )

    set( build_options ${build_config} )
endif()

# configure, make and install
build_cmake_commands( "${project_bin_dir}/${project_pkg}" build_make ${build_options}
    -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
)

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)

build_add_dependencies( ${project_name} eigen glog )
