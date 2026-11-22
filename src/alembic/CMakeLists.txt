# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: alembic-master
# Archive: alembic-master.tar.gz
# Upstream copyright and license notices: licenses/third-party/alembic/

build_info( " Adding alembic project" )

# project configuration

# project name
set( project_name "alembic" )

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

# platform-specific outputs
if( WIN32 )
    build_add_files( "Alembic${CMAKE_STATIC_LIBRARY_SUFFIX}" "${build_dir}/lib" lib_output )
    if( CMAKE_SHARED_LIBS )
        build_add_files( "Alembic${CMAKE_SHARED_LIBRARY_SUFFIX}" "${build_dir}/lib" runtime_output )
    endif()
    set( bin_files abcecho abcls abctree )
    list( TRANSFORM bin_files APPEND "${CMAKE_EXECUTABLE_SUFFIX}" )
    set( inc_files Alembic/Abc/All.h )
    build_add_files( "${inc_files}" "${build_dir}/include" inc_output )
    set( cmake_files AlembicConfig.cmake AlembicConfigVersion.cmake AlembicTargets.cmake )
    build_add_files( "${cmake_files}" "${build_dir}/lib/cmake/Alembic" cmake_output )
else()
    # bin files
    set( bin_files
        abcdiff
        abcecho
        abcechobounds
        abcls
        abcstitcher
        abctree
    )

    # lib files
    set( lib_files
        Alembic
    )

    # lib files
    build_add_libs(
        "${lib_files}" "${build_lib_dir}" ${lib_prefix} ${lib_suffix} lib_output
    )
endif()

build_add_files( "${bin_files}" "${build_dir}/bin" bin_output )

# build configuration

if( WIN32 )
    # options
    set( build_options
        "-DCMAKE_PREFIX_PATH=${build_dir}"
        -DALEMBIC_SHARED_LIBS=${CMAKE_SHARED_LIBS}
        -DUSE_TESTS=OFF
        -DUSE_HDF5=OFF
        "-DImath_DIR=${build_lib_dir}/cmake/Imath"
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5
    )

    set( build_output ${lib_output} ${runtime_output} ${bin_output} ${inc_output} ${cmake_output} ${sitepackages_output} )

    build_add_dependencies( ${project_name} imath )
else()
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

    build_add_dependencies( ${project_name} llvm )
endif()

# configure, make and install
build_cmake_commands( "${project_bin_dir}/alembic" build_make ${build_options}
    -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
)

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)
