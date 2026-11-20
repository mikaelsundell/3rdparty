# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: draco-1.5.2
# Archive: draco-1.5.2.tar.gz
# Upstream copyright and license notices: licenses/third-party/draco/

build_info( " Adding draco project" )

# project configuration

# project name
set( project_name "draco" )

# project pkg
set( project_pkg ${project_name}-1.5.2 )

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

# platform-specific outputs
if( WIN32 )
    build_add_files( "draco${CMAKE_STATIC_LIBRARY_SUFFIX}" "${build_lib_dir}" lib_output )
    if( CMAKE_SHARED_LIBS )
        build_add_files( "draco${CMAKE_SHARED_LIBRARY_SUFFIX}" "${build_lib_dir}" runtime_output )
    endif()
    set( bin_files draco_encoder draco_decoder )
    list( TRANSFORM bin_files APPEND "${CMAKE_EXECUTABLE_SUFFIX}" )
    set( inc_files draco/compression/decode.h )
    build_add_files( "${inc_files}" "${build_dir}/include" inc_output )
else()
    # bin files
    set( bin_files
        draco_encoder-1.5.2
        draco_decoder-1.5.2
    )

    # lib files
    set( lib_files
        draco
    )

    # lib files
    build_add_libs(
        "${lib_files}" "${build_lib_dir}" ${lib_prefix} ${lib_suffix} lib_output
    )
endif()

build_add_files( "${bin_files}" "${build_bin_dir}" bin_output )

# build configuration

if( WIN32 )
    # options
    set( build_options
        -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
        "-DCMAKE_PREFIX_PATH=${build_dir}"
        -DDRACO_TESTS=OFF
        -DDRACO_WASM=OFF
        -DDRACO_UNITY_PLUGIN=OFF
        -DDRACO_MAYA_PLUGIN=OFF
    )

    set( build_output ${lib_output} ${runtime_output} ${bin_output} ${inc_output} ${cmake_output} )
else()
    # options
    if( CMAKE_SHARED_LIBS )
        set( build_options -DBUILD_SHARED_LIBS=true )
    else()
        set( build_options -DBUILD_SHARED_LIBS=false )
    endif()

     # config
    set( build_config ${build_config} -DCMAKE_MODULE_PATH=${build_dir}/share/cmake/pybind11 )

    set( build_env
        ${build_env} &&
        export CPLUS_INCLUDE_PATH=${build_inc_dir} &&
        export LD_LIBRARY_PATH=${build_lib_dir}
    )
    list( APPEND build_options ${build_config} )

    # scripts
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

    set( build_output ${bin_output} ${lib_output} )
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
