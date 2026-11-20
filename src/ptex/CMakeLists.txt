# Copyright 2023-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

# Upstream package: ptex-master-220319
# Archive: ptex-master-220319.tar.gz
# Upstream copyright and license notices: licenses/third-party/ptex/

build_info( " Adding ptex project" )

# project configuration

# project name
set( project_name "ptex" )

# project pkg
set( project_pkg ${project_name}-master-220319 )

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
    build_add_files( "Ptex${CMAKE_STATIC_LIBRARY_SUFFIX}" "${build_lib_dir}" lib_output )
    if( CMAKE_SHARED_LIBS )
        build_add_files( "Ptex${CMAKE_SHARED_LIBRARY_SUFFIX}" "${build_lib_dir}" runtime_output )
    endif()
    set( inc_files Ptexture.h PtexVersion.h )
    set( cmake_files ptex-config.cmake ptex-config-version.cmake ptex-exports.cmake )
    build_add_files( "${cmake_files}" "${build_dir}/share/cmake/Ptex" cmake_output )
else()
    # bin files
    set( bin_files
        ptxinfo
    )

    # include files
    set( inc_files
        PtexExports.h
        PtexHalf.h
        PtexInt.h
        PtexPlatform.h
        Ptexture.h
        PtexUtils.h
        PtexVersion.h
    )

    # lib files
    set( lib_files
        Ptex.2.4
    )

    # bin files
    build_add_files(
        "${bin_files}" "${build_bin_dir}" bin_output
    )

    # lib files
    build_add_libs(
        "${lib_files}" "${build_lib_dir}" ${lib_prefix} ${lib_suffix} lib_output
    )
endif()

build_add_files( "${inc_files}" "${build_dir}/include" inc_output )

# build configuration

if( WIN32 )
    # patches
    build_patch_commands( "${project_bin_dir}/ptex" build_patch
        "${project_src_dir}/msvc/cmake-zlib-dependency.patch"
    )
    set( build_static_libs ON )
    if( CMAKE_SHARED_LIBS )
        set( build_static_libs OFF )
    endif()
    # options
    set( build_options
        -DPTEX_BUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
        -DPTEX_BUILD_STATIC_LIBS=${build_static_libs}
    )

    set( build_output ${lib_output} ${runtime_output} ${bin_output} ${inc_output} ${cmake_output} )
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

    set( build_options
        ${build_options}
    )
endif()

# configure, make and install
build_cmake_commands( "${project_bin_dir}/ptex" build_make ${build_options}
    -DBUILD_SHARED_LIBS=${CMAKE_SHARED_LIBS}
    "-DCMAKE_PREFIX_PATH=${build_dir}"
)

# run
build_add_archive_rule()

# Custom target builds missing installed outputs.
add_custom_target(
    ${project_name} ALL
    DEPENDS ${build_output} ${dir_output}
)

build_add_dependencies( ${project_name} zlib-ng )
